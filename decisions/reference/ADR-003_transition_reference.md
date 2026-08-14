# ADR-003 Reference: Complete Transition and Command Rules

This reference supports `../ADR-003_state_machine_definition.md`.

ADR-003 is the peer-review entry point for the hierarchical FSM. This file holds the exhaustive transition table and command split rules so the ADR can stay readable while the detailed implementation contract remains available.

## Complete transition specification

When ADR-003 summary text and this reference overlap, this reference is authoritative for exact transition guards and timing constraints.

**Transition priority (highest to lowest):**
1. Fault/interlock path (`OK == 0`) has highest priority in `IDLE` and all `RUN.*` sub-states; `START.*` and `ERROR.*` use their own state-specific handling.
2. Safety-recovery control (`clear_error`) applies only inside `ERROR.run`.
3. Commanded/nominal transitions (arm/test/sync/acquisition flow) apply only when higher-priority rules are not active.
4. In `RUN.*`, disarm (`disarm` on main or backplane `EN` falling on function boards) takes precedence over SYNC-driven `RUN.run -> RUN.stop` progression.

**Fault classification note:** When `OK == 0` is caused by a missing distributed `CLOCK` or failure in the `CLOCK -> divider -> pet` path, the board retains independent clock-loss and watchdog-activation evidence. Classification is performed by the host in `ERROR.run` using ADR-001 R6. Clock-loss evidence identifies F5 regardless of whether the watchdog also activated. Corrective action is to restore the external main `CLOCK` source and distributed path first, then inspect local divider/pet-path integrity if needed.

**Supervision classification note:** Host-supervision timeout while armed is classified as **S1** in ADR-001 R10. It is separate from the hardware fault taxonomy (F1-F6) because it is active only while armed (`EN=1`) and its root cause is host communication loss. Diagnostic differentiation uses the dedicated S1 bit in `fault_vector`.

| Current state | Event / Guard | Next state | Notes / Timing |
|---|---|---|---|
| START.boot | `boot_done == 1` | START.wait | Board enters START.wait with boot pull-down latch still asserted (`boot_pulldown_active`); release is allowed only after CLOCK qualification |
| START.wait | Function board: `watchdog_pet_edge_detected()` within `T_clock_present_max`; Main board: `main_clock_edge_detected()` within `T_clock_present_max`; then `OK == 1` continuously for `T_start_stable` by the absolute deadline `T_start_deadline` | IDLE | Start gate passed; clear retained watchdog evidence on this boundary because watchdog activation before CLOCK qualification may be expected during fleet power-up |
| START.wait | `OK` drops before `T_start_stable` completes | START.wait | Restart `T_start_stable` for external/global OK drops; local internal-fault summaries use immediate abort rule |
| START.boot or START.wait | `local_trip_summary == 1` | ERROR.run | Immediate local-fault abort. START states may tolerate shared `OK` LOW from fleet behavior, but must not mask known local faults. |
| START.wait | Function board: no `watchdog_pet_edge_detected()` by `T_clock_present_max`; Main board: no `main_clock_edge_detected()` by `T_clock_present_max` | ERROR.run | CLOCK qualification fault: boards record role-appropriate clock-loss evidence and the watchdog may independently activate. Recovery requires restoring the external main CLOCK source and distributed CLOCK path first. |
| START.wait | `T_start_deadline` elapsed with gates not passed | ERROR.run | START.wait deadline timeout (covers both "OK never rose" and "OK never stabilized"); sets the dedicated START.wait-deadline diagnostic bit in `fault_vector` (ADR-003 R7 timeout diagnostic visibility) |
| IDLE (main) | `send_pre_arm_sync` command received via Ethernet | IDLE | Main emits one pre-arm `SYNC` pulse while `EN=0`; main does not autonomously generate IDLE `SYNC` pulses |
| IDLE | `SYNC` rising edge and `EN == 0` | IDLE | On boards with a phase-controlled local converter, reset only its optional converter divider and restart `T_settle`; watchdog and baseline divider phase are unchanged. Main enforces ICD-defined `T_sync_min` HIGH/LOW dwell. |
| IDLE (main) | `arm` command and all applicable local operational-safety/readiness checks pass | RUN.init | Main asserts `EN = 1`; function-board readiness remains host-polled and EN-rise enforced locally. Checks include `local_sync_ready` where applicable. |
| IDLE (main) | `arm` command and any applicable local operational-safety/readiness check fails | IDLE | Main replies `ARM_REJECTED_NOT_READY_MAIN` with the blocking reason(s) |
| IDLE | debounced `EN` rising (`N_en_rise_debounce` samples) AND all applicable local operational-safety/readiness gates pass (function boards) | RUN.init | Gates include `local_sync_ready` and `sequencer_ready` on sequencer boards; FPGA `relay_drive` ARM asserts after RUN.init completes and external relay stage drives the coil |
| IDLE | debounced `EN` rising (`N_en_rise_debounce` samples) AND any applicable local operational-safety/readiness gate fails (function boards) | ERROR.run | EN-rise safety gate violation; board sets dedicated interlock-violation source bit in `fault_vector`, which sets `local_trip_summary`, asserts `OK` low, and trips globally |
| IDLE | `set_injected_fault` command accepted on any board | ERROR.run | Intentional maintenance trip path for F4 verification |
| IDLE | `OK == 0` | ERROR.run | Immediate fault path |
| RUN.init | `run_init_done == 1` | RUN.wait | Arm-entry initialization complete |
| RUN.wait | accepted timing-domain `SYNC` rising event | RUN.run | Start acquisition on the defined 100 MHz edge. Main must enforce first-trigger guard: first `SYNC` rising edge after each `EN` assertion is allowed only at/after `t_en_rise + T_run_init_max` |
| Any RUN.* (main) | `disarm` command to main | IDLE | Forced disarm path; `EN` de-asserts as `top_state` leaves RUN; residual cleanup runs as IDLE-entry actions |
| Any RUN.* (function) | backplane `EN` falling edge (no debounce) | IDLE | Function board follows main-board disarm immediately from any armed sub-state; relays already open via the `EN=0` hardware reset path; residual cleanup runs as IDLE-entry actions |
| RUN.run | accepted timing-domain `SYNC` falling event | RUN.stop | Graceful stop sequence |
| RUN.stop | `run_stop_done == 1` | RUN.wait | Ready for next trigger |
| Any RUN.* | any board host-supervision timeout (`> T_host_supervision_max`) while `EN=1` | ERROR.run | Timed-out board asserts `OK` low (armed communication supervision fault) |
| Any RUN.* | `OK == 0` | ERROR.run | Hardware interlock path, including supervision-induced trips |
| ERROR.run | `OK == 0` | ERROR.run | System already latched safe (`EN = 0`, `relay_drive = 0`, external relay RESET active, fault latched — all Moore consequences of ERROR entry); FSM ignores OK bus drops. However, late-arriving local faults must still update fault_vector and local_trip_summary per ADR-003 R6 rule 5. |
| ERROR.run | `set_injected_fault` command | ERROR.run | Targeted board asserts injected fault (`OK == 0` expected) |
| ERROR.run | `clear_injected_fault` command | ERROR.run | Clears injected source only; FSM remains latched until `clear_error` |
| ERROR.run | `halt_watchdog_pets` command | ERROR.run | FPGA stops pet signal; after `T_WD_HW_max`, watchdog IC pulls `OK` LOW via its independent driver (F4 Phase 2 test) |
| ERROR.run | `resume_watchdog_pets` command | ERROR.run | FPGA resumes pet signal; targeted watchdog path must release and `OK` must return HIGH within `T_WD_RELEASE_max` if no other source holds it LOW |
| ERROR.run (main) | `clear_error` command received via Ethernet | ERROR.clear | Main asserts `CLEAR` HIGH, starts local clear routine timer (bounded by `T_clear_max`), de-asserts `CLEAR` after `T_clear_hold` |
| ERROR.run (function) | Debounced `CLEAR` rising edge (`N_clear_debounce` consecutive FSM clock samples of `CLEAR == 1`) | ERROR.clear | Filtered trigger from main's `CLEAR` assertion; glitches shorter than `N_clear_debounce` cycles are rejected |
| ERROR.clear (function) | function-board exit evaluation boundary reached (ADR-003 R6 rule 5) with `fault_vector == 0` | START.wait | Success path: clear `local_trip_summary` and retained watchdog evidence on this boundary; `OK` releases at START.wait entry |
| ERROR.clear (function) | function-board exit evaluation boundary reached (ADR-003 R6 rule 5) with `fault_vector > 0` | ERROR.run | Fault persists/new fault occurred; keep `local_trip_summary = 1` and retain fault-source bits for diagnostics |
| ERROR.clear (main) | exit evaluation boundary reached (bounded by `T_clear_max`), `T_clear_hold` pulse completed, and `fault_vector == 0` | START.wait | Main CLEAR pulse generation is decoupled from main local-clear completion; clear `local_trip_summary` and retained watchdog evidence on this boundary |
| ERROR.clear (main) | exit evaluation boundary reached (bounded by `T_clear_max`), `T_clear_hold` pulse completed, and `fault_vector > 0` | ERROR.run | Main CLEAR pulse generation is decoupled from main local-clear completion; remains locally faulted or cannot clear |

## Clock-loss propagation

After `START.wait` completes, CLOCK-source loss is detected on both board roles and propagates through the existing `OK == 0` transitions. A continuous management-domain activity monitor detects the role-appropriate clock loss, enters the normal trip path, and retains clock-loss evidence. The watchdog may independently activate and retains separate diagnostic evidence. The host classifies the fault in `ERROR.run` using ADR-001 R6. Restoration does not resume acquisition automatically: the system must complete `ERROR.clear`, requalify through `START.wait`, return to `IDLE`, and be armed again.

## Command split rules

**Main/function-board arming split (normative):**
1. Only the main accepts Ethernet `arm`/`disarm`/`clear_error`/`send_pre_arm_sync`, and the acquisition trigger start/stop requests that command RUN `SYNC` edges (command naming and framing are ICD-defined; the first-trigger guard in ADR-003 R7 applies).
2. Function boards ignore or reject Ethernet `arm`, `send_pre_arm_sync`, and acquisition trigger requests.
3. Function boards transition IDLE -> RUN only on backplane `EN` rising edge.
4. `disarm` is accepted by the main in any `RUN.*`; main transitions directly to IDLE and `EN` de-asserts on that transition.
5. Function boards do not consume Ethernet `disarm`; they transition `Any RUN.* -> IDLE` on backplane `EN` falling edge.

**Injected-fault and watchdog-test command split (normative):**
1. Any board (including main) may accept `set_injected_fault` / `clear_injected_fault` / `halt_watchdog_pets` / `resume_watchdog_pets` for itself.
2. Legal state window is only `IDLE` and `ERROR.run`.
3. Commands in `START.*`, `RUN.*`, and `ERROR.clear` are rejected.
4. `clear_injected_fault` never clears `local_trip_summary` or `fault_vector`.
5. `clear_error`/`CLEAR` must force `injected_fault = 0` and resume watchdog petting as failsafe cleanup; local-trip release occurs only via the `ERROR.clear` success boundary (`clear_summary_strobe`).

**EN-rise safety gate on function boards (normative):**
1. On `EN` rising edge, the outcome is determined by all applicable local operational-safety/readiness gates evaluated simultaneously, including `local_sync_ready` and `sequencer_ready` on sequencer boards.
2. If all applicable gates pass, transition to `RUN.init` (`local_sync_ready` is set after local `T_settle` has elapsed since the last IDLE `SYNC` rising edge for boards with synchronized local converters, and may be tied to `1` for boards without them).
3. If any applicable gate fails, the board must immediately set a dedicated interlock-violation source bit in `fault_vector`; by rule this sets `local_trip_summary = 1`, asserts `OK` low, and transitions to `ERROR.run`. This intentionally catches edge cases such as an individual board reboot that missed the IDLE SYNC phase-reset.
