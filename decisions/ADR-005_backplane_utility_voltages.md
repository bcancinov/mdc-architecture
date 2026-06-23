# ADR-005: Backplane Utility Voltage Distribution

**Status:** Resolved
**Last updated:** 2026-06-23

---

## Context

Most modular boards need the same low-voltage digital and analog rails. If every board generates these common rails locally from the distributed `+12V_RAW` input, the system duplicates converter area, thermal load, layout effort, and switching-noise sources across the backplane.

Specialized boards may still need uncommon detector-specific voltages such as +40V, -40V, +100V, or -100V. Those rails are not common to all boards and should not be distributed as standard backplane resources.

---

## Decision

The backplane/common-power domain provides a set of **utility voltages** to modular boards:

| Rail | Intended use |
|---|---|
| `+3.3V_DIG` | Digital loads only, such as FPGA/SoC/processor logic, management interfaces, and digital support ICs |
| `+6V_ANA` | Common positive low-voltage analog utility rail |
| `-6V_ANA` | Common negative low-voltage analog utility rail |
| `+16V_ANA` | Common positive analog utility rail |
| `-16V_ANA` | Common negative analog utility rail |

The existing `+12V_RAW` distribution remains available to each modular board. It is the preferred input for board-local specialized converters that generate non-common rails, for example high-voltage detector rails.

Utility-voltage converters are generated centrally in the backplane/common-power domain, not independently on every function board. Function boards may add local filtering, protection, LDOs, or point-of-load regulation where needed, but should not regenerate these common utility voltages from `+12V_RAW` unless the board ICD/design spec justifies an exception.

---

## Utility Converter Synchronization

If utility-voltage DC-DC converter synchronization is implemented, the **main board is the synchronization authority**. The main board provides the sync reference/control used by the backplane utility converters. Signal naming, voltage levels, fanout, isolation, and timing details are ICD scope.

Utility converter synchronization is **preferred but optional**. It may be waived if EMC/noise characterization and detector-performance testing show that unsynchronized utility converters meet the instrument requirements.

This decision intentionally keeps utility-converter synchronization separate from the function-board sequencer `CLOCK`/`SYNC` behavior in ADR-004:

- Utility converter sync applies to centrally generated backplane utility rails.
- ADR-004 timing applies to sequencer timing, watchdog timing-domain qualification, and any board-local special-purpose converters that explicitly derive switching clocks from distributed timing.
- Utility converter sync is not a required FSM readiness gate unless a future instrument ICD adds a measured, project-specific requirement.

---

## Constraints

1. `+3.3V_DIG` is for digital use only. Analog circuits must use appropriate analog utility rails or local analog regulation/filtering.
2. Utility-voltage current budgets, tolerances, sequencing, ripple/noise limits, returns, connector pins, protection, inrush behavior, and telemetry are ICD/design-package scope.
3. Backplane utility voltages do not replace the need for board-local specialized rails where the voltage is not common across modular boards.
4. Safety-critical watchdog and fail-safe `OK` paths must remain independent of the FPGA/processor digital rail as required by ADR-001. Supplying the FPGA from `+3.3V_DIG` does not by itself make `+3.3V_DIG` an acceptable independent watchdog/fail-safe supply.
5. A board-local converter that generates a specialized rail from `+12V_RAW` may optionally synchronize its switching frequency according to ADR-004, but that is a board-specific design choice justified in the board ICD/design spec.

---

## Consequences

- Common rail generation moves out of most function-board designs, reducing duplicated converter circuitry and aggregate switching-noise sources.
- The backplane/common-power design becomes responsible for utility-rail capacity, protection, filtering, and optional synchronization.
- Function-board ICDs must list which utility rails they consume and any additional local regulation or filtering they require.
- Specialized high-voltage or detector-specific rails remain local to the boards that need them.
- EMC/noise validation decides whether utility converter synchronization is required for a given instrument implementation.
