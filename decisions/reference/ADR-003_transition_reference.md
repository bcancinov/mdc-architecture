# ADR-003 Reference: Example Transition Interpretation

**Status: Non-normative reference**

This file illustrates one detailed interpretation of [ADR-003](../ADR-003_state_machine_definition.md). It does not add architectural requirements. If it conflicts with ADR-003, the ADR controls. Exact timers, diagnostic fields, command names, and internal actions belong to firmware and communication specifications.

## Example transition table

| Current state | Example event or condition | Next state | Architectural result |
|---|---|---|---|
| Power-up | Local initialization begins | `START.boot` | Remain unarmed and establish safe defaults, identity, communications, and monitoring. |
| `START.boot` | Required local initialization completes | `START.wait` | Begin bounded timing and shared-health qualification. |
| `START.*` | Known local safety-relevant fault | `ERROR.run` | Assert the local trip and retain diagnostic evidence. |
| `START.wait` | Required timing evidence and stable `OK` are qualified | `IDLE` | Board is safely available for configuration and arming. |
| `START.wait` | Qualification cannot complete within the system-defined bound | `ERROR.run` | Remain safe and report qualification failure. |
| `IDLE` | Valid arm request on main; main readiness passes | `RUN.init` | Main asserts `EN`; function boards independently evaluate their readiness. |
| `IDLE` | Function board accepts `EN` rising and local readiness passes | `RUN.init` | Begin local arm preparation. |
| `IDLE` | Function board observes unsafe arm attempt | `ERROR.run` | Assert local `OK` contribution and remain safe. |
| `RUN.init` | Board-specific initialization completes | `RUN.wait` | Relay permissive may energize; await acquisition timing. |
| `RUN.wait` | Accepted acquisition `SYNC` rising event | `RUN.run` | Start timing-domain acquisition behavior. |
| `RUN.run` | Accepted acquisition `SYNC` falling event | `RUN.stop` | Stop acquisition gracefully. |
| `RUN.stop` | Board-specific stop work completes | `RUN.wait` | Remain armed for another acquisition event. |
| Any `RUN.*` | Disarm / `EN` falling | `IDLE` | Hardware permissive removes relay drive without waiting for FSM cleanup. |
| `IDLE` or `RUN.*` | Shared or local fault | `ERROR.run` | Safe-state hardware has priority over commanded operation. |
| `ERROR.run` | Explicit clear request | `ERROR.clear` | Re-evaluate live local conditions. |
| `ERROR.clear` | Local clear succeeds | `START.wait` | Release the local trip at the implementation's verified recovery boundary and requalify. |
| `ERROR.clear` | Fault remains or clear cannot complete | `ERROR.run` | Keep the local trip and diagnostic evidence. |

## Example command ownership

- Main consumes system coordination commands such as arm, disarm, clear, and acquisition trigger requests.
- Function boards respond to `EN`, `CLEAR`, `CLOCK`, and `SYNC` and expose their own configuration and diagnostic commands.
- Maintenance verification may command one selected board to assert its `OK` or watchdog path only while the system is safely disarmed or already latched safe.
- Operational writes and sequencer transfer occur only while safely disarmed.

Exact command strings, legal-state tables, acknowledgement behavior, and cleanup actions are communication/firmware specification material.

## Example fault-evidence behavior

A practical implementation commonly retains per-source diagnostic evidence and a separate local trip summary. During explicit recovery it rechecks live detectors before releasing its `OK` contribution. That organization is useful but not mandatory: another internal structure is compliant when it preserves the ADR-003 external behavior and diagnostic availability.
