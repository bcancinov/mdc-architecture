# Historical Changelog

This file contains repository changes before the latest summary in `README.md`.

## 2026-08-16 — Architecture-altitude and coherence pass

- Kept externally visible safety, timing, synchronization, configuration, and data-path behavior in the ADRs while moving exact registers, counters, debounce values, protocol details, and circuit topologies to future ICD and design specifications.
- Retained five mandatory utility-converter synchronization outputs, acquisition synchronization at integer divisors of 2 MHz, and forced continuous fixed-frequency switching; channel mapping, divisor, phase, and electrical details are ICD scope.
- Retained independent clock-loss and watchdog evidence without mandating one divider or clock-domain-crossing implementation.
- Clarified that the half-cycle `SYNC` launch/capture convention prevents a one-cycle sequencer ambiguity; management-domain observation has no phase requirement.
- Replaced fixed reliability portfolios, hold-up circuits, relay latch structures, and analog-filter topologies with verifiable behavioral requirements.
- Made all files under `decisions/reference/` explicitly non-normative and shortened the system concept guide to an introductory overview.

## 2026-08-16 — Interlock-power terminology clarification

- Renamed `V_SAFE_AON` to `V_INTERLOCK_LOCAL` to state that it is board-local interlock power, not an indefinitely available or backplane-distributed supply.
- Separated backplane shared-rail supervision, local interlock-supply supervision, fail-safe power/reset detection, and watchdog liveness detection in the normative and introductory explanations.
- Reserved PGOOD terminology for native converter power-good outputs and clarified that not every board-local converter requires independent supervision.
- Renamed the protected distributed bulk rail from `+12V_RAW` to `+12V`, named the external unprotected input `+12V_IN`, and required one central backplane eFuse between them.
- Kept local board protection implementation-specific rather than requiring an eFuse on every board or analog utility input.

## 2026-08-14 — Timing, supervision, power, and identity refinement

- Renamed the shared digital utility rail to `+3.3V_DIG_AUX` and limited it to low-power auxiliary digital loads.
- Required processors, FPGAs, memory, and other high-current digital loads to use board-local conversion from `+12V`, avoiding excessive connector current and conducted-noise coupling through a shared 3.3 V rail.
- Defined acquisition `SYNC` capture in the 100 MHz timing domain with a separate CDC-safe management observation; management/processor clocks remain independent and acquisition never resumes automatically after clock loss.
- Removed universal jitter and fault-latency numbers in favor of application timing verification and hardware interlock propagation without intentional software delay.
- Connected compatible backplane utility-converter PGOOD outputs directly to `OK`; main-board analog rail measurements provide diagnosis without individual buffered PGOOD copies.
- Replaced slot topology with a host-owned logical-role/IP/MAC/serial inventory and made armed host supervision protocol-neutral.
- Required each active board to supervise one local `V_INTERLOCK_LOCAL` supply with a direct open-drain `OK` output that remains valid long enough to trip the fleet while shared system power remains available.
- Made `+12V` and the complete utility-rail set mandatory on every standard backplane and added explicit per-board, per-slot, aggregate, connector, and thermal power-budget responsibilities.
- Defined the power-supervision boundary: common rails are supervised once on the backplane, each active board supervises one local `V_INTERLOCK_LOCAL` supply, and further board monitoring targets only safety-relevant functions.
- Assigned one authoritative ADR to each architectural concept, added repository requirement-writing and controlled-vocabulary conventions, and refocused the README and concept guide on their distinct audiences.

## 2026-07-05 — Architectural simplification: ERROR.init merged into ERROR.run

- `ERROR.init` was a vacuous pass-through: its entry actions are automatic consequences of leaving RUN/IDLE. All fault transitions now target `ERROR.run` directly; the `ERROR.clear` failure path returns there.
- The ERROR family is now `ERROR.run` hold plus `ERROR.clear` recovery, with no behavioral change to fault entry, hold-down, or recovery boundaries.

## 2026-07-05 — Architectural simplification: RUN.disarm eliminated

- Disarm now transitions directly `Any RUN.* → IDLE`; residual cleanup is performed as IDLE-entry actions.
- `EN` is asserted exactly while `top_state == RUN`; the external `EN=0`/`OK=0` reset path still opens relays before FSM cleanup.

## 2026-07-05 — Architectural simplification: START.wait reduced to two gates

- Removed the separate OK first-rise gate. CLOCK qualification and OK stability are bounded by `T_start_deadline = 10 s`.
- `T_clear_max` is bounded by `T_start_deadline - T_start_stable`; START.wait timeout diagnostics use one deadline bit with optional `ok_seen_high` telemetry.
- A dead fleet is detected at 10 s instead of 5 s while remaining unarmed.

## 2026-07-05 — Architectural simplification: unified S1 supervision mechanism

- Armed host-supervision timeout S1 now sets a `fault_vector` bit and uses the standard trip/clear path; the separate supervision latch was removed.
- The FPGA `OK` driver has three internal sources: `local_trip_summary`, `boot_pulldown_active`, and `injected_fault`.

## 2026-07-05 — Gap closure: data path, trust model, and interface hardening

- Added ADR-006: image data uses each video board's Ethernet port; overrun is a data-quality event; host supervision remains effective during bulk-data transfer.
- Added the ADR-002 isolated-instrument-LAN trust model.
- Hardened ADR-003 `CLEAR`, synchronized-input, safe-bias, and START.wait diagnostic rules.
- Recorded the ADR-001 no-hot-swap stance and added planned-document tracking.

## 2026-07-05 — Specification altitude cleanup

- Clarified normativity and moved implementation examples, scenarios, and supporting diagrams toward reference/design scope.
- Centralized management-clock rules in ADR-004, fault behavior in ADR-001, utility synchronization in ADR-005, and FSM transitions in the ADR-003 reference.
- Reconciled armed Ethernet command rules, F1 clear semantics, trigger commands, ADR status, and watchdog diagnostic clearing.

## 2026-06-30 — Utility converter frequency, synchronization, and module filtering

- Fixed utility converters at nominal 2 MHz during acquisition and prohibited variable-frequency operating modes.
- Required five phase-configurable point-to-point LVDS synchronization outputs on main while leaving converter use and phase interleaving instrument-selectable.
- Required local filtering for noise-sensitive analog utility inputs and defined connector return-domain partitioning.

## 2026-06-23 — Backplane utility voltages

- Added ADR-005 common utility rails while retaining `+12V` for specialized local rails.
- Defined optional synchronized utility conversion, `local_sync_ready`, and separation between utility power, sequencer timing, and watchdog supply independence.
- Split long tables and diagrams into reference documents.
