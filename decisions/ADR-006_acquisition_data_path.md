# ADR-006: Acquisition Data Path

**Status:** Resolved
**Last updated:** 2026-07-05

---

## Context

Video function boards produce the science data of the system: digitized detector readout. Until this ADR, the only architectural mention of that data was the Gigabit Ethernet speed requirement in ADR-002 R7. The data path deserves an explicit decision because it interacts with two existing architectural rules:

1. **Main board scope (ADR-003 R1):** the main board is a coordinator, not a data concentrator.
2. **Armed keep_alive supervision (ADR-001 R10, ADR-003 R6):** while armed, every board trips the interlock if its host supervision lease expires. Bulk data transfer and supervision share infrastructure, so congestion must not be able to masquerade as loss of supervision.

This ADR intentionally pins only the cross-board contracts and safety interactions. Throughput numbers, transport protocol, framing, buffering technology, and flow control are ICD/design-package scope.

---

## Considered and Rejected

### Backplane data bus to the main board

Route acquisition data across the backplane to the main board, which forwards it to the host.

**Rejected because:** It turns the main board into a data concentrator and single choke point, contradicting the ADR-003 R1 scope rule (PLC gateway, no acquisition role). It also adds a high-speed parallel or serial bus to a backplane whose signal set is deliberately minimal and safety-oriented.

### Dedicated separate data link per video board

A second physical interface (additional Ethernet port, fiber, etc.) reserved for image data, keeping control traffic on the existing port.

**Rejected because:** Extra cabling, connectors, and PHYs per video board are not justified before a measured need exists. The shared-link risks (congestion vs. supervision) are addressed by the supervision-independence rule below. An instrument whose measured throughput exceeds the shared link may revisit this in its ICD/design package without changing the rest of the architecture.

---

## Decision

Acquisition data flows from each video function board directly to the remote host over that board's own Ethernet port — the same Gigabit port required by ADR-002 R7. There is no backplane data path, and the main board never carries science data.

### Constraints (normative)

1. **Supervision independence:** Bulk data transfer must not be able to starve `keep_alive` supervision. A board's supervision monitor must process valid `keep_alive` commands independently of bulk-data congestion, so that an S1 trip (ADR-001 R10) reflects actual loss of host supervision, not a busy link while the host is alive. Symmetrically, the host must maintain the `keep_alive` cadence during readout. The isolation mechanism (separate socket, priority handling, dedicated queue) is ICD/design scope.
2. **Overrun is a data-quality event, not a fault:** If the host or network cannot absorb readout data fast enough (buffer overrun, dropped frames, incomplete transfer), the board must not pull `OK` LOW and must not abort the acquisition. Detector safety and FSM behavior are unaffected. The board must flag the event in telemetry with enough information for the host to identify the affected data. This follows the core philosophy: data loss costs science quality; a trip costs observing time and must be reserved for safety-relevant conditions.
3. **Buffering is sized against the overrun policy:** Board-local buffering (depth, memory technology, full-frame vs. streaming) is an ICD/design decision, but it must be explicitly sized and verified against constraint 2 and the instrument's throughput requirements.
4. **Transport is ICD scope:** Protocol, framing, flow control, retransmission, and data-integrity checking (e.g., checksums per frame) are ICD-defined.

---

## Consequences

- Video-board ICDs must define the data transport protocol, buffering strategy, overrun telemetry, and the mechanism that isolates `keep_alive` processing from bulk-data congestion.
- Host software must sustain the `keep_alive` cadence to every armed board during readout, and must interpret overrun telemetry as a data-quality flag, not a system fault.
- The main board and backplane remain untouched by data-path scaling: adding faster or additional video boards changes only those boards and the host network.
- Instruments with throughput beyond a shared Gigabit link may introduce a dedicated data link in their ICD/design package; doing so does not alter the supervision-independence or overrun-policy rules.
