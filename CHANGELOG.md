# Historical Changelog

This file contains repository changes before the latest summary in `README.md`.

## 2026-08-14 — Timing, supervision, power, and identity refinement

- Renamed the shared digital utility rail to `+3.3V_DIG_AUX` and limited it to low-power auxiliary digital loads.
- Required processors, FPGAs, memory, and other high-current digital loads to use board-local conversion from `+12V_RAW`, avoiding excessive connector current and conducted-noise coupling through a shared 3.3 V rail.
- Defined acquisition `SYNC` capture in the 100 MHz timing domain with a separate CDC-safe management observation; management/processor clocks remain independent and acquisition never resumes automatically after clock loss.
- Removed universal jitter and fault-latency numbers in favor of application timing verification and hardware interlock propagation without intentional software delay.
- Connected compatible backplane utility-converter PGOOD outputs directly to `OK`; main-board analog rail measurements provide diagnosis without individual buffered PGOOD copies.
- Replaced slot topology with a host-owned logical-role/IP/MAC/serial inventory and made armed host supervision protocol-neutral.
- Required each active board to supervise one local `V_SAFE_AON` with a direct open-drain `OK` output and isolated hold-up energy.
- Made `+12V_RAW` and the complete utility-rail set mandatory on every standard backplane and added explicit per-board, per-slot, aggregate, connector, and thermal power-budget responsibilities.
- Defined the power-supervision boundary: common rails are supervised once on the backplane, each active board supervises one local `V_SAFE_AON`, and further board monitoring targets only safety-relevant functions.
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

- Added ADR-005 common utility rails while retaining `+12V_RAW` for specialized local rails.
- Defined optional synchronized utility conversion, `local_sync_ready`, and separation between utility power, sequencer timing, and watchdog supply independence.
- Split long tables and diagrams into reference documents.
