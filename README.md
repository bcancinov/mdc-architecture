# Modular Detector Controller — Architecture and Specifications

**Status:** Draft architecture. ADRs marked **Resolved** represent the current architectural decisions and remain subject to system-level review.

This repository contains the architecture, interface, design, and integration specifications for a modular detector controller.

For a non-specialist introduction to the complete system, start with the [system concept guide](integration/system_concept_guide.md). For revision history, see the [changelog](CHANGELOG.md).

## Repository map

```text
specifications/
├── README.md                  Repository entry point and writing conventions
├── CHANGELOG.md               Revision history
├── decisions/                 Architecture Decision Records (ADRs)
│   └── reference/             Detailed tables and supporting ADR diagrams
├── interfaces/                Interface Control Documents (planned)
├── design/                    Firmware and hardware design specifications (planned)
└── integration/               Concept guides and integration material
```

| Document type | Purpose | Typical content |
|---|---|---|
| ADR | Defines what must be true and why | Safety invariants, state behavior, clock ownership, power architecture |
| ICD | Defines what crosses a boundary | Pinouts, electrical limits, protocols, message fields, timing values |
| Firmware/Hardware Design Specification | Defines how a board satisfies the requirements | RTL structure, schematics, components, calculations |
| Concept/Integration Guide | Explains how the system works as a whole | Mental models, operating stories, examples, bring-up guidance |

Rule of thumb:

- Cross-board architectural constraints belong in an ADR.
- Exact external interfaces and project-specific values belong in an ICD.
- Internal implementation belongs in a design specification.
- Explanations for readers and operators belong in integration material.

References to planned ICDs, firmware appendices, and hardware design specifications are intentional forward references.

## Requirement-writing convention

The repository uses the following requirement vocabulary:

| Term | Meaning |
|---|---|
| `shall` / `must` | Mandatory requirement |
| `shall not` / `must not` | Prohibited behavior |
| `should` | Recommendation; deviation should be justified |
| `may` | Optional or explicitly permitted behavior |
| Present-tense description | Context, summary, rationale, or expected operation; not a new requirement by itself |

Additional rules:

1. Each normative concept has one authoritative document. Other documents summarize its consequence and link to that owner.
2. Safety and interface requirements use explicit normative language.
3. Diagrams, examples, rationale, and text labeled **Reference**, **Design guidance**, or **Non-normative** are illustrative unless explicitly declared normative.
4. Exact component choices, register names, and internal implementation techniques belong in design specifications unless cross-board compatibility or safety requires them architecturally.
5. ICD-defined values shall not be presented as unofficial fixed defaults in explanatory documents.
6. Exact signals, states, commands, constants, and rail names use code formatting, for example `OK`, `ERROR.run`, and `+12V_RAW`.

## Architectural ownership

| Concept | Authoritative document |
|---|---|
| Fault taxonomy and physical fault-detection mechanisms | [ADR-001](decisions/ADR-001_presence_health_detection.md) |
| Persistent configuration, identity, and host inventory | [ADR-002](decisions/ADR-002_backplane_configuration_identification.md) |
| FSM states, transitions, timers, and host-supervision behavior | [ADR-003](decisions/ADR-003_state_machine_definition.md) |
| `CLOCK`, `SYNC`, clock domains, and timing ownership | [ADR-004](decisions/ADR-004_clock_sync_distribution.md) |
| Mandatory common power rails, rail supervision, and power budgets | [ADR-005](decisions/ADR-005_backplane_utility_voltages.md) |
| Acquisition data transport and overrun interaction | [ADR-006](decisions/ADR-006_acquisition_data_path.md) |

The owner defines the mechanism. Other documents may repeat the resulting behavior when needed for context.

## Controlled vocabulary

| Preferred term | Meaning |
|---|---|
| Main board | Board that drives shared coordination signals such as `EN`, `CLEAR`, `CLOCK`, and `SYNC` |
| Function board | Active plug-in board performing detector-specific work, such as video, bias, or clock generation |
| Bridge board | Active board extending supported signals to another backplane |
| Passive terminator | Unpowered slot insert that maintains continuity-loop routing |
| Backplane board | Physical PCB carrying slots, shared signals, `+12V_RAW`, and common utility converters |
| Active board | Powered main, function, or bridge board participating in communication or safety logic |
| Utility rail | Mandatory common low-current rail generated on the backplane board |
| Qualified rail-health output | Open-drain backplane contribution to `OK`, provided by verified native PGOOD or a dedicated supervisor |
| `V_SAFE_AON` | Low-power local safety supply on each active board; not a backplane-distributed rail |
| Fault | Hardware or electrical condition requiring safe-state action |
| Supervisory interlock event | Non-hardware condition, such as armed host-supervision timeout, requiring the same safe response |
| Not Ready | Condition that blocks arming while disarmed but is not itself a fault |
| Trip | Action that asserts the interlock, normally by pulling `OK` LOW |
| Recovery | Explicit `ERROR.clear → START.wait → IDLE` process |
| Host inventory | Mapping of logical role to board type/revision, IP, MAC, and serial ID |
| Topology | Physical signal-distribution structure, such as an LVDS star or multi-backplane clock tree |

Use **board** when the main/function distinction is irrelevant. Reserve **module** for a complete removable mechanical assembly when that distinction matters.

## Formatting convention

- Markdown files use UTF-8 without a byte-order mark, one final newline, and no trailing whitespace.
- Use ATX headings (`#`, `##`, `###`) and blank lines around headings, lists, tables, and fenced blocks.
- Keep ordinary paragraphs as logical lines; do not hard-wrap tables or links to an arbitrary column limit.
- Use relative links for repository documents.
- Use the controlled vocabulary consistently in prose and diagrams.
