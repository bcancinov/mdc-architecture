# Modular Detector Controller — Architecture & Specifications

**Status:** Draft / Pending Initial Team Review (April 2026). Individual ADRs marked *Resolved* are settled by the authors but remain subject to this initial team review.

This repository contains the evolving architecture specifications, ADRs, and ICD content for the modular detector controller.

To avoid documentation drift, **this README is a primer and map**, not the normative source. It explains the system intent and design philosophy.

## Changelog

### 2026-07-05 — Architectural simplification: ERROR.init merged into ERROR.run

- `ERROR.init` was a vacuous pass-through: its "entry actions" (`EN` drop, `relay_drive` de-assert, external relay RESET, latches held) are all automatic Moore consequences of leaving RUN/IDLE, not sequenced work. All fault transitions now target `ERROR.run` directly; the `ERROR.clear` failure path returns to `ERROR.run`.
- The ERROR family is now two states (`ERROR.run` hold, `ERROR.clear` recovery); the FSM is 9 states total.
- No behavioral change: entry conditions, OK hold-down, late-arriving-fault handling, and recovery boundaries are unchanged.

### 2026-07-05 — Architectural simplification: RUN.disarm eliminated

- Disarm now transitions directly `Any RUN.* → IDLE` (disarm command on main, `EN` falling on function boards). Residual cleanup (bleeding integrators, zeroing counters) is performed as IDLE-entry actions; the sequencer-hash token already cleared on IDLE entry.
- `EN` is now simply "asserted iff `top_state == RUN`" — the RUN.disarm carve-out is gone. `relay_drive` remains asserted only in RUN.wait/run/stop.
- No safety change: relay cutoff was never provided by this state — the external `EN=0`/`OK=0` hardware reset path opens relays before any FSM transition. FSM is now 10 states.

### 2026-07-05 — Architectural simplification: START.wait reduced to two gates

- Removed gate 2 (`T_ok_rise_max`, OK first-rise) from `START.wait`. A fleet whose `OK` never rises is caught by the absolute deadline, since the stability window can never complete. START.wait now has two gates: CLOCK qualification (`T_clock_present_max`) and OK stability (`T_start_stable`), both bounded by the new explicit constant `T_start_deadline` (10 s, replacing the derived `T_ok_rise_max + T_start_stable`).
- `T_clear_max` is now bounded by its real physical constraint: `T_clear_max <= T_start_deadline - T_start_stable` (numerically unchanged).
- The two START.wait timeout diagnostic bits merged into one START.wait-deadline bit; an optional `ok_seen_high` telemetry flag (ICD option) can distinguish "never rose" from "never stabilized".
- Behavior change: a dead fleet is detected at 10 s instead of 5 s — unarmed, so no safety impact. Nominal boot/recovery timing is unchanged.

### 2026-07-05 — Architectural simplification: unified S1 supervision mechanism

- Removed `latched_supervision_fault` as a separate latch and OK-driver source. The armed keep_alive timeout (S1) now sets a dedicated bit in `fault_vector` and follows the standard fault-path, trip, and clear semantics (ADR-003 R6) — the same mechanism as every other fault source, including the existing procedural EN-rise interlock-violation bit.
- The FPGA `OK` driver now has exactly three internal sources: `local_trip_summary`, `boot_pulldown_active`, `injected_fault`.
- ADR-001 R10 keeps the S1 taxonomy (host-communication loss, active only while armed) but diagnosis is now uniform: the host reads `fault_vector` in `ERROR.run`; the separate S1 truth table was removed.
- No change to trip latency, `OK` hold-down behavior, or recovery boundaries.

### 2026-07-05 — Gap closure: data path, trust model, and interface hardening

- Added ADR-006 (Acquisition Data Path): image data flows over each video board's own Ethernet port; buffer overrun is a data-quality event that never trips `OK`; `keep_alive` supervision must be isolated from bulk-data congestion; buffering/transport details are ICD scope.
- ADR-002: added the security and trust model — isolated instrument LAN assumed, no per-command authentication by design, network isolation is a hard deployment requirement.
- ADR-003 R3: `CLEAR` edges are now explicitly ignored outside `ERROR.run`; all shared backplane FSM inputs must be synchronized into the management clock domain; the backplane must bias `EN`/`CLEAR` to safe LOW when undriven.
- ADR-003 R7: START.wait OK-rise and stability timeouts now set dedicated `fault_vector` diagnostic bits so timed-out boards are distinguishable from boards dragged into ERROR.
- ADR-001 R8: recorded the hot-swap stance — live insertion/removal is not supported; board replacement happens in ERROR or powered down.
- README: added the planned-documents list (Firmware Reference Appendix, Hardware Design Spec, System Integration Guide, ICDs) as the tracking point for forward references; removed the never-defined `pull_ok_low` signal from ADR-003.

### 2026-07-05 — Specification altitude cleanup (reduce over-specification)

- Added the normativity convention: only must/shall statements bind; code, scenarios, and *Reference*/*rationale* material are illustrative.
- ADR-003: state-register encoding and `EN`/`relay_drive` HDL demoted to non-normative reference (atomic-state-update invariant and output behavior remain binding); START.wait scenarios/rationales marked illustrative; early-abort prohibition relaxed to a recommendation.
- ADR-001/ADR-004: cascaded watchdog pet demoted to reference pattern; the binding rule is two-domain pet liveness. Certified-component mandate for the OK driver relaxed to a quantified-reliability requirement.
- ADR-004 R3: IOB re-timing demoted to reference technique; the binding rule is the 5 ps RMS CNV-to-CLOCK jitter budget.
- ADR-005: filter engineering checklist reduced to design-specification scope; local-filter placement and attenuation requirements remain binding.
- Deduplicated normative content: management-clock rules owned by ADR-004 R5 (ADR-003 R2 now references them); fault detection/propagation/latency defined once in the ADR-001 summary table (R4 duplicate removed); sequencer hash attestation owned by ADR-002 R9 (ADR-003 keeps only the token lifecycle); utility-sync capability phrasing centralized in ADR-005; README macro state diagram replaced by a pointer to ADR-003.
- Fixed contradictions: Ethernet-layer rule now permits control/supervision commands (`keep_alive`, `disarm`, trigger requests) while armed, prohibiting only configuration writes; F1 loop-break clear semantics aligned with ADR-003 R6 (prime-on-entry, level-sensitive re-set); acquisition trigger start/stop requests added to the main-only command set (naming ICD-defined); README status note reconciled with per-ADR *Resolved* status.
- Diagnostic fix: `WD_latch` now also clears at the `START.wait → IDLE` qualification-success boundary, so watchdog trips that legitimately occur during fleet power-up (before distributed `CLOCK` is available) no longer persist into IDLE/RUN diagnostics and cannot be misclassified later as F2b.

### 2026-06-30 — Utility converter frequency, synchronization, and module filtering

- Fixed backplane utility converters at a nominal 2 MHz continuous switching frequency during acquisition and prohibited burst, pulse-skipping, foldback, and spread-spectrum modes during acquisition.
- Required the main board and its connector to provide five independent, phase-configurable, point-to-point LVDS utility-converter sync outputs; converter use and phase interleaving remain instrument options.
- Required noise-sensitive modules to filter analog utility rails locally immediately after the backplane connector and before low-noise regulation.
- Defined analog/digital connector zoning and intentional return allocation without mandating separate physical connector bodies.

### 2026-06-23 — Backplane utility voltages

- Added ADR-005 to define common backplane utility voltages: `+3.3V_DIG`, `+6V_ANA`, `-6V_ANA`, `+16V_ANA`, and `-16V_ANA`.
- Kept `+12V_RAW` distributed to modular boards for specialized local rails such as detector high voltages.
- Defined utility-voltage DC-DC synchronization as preferred but optional, with the main board acting as the sync authority when implemented (superseded by the mandatory interface capability defined on 2026-06-30).
- Updated ADR-001, ADR-003, and ADR-004 to separate utility-power distribution from sequencer timing, board-local special converters, and safety watchdog/fail-safe supply independence.
- Renamed the pre-arm synchronization readiness flag to `local_sync_ready` so it is not tied only to DC-DC converter synchronization.
- Split long transition tables, topology examples, and supporting diagrams into `decisions/reference/` to make the ADRs easier to peer review.
- Updated the architecture summary presentation and diagrams to show utility voltages as common backplane resources.

### Document Boundaries & Repository Map

```
specifications/
├── README.md                  ← This file (primer and map)
├── decisions/                 ← ADRs: architectural constraints and rationale
│   └── reference/             ← Long normative/reference tables and diagrams split out of ADRs
├── interfaces/                ← ICDs: protocols, message formats, electrical details  [planned]
├── design/                    ← Firmware and hardware design specs                    [planned]
└── integration/               ← Concept guide, system integration guide, worked examples
```

| Folder / Document Type | Purpose (What lives here) | Examples | When to look here |
|---|---|---|---|
| **`decisions/`** <br><br> **ADR** (Architecture Decision Record) | *What must be true and why.* <br><br>Architectural constraints, invariants, rationale, and rejected alternatives. Long tables/diagrams may live in `decisions/reference/` to keep ADRs reviewable. | Fault taxonomy, FSM states and transition guards, timing constants, safety-path rules (four OK sources, registered outputs), relay stage normative requirements. | When you need to know a system rule, understand why a design choice was made, or verify whether a proposed change violates an architectural constraint. |
| **`interfaces/`** <br><br> **ICD** (Interface Control Document) | *What crosses a boundary.* <br><br>Protocols, message formats, electrical interface details, and host-side orchestration sequences. | Ethernet command schemas, keep_alive format/cadence, UART command set, F4 verification host-side sequence, sequencer payload framing, backplane pinout/voltage levels. | When you are implementing host software, writing board firmware that handles external commands, or designing a backplane connector. |
| **`design/`** <br><br> **FDS / HDS** (Firmware & Hardware Design Specs) | *How internal implementation satisfies the ADR constraints.* <br><br>Reference code, pseudocode, schematics, and component selections. | START.wait qualification loop, ERROR.clear evaluator, FSM integration modules, D flip-flop relay stage wiring, wired-AND RESET_n generator, fail-safe buffer circuits. | When you are writing FPGA RTL, laying out a board schematic, or selecting components for a specific function board. |
| **`integration/`** <br><br> **Concept Guide / System Integration Guide** | *How the system behaves as a whole during operation.* <br><br>Reader-friendly concept explanations, worked examples, fault lifecycle walkthroughs, onboarding tutorials. | `system_concept_guide.md`, fault-trip and ERROR.clear recovery lifecycle narrative, multi-board power-up sequencing example. | Start here when the ADRs are too dense, when bringing up a new system, training a new team member, or debugging a cross-board interaction. |

**Rule of thumb:** If it says *"the board must..."* or *"this is prohibited because..."*, it belongs in an ADR in `decisions/`. If it says *"send command X, wait Y ms, read pin Z"*, it belongs in an ICD in `interfaces/`. If it says *"wire D=VCC, CLK=relay_drive"* or *"always @(posedge clk) begin..."*, it belongs in a design spec in `design/`.

**Planned documents (forward references):** ADRs refer to several documents that do not exist yet: the **Firmware Reference Appendix** and **Hardware Design Specification** (future `design/`), the **System Integration Guide** (future `integration/`), and the system/board **ICDs** (future `interfaces/`). Treat these mentions as forward references — the ADR text defines *what* those documents must cover, and this list is the tracking point until they are written.

**Normativity convention:** In ADRs, only *must / shall / prohibited / required* statements are binding. Code blocks, diagrams, worked scenarios, and anything labeled *Reference*, *Design rationale*, or *non-normative* are illustrative — they show one way to satisfy a rule, not the rule itself. Designers may deviate from illustrative material freely as long as every binding statement holds. ADRs should bind cross-board contracts and safety invariants; board-internal implementation choices belong to design specs.

**Recommended reading path for new readers:** Start with [`integration/system_concept_guide.md`](integration/system_concept_guide.md), then use this README as the map into the ADRs and future ICD/design documents.

---

## 1. Architecture Primer

### The Physical Layout
The system is a multi-board, backplane-based controller divided into two distinct roles:
* **The Main Board:** Acts as a PLC gateway and system coordinator. It distributes the master `CLOCK` and `SYNC`, manages the continuity loop, and drives the global `EN` (arm) and `CLEAR` (recovery) signals. *Crucially, the main board has no sequencer and does not run scientific acquisitions itself.*
* **The Function Boards:** (Video, Bias, Clock, etc.) These boards execute the actual sequencer logic, drive detector pins, and sample the ADCs. 

The backplane also distributes common utility voltages (`+3.3V_DIG`, `+/-6V_ANA`, `+/-16V_ANA`) so most modular boards do not duplicate the same local DC-DC converters. `+12V_RAW` remains available for boards that need specialized local rails such as high detector voltages. Utility converters operate at a nominal fixed 2 MHz during acquisition. The main board provides utility-converter synchronization capability per ADR-005; instruments may choose whether to use synchronization and phase interleaving. Noise-sensitive function boards locally filter analog utility rails immediately after the connector and before low-noise regulation (ADR-005).

### Core Design Philosophy
> **"Go to safe state fast. Go to not-safe state slow."**

The architecture is intentionally safety-biased: a false trip costs observing time, but a false arm can damage hardware. We enforce this with two layers:
1.  **Hardware Interlock Layer (Sub-microsecond):** Deterministic hardware mechanisms. If a fault occurs, an open-drain `OK` bus drops, and hardware latches instantly sever relay power independent of software or FPGA clock state. 
2.  **Ethernet Telemetry Layer (Diagnostic):** Slower, software-driven diagnostics. Used to configure the system in `IDLE`, identify the root cause of a fault while safely deadlocked in `ERROR`, and orchestrate recovery.

### The Macro State Flow
The entire architecture is governed by a single hierarchical flow: `START.boot → START.wait → IDLE ⇄ RUN`, with any fault dropping to `ERROR` and recovery always returning through `ERROR.clear → START.wait`. `START.wait` is the required stability gate for entering `IDLE` during both boot and fault recovery, while local internal faults can still abort directly to `ERROR.run`.

The authoritative state diagram and transition rules live in [ADR-003](decisions/ADR-003_state_machine_definition.md) (R4, R7, R8); a reader-friendly walkthrough is in the [concept guide](integration/system_concept_guide.md). The diagram is intentionally not duplicated here.
