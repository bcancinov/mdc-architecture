# Historical Changelog

This file contains repository changes before the latest summary in `README.md`.

## 2026-09-09 — Standalone fault descriptions

- Described watchdog timeout and acquisition-clock loss as separate failures, removing comparisons with the earlier design from the ADRs, guide, and handbook.
- Retained optional refresh alignment as a noise-control choice.

## 2026-09-08 — Separate watchdog and clock-loss protection

- Removed acquisition-clock activity as a requirement for watchdog refresh; watchdogs monitor processor/control-logic execution and clock monitors separately detect acquisition-clock loss.
- Allowed optional refresh alignment for noise control, with local-clock fallback and an independent watchdog timeout time base.
- Aligned fault classification, ADR-004, reference diagrams, the concept guide, handbook explanations, and fault scenarios.

## 2026-09-08 — Handbook references

- Removed the Skipper CCD collaboration mandate from the handbook bibliography.

## 2026-09-08 — Watchdog timing and operating scope

- Rewrote Section 7.5 as connected prose explaining clock-dependent refreshes, the independent watchdog timeout, fault examples, and diagnostic limits.
- Explained disarmed watchdog protection and continuous distributed clocking, distinct from armed-only host supervision; aligned the concept guide.

## 2026-09-08 — Simplified timing-fault explanation

- Shortened Section 7.5 to two checks, their shared safe response, and a plain-language diagnostic table; aligned the concept guide.

## 2026-09-08 — Clock-loss and watchdog explanation

- Explained clock-activity monitoring, watchdog petting, independent trip paths, and retained evidence with clock-cable and frozen-processing examples.
- Clarified why watchdog-only evidence does not uniquely identify frozen logic; aligned the concept guide without changing architectural requirements.

## 2026-09-08 — Timing explanation and scenario alignment

- Combined management-clock independence and asynchronous acquisition-event observation into one explanation with a concrete SYNC example.
- Aligned operating scenarios with retained-configuration verification, disarmed host loss, frozen-host rationale, telemetry supervision, optional input eFuse trips, and active LOOP safety-hardware reporting.
- Clarified that clock-loss detection may use independent management or safety clocking; kept the concept guide aligned.

## 2026-09-08 — Armed host supervision rationale

- Retained supervision on every armed active board: continued operation with an unavailable or unresponsive host is not assumed safe.
- Clarified that bidirectional telemetry may qualify and disarmed host disconnection alone does not assert `OK`.
- Clarified pre-arm verification of configuration and readiness, including retained settings from another host, without mandating session handover or reload mechanisms.
- Aligned ADRs, the concept guide, and handbook explanations.

## 2026-09-08 — Optional board input eFuses

- Clarified in ADR-005, the concept guide, and handbook Section 4.2.1 that main and function boards may use input eFuses on protected +12 V or consumed analog rails, with suitable voltage and polarity ratings.

## 2026-09-08 — Shared +12 V conducted disturbances

- Extended function-board power-entry conditioning to every consumed shared rail, including protected +12 V.
- Included digital loads and local converters in returned-emission and load-disturbance requirements because other boards may derive analog supplies from +12 V.
- Aligned ADR-005, the concept guide, and handbook Section 4.2.2; limits remain ICD scope and topology remains board-design scope.

## 2026-09-08 — Detector interface terminology

- Used detector interface for connectors and electronics, and detector protection relay for the protective relay.
- Retained detector-facing for broader output and permission descriptions; no architectural behavior changed.

## 2026-09-08 — Direct local response to LOOP LOW

- Allowed active function boards to remove local detector-facing permission directly on incoming LOOP LOW; main still asserts `OK` to trip the entire powered fleet.
- Allowed active LOOP reporting of detected safety-hardware problems without claiming coverage of every internal device failure.
- Kept forwarding independent of `OK`, `EN`, and state so the safe response does not prevent loop recovery.
- Aligned the ADRs, concept guide, and version 0.2 handbook.

## 2026-09-08 — Passive and active continuity options

- Allowed passive copper and unconditional active forwarding in a common continuity chain; empty-slot terminators remain passive.
- Allowed qualified active forwarding to report F6 through main; passive boards retain a separate hardware F6 path, and main's own power-loss response remains independent of failed main logic.
- Assigned loop voltage, thresholds, pull-downs, power-state behavior, loading, and propagation limits to the backplane ICD.
- Aligned the concept guide, handbook, diagrams, and shared-signal reference; retained version 0.2.

## 2026-09-08 — Interlock-power-loss implementation flexibility

- Made a dedicated local interlock-supply supervisor optional while retaining F6 reporting to the powered fleet.
- Required detector-facing relay permission and drive to drop on interlock-supply loss, including when relay-driver power remains available.
- Aligned the ADRs, concept guide, handbook, and diagrams; supervisor and hold-up circuitry remain implementation examples.

## 2026-09-08 — Concept guide and board example

- Aligned the system concept guide with version 0.2 and identified it as the handbook's maintained explanatory content source; ADRs remain authoritative.
- Added a conceptual video function-board diagram and explanation covering connectors, local power, processing, independent safety, and detector-specific electronics.
- Documented the named PDF build, source-maintenance workflow, non-visual checks, and writable LuaLaTeX cache troubleshooting.

## 2026-09-07 — Handbook version 0.2

- Updated derived LaTeX chapters and generated ADR reference tables to reflect the revised safety, power, timing, diagnostics, and data-capacity decisions.
- Added safety-implementation comparison and maintenance-test timing figures; revised power and timing-domain diagrams.
- Added a cumulative publication change record with a fixed revision date, separate from the PDF generation date.
- Made the non-visual build checker read the expected version from publication metadata.
- Simplified repeated explanations, clarified stop/disarm/trip and distributed readiness, and grouped power, safety, and communication topics for readability.
- Visual review of the diagrams is reserved for the user.

## 2026-09-07 — Safety implementation options and application flexibility

- Permitted a dedicated safety CPLD, including the independent watchdog function, while preserving independent timeout operation, interlock-supply supervision, and safe failure behavior.
- Made watchdog diagnostics evidence-based and required an observable HIGH-to-LOW transition for conclusive `OK` maintenance verification; retained procedural details in reference material.
- Retained mandatory fixed-pin backplane analog rails while permitting optional board consumption and local conversion from protected `+12V` as normal design choices.
- Clarified application ownership of Ethernet capacity and ADC sampling rate and its relationship to sequencer timing.
- Aligned the supporting fault/transition references, concept guide, and older architecture overview with the revised ADRs.

## 2026-08-16 — Remove unused shared digital auxiliary rail

- Removed `+3.3V_DIG_AUX` from the mandatory backplane utility rails because the architecture has no concrete common load that justifies a separate distributed low-voltage digital supply.
- Required ordinary digital supplies, including low-power identification and monitoring supplies, to be generated locally from protected `+12V`.
- Retained the five utility-converter synchronization outputs as a separate standard interface capability; they represent switching channels and are not assigned one-to-one to the four analog utility rails.

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
