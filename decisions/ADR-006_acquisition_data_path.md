# ADR-006: Acquisition Data Path

**Status:** Resolved
**Last updated:** 2026-08-14

---

## Context

Video function boards produce the science data of the system: digitized detector readout. Until this ADR, the only architectural mention of that data was the Gigabit Ethernet speed requirement in ADR-002 R7. The data path deserves an explicit decision because it interacts with two existing architectural rules:

1. **Main board scope (ADR-003 R1):** the main board is a coordinator, not a data concentrator.
2. **Armed host supervision (ADR-001 R10, ADR-003 R6):** while armed, every board trips the interlock if its host-supervision timer expires. The acquisition protocol may itself provide the qualifying host interactions, so this ADR must not prematurely mandate a separate heartbeat mechanism.

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

1. **Host supervision during acquisition:** The ICD shall define which valid host interaction refreshes the board's supervision timer during acquisition. It may be a telemetry request, explicit heartbeat, or an application-level data acknowledgement/credit. The board shall return an ICD-defined response so the host can verify the reverse path. Outbound image or telemetry traffic alone does not prove that the host is present. The implementation must be verified at maximum supported data load so qualifying host interactions are not indefinitely delayed by local scheduling or queueing.
2. **Overrun is a data-quality event, not by itself a fault:** If the host or network cannot absorb readout data fast enough (buffer overrun, dropped frames, incomplete transfer), the board does not pull `OK` LOW solely because of that overrun and reports enough telemetry for the host to identify the affected data. If no qualifying host interaction is completed before `T_host_supervision_max`, however, the independent S1 timeout still trips the system. The transport's behavior after an overrun is ICD-defined and must preserve detector safety.
3. **Buffering is sized against the overrun policy:** Board-local buffering (depth, memory technology, full-frame vs. streaming) is an ICD/design decision, but it must be explicitly sized and verified against constraint 2 and the instrument's throughput requirements.
4. **Transport is ICD scope:** Protocol, framing, flow control, retransmission, and data-integrity checking (e.g., checksums per frame) are ICD-defined.

---

## Consequences

- Video-board ICDs must define the data transport protocol, buffering strategy, overrun telemetry, and the host interaction that qualifies for supervision refresh during acquisition.
- Host software must complete the qualifying supervision interaction with every armed board within the defined timeout and interpret overrun telemetry as a data-quality flag rather than, by itself, a system fault.
- The main board and backplane remain untouched by data-path scaling: adding faster or additional video boards changes only those boards and the host network.
- Instruments with throughput beyond a shared Gigabit link may introduce a dedicated data link in their ICD/design package; doing so does not alter the host-supervision or overrun-policy rules.
