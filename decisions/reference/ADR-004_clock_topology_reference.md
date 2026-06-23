# ADR-004 Reference: Multi-Backplane Clock/SYNC Topologies

This reference supports `../ADR-004_clock_sync_distribution.md`.

ADR-004 is the peer-review entry point for the 100 MHz point-to-point LVDS timing decision. This file holds multi-backplane topology examples and implementation notes that are useful during ICD/design work.

## Topology options

For multi-backplane systems, choose topology per instrument scale and physical layout. ADR-004 intentionally leaves topology open and does not mandate one pattern.

| Topology | Description | Suitable for |
|---|---|---|
| Hierarchical (tiered) star | Main distributes trunk lines to secondary fanout buffers in each sub-chassis | Large fixed instruments, best jitter |
| Daisy-chain repeater | The main board resides on the first (primary) backplane and extends CLOCK/SYNC over cable to downstream backplanes. The repeater/bridge role is implemented on each extended backplane (for example, a bridge function board or a downstream main board). See daisy-chain implementation rules below for buffer vs. ZDM constraints. | Moderate scale, limited hop count |
| Hybrid | Tiered distribution to primary chassis, short daisy-chain hops within localized clusters | Very large instruments (50+ boards) |

## Daisy-chain repeater implementation rules

When implementing the bridge role on an extended backplane, engineers must choose between two options:

**(a) Buffer-only:** Both `CLOCK` and `SYNC` pass through matched low-skew LVDS buffers. Both accumulate similar propagation delays per hop, maintaining the relative 180° phase, but `CLOCK` jitter accumulates per hop.

**(b) ZDM regeneration:** `CLOCK` is a continuous periodic signal and is regenerated via a jitter cleaner in Zero Delay Mode (ZDM). `SYNC` consists of aperiodic pulses and cannot be ZDM regenerated; it must pass through a low-skew LVDS fanout buffer.

**Hop-count constraint:** Because ZDM eliminates `CLOCK` delay but `SYNC` accumulates buffer propagation delay per hop, the 180° phase margin degrades linearly with each backplane added. This imposes a strict physical limit on the maximum number of daisy-chained backplanes. The maximum hop count must be mathematically validated against the 100 MHz setup/hold margins.

## Topology diagrams

**Hierarchical (tiered) star:**

```mermaid
graph TD
    M["Main Board\nCLOCK + SYNC source"]

    M -- "trunk LVDS" --> FO1["Fanout Buffer\n(sub-chassis 1)"]
    M -- "trunk LVDS" --> FO2["Fanout Buffer\n(sub-chassis 2)"]

    FO1 -- "p2p" --> S1F1["Slot 1"]
    FO1 -- "p2p" --> S1F2["Slot 2"]
    FO1 -- "p2p" --> S1FN["Slot N"]

    FO2 -- "p2p" --> S2F1["Slot 1"]
    FO2 -- "p2p" --> S2F2["Slot 2"]
    FO2 -- "p2p" --> S2FN["Slot N"]
```

**Daisy-chain repeater:**

```mermaid
graph LR
    subgraph BP1["Backplane 1 (primary)"]
        M["Main Board\nCLOCK + SYNC source"]
        S1["Slots (local star)"]
        M --> S1
    end

    subgraph BP2["Backplane 2 (extended)"]
        BR2["Bridge role in BP2\n(buffer or ZDM)\n(function board or downstream main board)"]
        S2["Slots (local star)"]
        BR2 --> S2
    end

    subgraph BP3["Backplane 3 (extended)"]
        BR3["Bridge role in BP3\n(buffer or ZDM)\n(function board or downstream main board)"]
        S3["Slots (local star)"]
        BR3 --> S3
    end

    M -- "cable CLOCK + SYNC" --> BR2
    BR2 -- "cable CLOCK + SYNC" --> BR3
```

*ZDM constraint:* CLOCK jitter is cleaned at each hop, but SYNC delay accumulates. The 180° phase margin between CLOCK and SYNC degrades per hop, limiting the maximum chain length.

**Hybrid:**

```mermaid
graph TD
    M["Main Board\nCLOCK + SYNC source"]

    M -- "trunk" --> FO1["Fanout Buffer\n(cluster A)"]
    M -- "trunk" --> FO2["Fanout Buffer\n(cluster B)"]

    FO1 --> BPA1["Backplane A1\n(local star)"]
    BPA1 -- "short hop" --> BPA2["Backplane A2\n(local star)"]

    FO2 --> BPB1["Backplane B1\n(local star)"]
    BPB1 -- "short hop" --> BPB2["Backplane B2\n(local star)"]
```
