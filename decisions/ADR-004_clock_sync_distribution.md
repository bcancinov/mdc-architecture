# ADR-004: Clock and Sync Distribution

**Status:** Resolved
**Last updated:** 2026-08-16

---

## Context

The main board distributes the acquisition timing used by sequencers across one or more backplanes. Timing-sensitive boards must associate each acquisition `SYNC` transition with the same intended 100 MHz clock cycle, while management and safety logic must continue operating if the distributed timing disappears.

> **Core decision:** Distribute a full-rate 100 MHz sequencer `CLOCK` and acquisition `SYNC` from main over point-to-point LVDS. Capture acquisition events directly in the timing domain, keep management clocks independent, and detect timing loss without relying on the lost clock.

---

## Considered and Rejected

### M-LVDS multidrop backplane clock

Rejected because stubs, connector discontinuities, and population-dependent loading make verification more difficult than independent point-to-point links.

---

## Resolved Constraints

### R1: Each slot receives point-to-point LVDS timing

Each supported slot receives dedicated `CLOCK` and `SYNC` differential pairs from the applicable timing fanout. There are no shared transmission-line stubs at the slot interface, and empty slots do not load populated-slot timing links.

Electrical levels, termination, routing impedance, skew, and connector pinout belong to the timing ICD and hardware design.

### R2: The sequencer clock is distributed at 100 MHz

The main board supplies the primary sequencer clock at 100 MHz. Function boards use it directly for their sequencer timing and do not recreate it by multiplying a lower-frequency reference. Lower-frequency synchronous functions may use integer division.

The complete source, fanout, routing, receiver, FPGA, ADC, and detector timing chain shall be verified for the application. The architecture does not prescribe the clock-source component.

### R3: Acquisition SYNC has a half-cycle launch/capture relationship

During acquisition, main changes `SYNC` on a falling edge of the distributed 100 MHz `CLOCK`, and participating function boards capture it on the following rising edge. This nominal 180° relationship gives a half-cycle separation so all boards associate the transition with the same intended clock cycle rather than ambiguously selecting the preceding or following edge.

The timing ICD shall verify the remaining setup/hold margin after source delay, fanout, routing, connectors, receivers, inter-board skew, and environmental variation. A rising `SYNC` event starts acquisition behavior and a falling event stops it as defined by ADR-003.

A separate CDC-safe observation may enter each board's independent management domain for state reporting and telemetry. This management observation has no required phase relationship with the local management clock and is not the source of the timing-critical sequencer event.

CNV and other timing-critical ADC controls shall be launched through deterministic timing-domain paths. Exact FPGA I/O technique and timing constraints belong to the video-board design.

Restoration of lost `CLOCK` never resumes acquisition automatically. The system remains safe, requalifies, returns to `IDLE`, and is explicitly armed again.

### R4: Watchdog and clock-loss evidence cover both critical domains

Every active board's external watchdog petting shall demonstrate progress of management/safety logic and the board's required timing/pet path. Petting stops if either path stops progressing. Independently, function boards monitor distributed `CLOCK` activity from their local management domain, and main monitors its external clock source.

Separate retained clock-loss and watchdog-activation evidence lets the host localize faults across the fleet: source loss, a board distribution/receiver problem, or a local logic/pet-path failure. Exact pet frequency, dividers, CDC topology, and diagnostic storage belong to firmware and hardware design specifications. The cascaded divider/toggle circuit in the ADR-001 reference is one compliant implementation.

### R5: Management clocks remain independent

Every active board shall have an independent local management clock for safety state, host supervision, fault monitoring, diagnostics, and communications. It shall not require the distributed 100 MHz `CLOCK` or phase lock to it.

Loss of distributed `CLOCK` shall not stop management, Ethernet/UART service, fault response, or recovery control. Operational timeouts are expressed in real time and implemented from the appropriate local time base.

### R6: Optional board-local converter synchronization

A specialized board-local converter may synchronize to a timing-derived reference when its design benefits from coherent switching. If it uses the common 2 MHz baseline, its synchronization frequency is `2 MHz / N` for an ICD-defined positive integer `N`. Divider, phase, settling, free-running fallback, and filtering are board-design choices.

An optional pre-arm `SYNC` event may establish a board-specific converter phase relationship. A board that requires settling after this event remains Not Ready until its verified settling interval has elapsed. This optional converter use does not alter the acquisition `SYNC` capture rule in R3.

Backplane utility-converter synchronization is owned by ADR-005.

### R7: Slot count and multi-backplane topology are application-dependent

The architecture does not impose a universal slot or backplane count. Each instrument defines its topology from power, thermal, mechanical, and timing constraints.

Multi-backplane designs shall preserve point-to-point slot interfaces and verify cumulative propagation, jitter, skew, and setup/hold margin. Buffer-only, regenerated, hierarchical-star, daisy-chain, and hybrid examples are shown non-normatively in [ADR-004_clock_topology_reference.md](reference/ADR-004_clock_topology_reference.md).

---

## Decision

Resolved. Point-to-point LVDS distribution, the fixed 100 MHz sequencer clock, half-cycle acquisition-SYNC relationship, deterministic timing-domain capture, independent management clocks, two-domain liveness evidence, and application-defined multi-backplane scale are architectural. Divider implementation, detailed timing budgets, and optional board-local converter behavior belong to ICD and design specifications.

---

## Consequences

- Timing ICDs must verify that every participating board captures each acquisition `SYNC` on the intended 100 MHz edge.
- Board management and diagnostics remain available after distributed-clock loss.
- Watchdog and clock evidence remain separate for fault localization without mandating one divider or CDC circuit.
- Instrument designs define and verify their own slot count and multi-backplane timing topology.
