# ADR-002: Board Identification and Configuration Strategy

**Status:** Resolved
**Last updated:** 2026-08-16

---

## Context

Every active board has its own Ethernet endpoint, but Ethernet cannot be the only recovery path for its own identity and bootstrap-network configuration. The host also needs to associate logical instrument roles with actual boards without depending on physical slot position.

> **Core decision:** Use an accessible UART service interface for persistent identity, bootstrap-network configuration, and recovery. Use Ethernet for volatile operation. The remote host owns the authoritative logical-role inventory.

Protocol framing, storage layout, port numbers, link rates, and exact commands belong to communication and board ICDs.

---

## Considered and Rejected

### Ethernet-only discovery and configuration

Rejected as the sole bootstrap mechanism because stale or invalid network settings could make a board unreachable through the channel needed to repair them. Discovery may still be provided as a commissioning convenience.

### Shared backplane I2C inventory bus

Rejected because the UART service path and host inventory already solve commissioning and recovery without adding another shared backplane bus and addressing scheme.

---

## Resolved Constraints

### R1: Every active board has an accessible UART service interface

The service interface supports:

- commissioning and replacement;
- permitted persistent-data reads and writes;
- fallback diagnostics when Ethernet is unavailable; and
- recovery when invalid bootstrap data prevents normal network startup.

The interface shall remain physically accessible for service. Connector type, electrical standard, framing, validation responses, request/response policy, common command catalog, and recovery-entry mechanism are ICD scope.

### R2: Persistent data is limited to identity, bootstrap, and factory information

Each active board shall make the following information available where applicable:

- unique MAC address;
- unique serial or board ID;
- board type and hardware revision;
- bootstrap IP information when static addressing is used; and
- required manufacturing calibration or trim data.

Normal bias, clock, timing, acquisition, enable-mask, and sequencer settings are operational data and are not persistent board configuration. Software version is reported by the active firmware image. Exact NVM technology, record format, field protection, redundancy, and atomic-update method belong to the board hardware and firmware specifications.

Interrupted service operations shall not make a partially written persistent record valid.

### R3: Persistent and operational channels remain separate

| Information | Normal channel | Persistence |
|---|---|---|
| Identity, bootstrap network, and factory data | UART service interface | Persistent |
| Operational parameters | Ethernet | Current boot session |
| Sequencer payload | ICD-defined reliable host transfer | Current boot session |
| Diagnostics | Ethernet normally; UART for service/recovery | Observation only |

Ethernet shall not modify persistent NVM. Operational writes are accepted only while the board is safely disarmed and shall be validated before application. Exact state allowlists, response messages, transaction behavior, and parameter catalogs belong to the communication and board ICDs.

Reset or power loss restores safe operational defaults and clears volatile sequencer readiness. Fault recovery and ordinary arm/disarm cycles do not by themselves erase valid current-session operational settings.

### R4: Board inventory is host-owned and independent of slot position

The host owns the authoritative mapping:

```text
logical role <-> board capability/revision <-> network endpoint <-> MAC/serial
```

At commissioning and startup, the host verifies that each expected endpoint reports the expected board identity and capability. Reachability alone is insufficient. Physical slot is not an authoritative runtime identity and need not be stored by the board.

When a board is replaced, its bootstrap settings are commissioned through the service interface and the host inventory is explicitly updated. An identification indicator or discovery protocol may assist service but does not replace the inventory.

The main board does not need function-board inventory to drive the shared electrical interfaces. It distributes the supported signals independently of slot occupancy.

### R5: Every active board has a dedicated Ethernet endpoint

Boards connect directly or through network switches to the trusted instrument network. The host communicates with each board; main does not proxy ordinary function-board control traffic, and function boards do not command one another.

Each board's link capacity shall support its maximum required control, telemetry, supervision, configuration, and acquisition traffic with verified margin. Minimum link rate, transport, framing, client/server roles, reconnect behavior, and port assignments belong to the applicable ICD. Video-board acquisition requirements are defined by ADR-006.

The network is assumed to be physically or logically isolated and its peers trusted. This is a deployment requirement. Instruments that cannot guarantee isolation shall add authentication or other compensating controls in their deployment and communication specifications. Message-integrity checks may be used independently of authentication.

### R6: Sequencer readiness is a pre-arm condition

Sequencer payloads are volatile and shall be transferred only while safely disarmed through an ICD-defined reliable host protocol. A sequencer board remains Not Ready until the host explicitly completes the loading transaction. Subsequent accepted sequencer modification returns it to Not Ready.

The readiness indication records completion of the host loading transaction; the architecture neither requires nor prohibits additional hashes, content validation, or attestation. A sequencer board that receives an unsafe arm attempt while Not Ready follows the ADR-003 interlock behavior.

Logical addressing, transfer segmentation, completion messages, execution length, and internal memory implementation belong to the sequencer and communication specifications.

### R7: Armed communication follows protocol-neutral supervision

While armed, each board uses the ADR-003 host-supervision rule. The qualifying interaction may be telemetry, an explicit heartbeat, data acknowledgement, credit, or another bidirectional protocol operation. Message choice, cadence, retry policy, response, and timeout are ICD-defined.

---

## Decision

Resolved. UART provides persistent commissioning and recovery; Ethernet provides volatile normal operation; the host owns logical-role inventory; slot position is not operational identity; and sequencer loading remains a volatile pre-arm activity. Exact protocols and storage implementation are delegated to ICD and design specifications.

---

## Consequences

- Manufacturing and service workflows require physical UART access to every active board.
- Host software is responsible for inventory verification and replacement-board commissioning records.
- Communication ICDs define link capacity, framing, transports, commands, validation behavior, and host-supervision interactions.
- Board designs may add integrity mechanisms without changing the architecture.
