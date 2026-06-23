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

**Fault classification note:** When `OK == 0` is caused by a missing distributed `CLOCK` or failure in the `CLOCK -> divider -> pet` path, the clock monitor sets the F5 source bit in `fault_vector` (`F5_latch`) and the watchdog may independently trip (setting `WD_latch`). Classification is performed by the host in `ERROR.run` using the diagnostic truth table (ADR-001 R6). If `F5_latch == 1`, the authoritative class is F5 regardless of `WD_latch` state. Corrective action: restore the external main `CLOCK` source and distributed `CLOCK` path first, then inspect local divider/pet-path integrity if needed.

**Supervision classification note:** keep_alive lease timeout while armed is classified as **S1** (supervisory interlock event) in ADR-001 R10. It is separate from the hardware fault taxonomy (F1-F6) because it is only active while armed (`EN=1`) and its root cause is host communication loss, not hardware failure. Diagnostic differentiation uses `latched_supervision_fault` (see ADR-001 R10 truth table).

| Current state | Event / Guard | Next state | Notes / Timing |
|---|---|---|---|
| START.boot | `boot_done == 1` | START.wait | Board enters START.wait with boot pull-down latch still asserted (`boot_pulldown_active`); release is allowed only after CLOCK qualification |
| START.wait | Function board: `watchdog_pet_edge_detected()` within `T_clock_present_max`; Main board: `main_clock_edge_detected()` within `T_clock_present_max`; then first `OK == 1` within `T_ok_rise_max`, then `OK == 1` continuously for `T_start_stable` by absolute deadline `T_ok_rise_max + T_start_stable` | IDLE | Start gate passed |
| START.wait | after first OK-high detection, `OK` drops before `T_start_stable` completes | START.wait | Restart `T_start_stable` for external/global OK drops; local internal-fault summaries use immediate abort rule |
| START.boot or START.wait | `local_trip_summary == 1` | ERROR.init | Immediate local-fault abort. START states may tolerate shared `OK` LOW from fleet behavior, but must not mask known local faults. |
| START.wait | Function board: no `watchdog_pet_edge_detected()` by `T_clock_present_max`; Main board: no `main_clock_edge_detected()` by `T_clock_present_max` | ERROR.init | CLOCK qualification fault: function boards set F5 source bit in `fault_vector` (`F5_latch`); watchdog may independently set `WD_latch`. Main board sets a dedicated external-clock-source fault bit in its `fault_vector`. Host classifies via diagnostic truth table (ADR-001 R6). Recovery requires restoring the external main CLOCK source and distributed CLOCK path first. |
| START.wait | no `OK == 1` detected within `T_ok_rise_max` | ERROR.init | Start-up/recovery timeout fault |
| START.wait | `T_ok_rise_max + T_start_stable` elapsed and gate not passed | ERROR.init | Stability-gate timeout fault |
| IDLE (main) | `send_pre_arm_sync` command received via Ethernet | IDLE | Main emits one pre-arm `SYNC` pulse while `EN=0`; main does not autonomously generate IDLE `SYNC` pulses |
| IDLE | `SYNC` rising edge and `EN == 0` | IDLE | Pre-arm sync action: reset local divider chain (÷50 baseline, ÷M watchdog, and optional ÷N local DC-DC where implemented), restart `T_settle` where applicable; main enforces `T_sync_min` HIGH/LOW dwell for deterministic capture |
| IDLE (main) | `arm` command and local `local_sync_ready == 1` | RUN.init | Main asserts `EN = 1`; function-board readiness/attestation remains host-polled and EN-rise enforced locally. If no main-local synchronization readiness applies, this guard is tied to `1`. |
| IDLE (main) | `arm` command and local `local_sync_ready == 0` | IDLE | Main replies `ARM_REJECTED_NOT_READY_MAIN`; applies only when main-local synchronization readiness is implemented |
| IDLE | debounced `EN` rising (`N_en_rise_debounce` samples) AND `local_sync_ready == 1` AND `sequencer_hash_valid_current_arm == 1` (function boards) | RUN.init | Readiness gate passed; FPGA `relay_drive` ARM asserts after RUN.init completes and external relay stage drives the coil |
| IDLE | debounced `EN` rising (`N_en_rise_debounce` samples) AND (`local_sync_ready == 0` OR `sequencer_hash_valid_current_arm == 0`) (function boards) | ERROR.init | EN-rise safety gate violation; board sets dedicated interlock-violation source bit in `fault_vector`, which sets `local_trip_summary`, asserts `OK` low, and trips globally |
| IDLE | `set_injected_fault` command accepted on any board | ERROR.init | Intentional maintenance trip path for F4 verification |
| IDLE | `OK == 0` | ERROR.init | Immediate fault path |
| RUN.init | `run_init_done == 1` | RUN.wait | Arm-entry initialization complete |
| RUN.wait | `SYNC` rising edge | RUN.run | Start acquisition. Main must enforce first-trigger guard: first `SYNC` rising edge after each `EN` assertion is allowed only at/after `t_en_rise + T_run_init_max` |
| Any RUN.* (main) | `disarm` command to main | RUN.disarm | Forced disarm path; main de-asserts `EN` on `RUN.disarm` entry |
| Any RUN.* (function) | backplane `EN` falling edge (no debounce) | RUN.disarm | Function board follows main-board disarm immediately from any armed sub-state |
| RUN.run | `SYNC` falling edge | RUN.stop | Graceful stop sequence |
| RUN.stop | `run_stop_done == 1` | RUN.wait | Ready for next trigger |
| RUN.disarm | one FSM clock elapsed since entry | IDLE | Deterministic one-cycle bookkeeping complete; relays already open due to `EN=0` |
| Any RUN.* | any board keep_alive lease timeout (`> T_keepalive_lease_max`) while `EN=1` | ERROR.init | Timed-out board asserts `OK` low (armed communication supervision fault) |
| Any RUN.* | `OK == 0` | ERROR.init | Immediate fault path (includes keep_alive-induced trips) |
| ERROR.init | entry actions complete (`EN = 0`, `relay_drive = 0`, external relay RESET active, fault latched) | ERROR.run | Latched fault hold state |
| ERROR.run | `OK == 0` | ERROR.run | System already latched safe; FSM ignores OK bus drops (no re-entry to ERROR.init). However, late-arriving local faults must still update fault_vector and local_trip_summary per ADR-003 R6 rule 5. |
| ERROR.run | `set_injected_fault` command | ERROR.run | Targeted board asserts injected fault (`OK == 0` expected) |
| ERROR.run | `clear_injected_fault` command | ERROR.run | Clears injected source only; FSM remains latched until `clear_error` |
| ERROR.run | `halt_watchdog_pets` command | ERROR.run | FPGA stops pet signal; after `T_WD_HW_max`, watchdog IC pulls `OK` LOW via its independent driver (F4 Phase 2 test) |
| ERROR.run | `resume_watchdog_pets` command | ERROR.run | FPGA resumes pet signal; targeted watchdog path must release and `OK` must return HIGH within `T_WD_RELEASE_max` if no other source holds it LOW |
| ERROR.run (main) | `clear_error` command received via Ethernet | ERROR.clear | Main asserts `CLEAR` HIGH, starts local clear routine timer (bounded by `T_clear_max`), de-asserts `CLEAR` after `T_clear_hold` |
| ERROR.run (function) | Debounced `CLEAR` rising edge (`N_clear_debounce` consecutive FSM clock samples of `CLEAR == 1`) | ERROR.clear | Filtered trigger from main's `CLEAR` assertion; glitches shorter than `N_clear_debounce` cycles are rejected |
| ERROR.clear (function) | function-board exit evaluation boundary reached (ADR-003 R6 rule 5) with `fault_vector == 0` | START.wait | Success path: assert `clear_summary_strobe` and `clear_wd_latch` on this boundary so `local_trip_summary`, `latched_supervision_fault`, and `WD_latch` clear, and `OK` releases at START.wait entry |
| ERROR.clear (function) | function-board exit evaluation boundary reached (ADR-003 R6 rule 5) with `fault_vector > 0` | ERROR.init | Fault persists/new fault occurred; keep `local_trip_summary = 1` and retain fault-source bits for diagnostics |
| ERROR.clear (main) | exit evaluation boundary reached (bounded by `T_clear_max`), `T_clear_hold` pulse completed, and `fault_vector == 0` | START.wait | Main CLEAR pulse generation is decoupled from main local-clear completion; assert `clear_summary_strobe` and `clear_wd_latch` on this boundary so `local_trip_summary`, `latched_supervision_fault`, and `WD_latch` clear |
| ERROR.clear (main) | exit evaluation boundary reached (bounded by `T_clear_max`), `T_clear_hold` pulse completed, and `fault_vector > 0` | ERROR.init | Main CLEAR pulse generation is decoupled from main local-clear completion; remains locally faulted or cannot clear |

## Clock-loss propagation

After `START.wait` completes, CLOCK-source loss is detected on both board roles and propagates through the existing `OK == 0` transitions. On the main board, a continuous CLOCK-source monitor (management clock domain) detects external clock-generator failure and sets the dedicated CLOCK-source fault bit in `fault_vector`. On function boards, the internal clock monitor detects distributed CLOCK loss and sets the F5 source bit in `fault_vector` (`F5_latch`); the watchdog may independently trip (`WD_latch`). The host classifies the fault in `ERROR.run` using the diagnostic truth table (ADR-001 R6).

## Command split rules

**Main/function-board arming split (normative):**
1. Only the main accepts Ethernet `arm`/`disarm`/`clear_error`/`send_pre_arm_sync`.
2. Function boards ignore or reject Ethernet `arm` and `send_pre_arm_sync`.
3. Function boards transition IDLE -> RUN only on backplane `EN` rising edge.
4. `disarm` is accepted by the main in any `RUN.*`; main enters `RUN.disarm` immediately and de-asserts `EN` on `RUN.disarm` entry.
5. Function boards do not consume Ethernet `disarm`; they transition `Any RUN.* -> RUN.disarm` on backplane `EN` falling edge, then `RUN.disarm -> IDLE` after one FSM clock.

**Injected-fault and watchdog-test command split (normative):**
1. Any board (including main) may accept `set_injected_fault` / `clear_injected_fault` / `halt_watchdog_pets` / `resume_watchdog_pets` for itself.
2. Legal state window is only `IDLE` and `ERROR.run`.
3. Commands in `START.*`, `RUN.*`, and `ERROR.clear` are rejected.
4. `clear_injected_fault` never clears `local_trip_summary` or `fault_vector`.
5. `clear_error`/`CLEAR` must force `injected_fault = 0` and resume watchdog petting as failsafe cleanup; local-trip/supervision release occurs only via the `ERROR.clear` success boundary (`clear_summary_strobe`).

**EN-rise safety gate on function boards (normative):**
1. On `EN` rising edge, the outcome is fully determined by two conditions evaluated simultaneously: `local_sync_ready` and `sequencer_hash_valid_current_arm`.
2. If both are `1`, transition to `RUN.init` (`local_sync_ready` is set after local `T_settle` has elapsed since the last IDLE `SYNC` rising edge for boards with synchronized local converters, and may be tied to `1` for boards without them).
3. If either is `0`, the board must immediately set a dedicated interlock-violation source bit in `fault_vector`; by rule this sets `local_trip_summary = 1`, asserts `OK` low, and transitions to `ERROR.init`. This intentionally catches edge cases such as an individual board reboot that missed the IDLE SYNC phase-reset.
