# Modular Detector Controller — Architecture & Specifications

**Status:** Draft / Pending Initial Team Review (April 2026). Individual ADRs marked *Resolved* are settled by the authors but remain subject to this initial team review.

This repository contains the evolving architecture specifications, ADRs, and ICD content for the modular detector controller.

To avoid documentation drift, **this README is a primer and map**, not the normative source. It explains the system intent and design philosophy.

## Changelog

### 2026-08-14 — Timing, supervision, and power-fault simplification

- Kept management clocks independent from the 100 MHz sequencer domain; acquisition `SYNC` is captured in the timing domain and observed separately through CDC for management.
- Replaced universal jitter/latency claims and a mandatory heartbeat command with design-verified timing margins and protocol-neutral host supervision.
- Added direct compatible utility-converter PGOOD connections to `OK`, main-board analog rail diagnostics, identity-based host inventory, and last-gasp monitoring of each board's safety-support supply.

### 2026-07-17 — Host-owned operational configuration

- Limited NVM to persistent identity, bootstrap-network, and necessary factory data; only UART may write it under the explicit state allowlist.
- Made Ethernet operational configuration and TCP sequencer loading volatile and `IDLE`-only, with local safety/readiness checks before arm.
- Removed persistent sequencers and sequencer hash attestation; transfer details remain ICD scope.

[Older changes](CHANGELOG.md)

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
| **`decisions/`** <br><br> **ADR** (Architecture Decision Record) | *What must be true and why.* <br><br>Architectural constraints, invariants, rationale, and rejected alternatives. Long tables/diagrams may live in `decisions/reference/` to keep ADRs reviewable. | Fault taxonomy, FSM states and transition guards, timing constants, safety-path and relay-stage requirements. | When you need to know a system rule, understand why a design choice was made, or verify whether a proposed change violates an architectural constraint. |
| **`interfaces/`** <br><br> **ICD** (Interface Control Document) | *What crosses a boundary.* <br><br>Protocols, message formats, electrical interface details, and host-side orchestration sequences. | Ethernet command schemas, host-supervision interactions/cadence, UART command set, F4 verification host-side sequence, sequencer payload framing, backplane pinout/voltage levels. | When you are implementing host software, writing board firmware that handles external commands, or designing a backplane connector. |
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

The backplane also generates and distributes common utility voltages (`+3.3V_DIG_AUX`, `+/-6V_ANA`, `+/-16V_ANA`) so modular boards do not duplicate converters for modest shared loads. `+3.3V_DIG_AUX` is limited to low-power auxiliary digital functions; processors, FPGAs, memory, and other high-current digital loads use board-local conversion from `+12V_RAW`. Compatible utility-converter PGOOD outputs wire directly into `OK` for hardware protection, while the main board measures rail voltages and optional currents for diagnosis. `+12V_RAW` also supplies specialized local rails and each board's monitored safety-support supply. Utility converters operate at a nominal fixed 2 MHz during acquisition. The main board provides utility-converter synchronization capability per ADR-005; instruments may choose whether to use synchronization and phase interleaving. Noise-sensitive function boards locally filter analog utility rails immediately after the connector and before low-noise regulation (ADR-005).

### Core Design Philosophy
> **"Go to safe state fast. Go to not-safe state slow."**

The architecture is intentionally safety-biased: a false trip costs observing time, but a false arm can damage hardware. We enforce this with two layers:
1.  **Hardware Interlock Layer:** Deterministic hardware mechanisms. A detected safety fault pulls the open-drain `OK` bus LOW, and reset-dominant hardware removes relay-coil drive without intentional software delay or dependence on continued FPGA clock operation. Exact response budgets are verified in the safety analysis and board designs.
2.  **Ethernet Management Layer:** Slower, software-driven configuration, control, and diagnostics. Used to configure the system in `IDLE`, identify fault causes in `ERROR`, and orchestrate recovery.

### The Macro State Flow
The entire architecture is governed by a single hierarchical flow: `START.boot → START.wait → IDLE ⇄ RUN`, with any fault dropping to `ERROR` and recovery always returning through `ERROR.clear → START.wait`. `START.wait` is the required stability gate for entering `IDLE` during both boot and fault recovery, while local internal faults can still abort directly to `ERROR.run`.

The authoritative state diagram and transition rules live in [ADR-003](decisions/ADR-003_state_machine_definition.md) (R4, R7, R8); a reader-friendly walkthrough is in the [concept guide](integration/system_concept_guide.md). The diagram is intentionally not duplicated here.
