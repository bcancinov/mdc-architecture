# ADR-005: Backplane Utility Voltage Distribution

**Status:** Resolved
**Last updated:** 2026-08-14

---

## Context

Most modular boards need the same analog utility rails and some low-power digital support circuitry benefits from a shared auxiliary rail. If every board generates these modest common loads locally from the distributed `+12V_RAW` input, the system duplicates converter area, thermal load, layout effort, and switching-noise sources across the backplane.

Processor, FPGA, memory, and other high-current digital loads are different: distributing their power at 3.3 V would increase connector current and voltage drop, while their fast load transients and local point-of-load converters could conduct noise onto a shared rail. These loads therefore remain locally converted from `+12V_RAW`.

Specialized boards may still need uncommon detector-specific voltages such as +40V, -40V, +100V, or -100V. Those rails are not common to all boards and should not be distributed as standard backplane resources.

---

## Decision

The backplane/common-power domain provides a set of **utility voltages** to modular boards:

| Rail | Intended use |
|---|---|
| `+3.3V_DIG_AUX` | Low-power auxiliary digital loads, such as identification, monitoring, and modest management/support circuits |
| `+6V_ANA` | Common positive low-voltage analog utility rail |
| `-6V_ANA` | Common negative low-voltage analog utility rail |
| `+16V_ANA` | Common positive analog utility rail |
| `-16V_ANA` | Common negative analog utility rail |

The existing `+12V_RAW` distribution remains available to each modular board. It is the required input for board-local conversion that supplies processors, FPGAs, memory, and other high-current digital loads, and the preferred input for specialized converters that generate non-common rails such as high-voltage detector rails.

Utility-voltage converters are physically located on the backplane/common-power board, not on the main board and not independently on every function board. Function boards may add local protection, filtering, LDOs, or point-of-load regulation where needed, but should not regenerate these common utility voltages from `+12V_RAW` unless the board ICD/design spec justifies an exception. `+3.3V_DIG_AUX` is not a bulk processor/FPGA supply and shall not be used as the input to high-current digital point-of-load conversion.

## Utility-Rail Fault Protection and Diagnostics

Each utility converter's compatible open-drain power-good/fault output shall connect directly to the shared `OK` bus. A converter fault therefore uses the same hardware interlock path as board-local faults and sends the system to `ERROR.run` without relying on the main processor or an individual telemetry link.

Direct wire-AND connection is permitted only when every participating output is electrically compatible with the `OK` bus in its powered, unpowered, startup, shutdown, and fault states. The common-power design must verify voltage ratings, polarity, leakage, pull-up current, output behavior during loss of converter bias, and fault coverage. If a converter's native output cannot meet these conditions or does not supervise the required undervoltage/overvoltage cases, the backplane shall add a simple compatible hardware supervisor or open-drain interface for that rail.

The main board shall measure the present utility-rail voltages and may measure rail currents for telemetry and root-cause diagnosis. These analog measurements are diagnostic only and do not replace the direct PGOOD-to-`OK` path. Individual PGOOD copies shall not be routed to the main board: avoiding those copies removes the need for a buffer or isolation channel for every converter. Consequently, a very brief self-clearing event may be reported only as a generic common-power trip unless the common-power implementation retains additional local evidence.

---

## Utility Converter Frequency and Synchronization

Backplane utility DC-DC converters shall use a fixed nominal **2 MHz switching frequency during normal, non-fault acquisition operation**. Fixed-frequency operation keeps the conducted-noise spectrum predictable and lets function-board input filters be designed around a known fundamental and its harmonics. Converter efficiency, thermal margin, magnetic-component loss, and control-loop performance at 2 MHz must be verified in the common-power design, particularly for the `+/-16V_ANA` conversion stages.

During normal, non-fault acquisition operation, utility converters shall not enter burst mode, pulse-skipping mode, frequency foldback, spread-spectrum operation, or another mode that introduces asynchronous or low-frequency switching components. Before an external synchronization reference is available, or after its loss, an enabled converter may free-run within an ICD-defined band around 2 MHz, but it must remain in a continuous fixed-frequency operating mode. This restriction does not prevent protective shutdown, current limiting, or other required fault responses. Startup, light-load, synchronization-loss, and fault behavior are common-power ICD/design-package requirements.

The **main board is the utility synchronization authority** and shall implement five independently phase-capable, point-to-point LVDS outputs:

```text
UTILITY_DCDC_SYNC[0]_P/N
...
UTILITY_DCDC_SYNC[4]_P/N
```

These outputs reserve synchronization capability for up to five independent switching channels; they are not permanently assigned one-to-one to the five utility rails. A single converter channel may generate more than one rail. Channel-to-converter and channel-to-rail mapping belong to the common-power ICD.

Each output shall generate 2 MHz from the main board's 100 MHz timing source and support an independently configurable phase offset with 10 ns resolution over the 500 ns switching period. The main-board connector pins, FPGA or timing-logic implementation, and output buffering are mandatory even when a particular instrument elects not to synchronize its utility converters.

Use of external synchronization by a utility converter is optional when fixed-frequency unsynchronized operation satisfies the instrument's conducted-noise, EMC, and detector-performance requirements. When synchronization is used, all channels may use the same phase or an instrument-defined phase plan may offset them to reduce coincident input-current transients. No universal phase plan is imposed by this ADR because the useful offsets depend on converter topology and load. Phase settings and the output-enable mask are volatile main-board operational configuration supplied by the host in `IDLE` per ADR-002. They shall remain fixed throughout acquisition; implementations shall prevent malformed or shortened sync periods when applying a new setting.

The LVDS links shall be routed point-to-point and terminated at the common-power destination. LVDS receivers shall be placed in the common-power domain, with only short local single-ended connections from the receivers to converter synchronization inputs. Receiver behavior for an absent, disconnected, or unpowered transmitter must be deterministic and must permit the converter's defined free-running fallback. Differential impedance, termination value, electrical levels, intra-pair skew, channel-to-channel skew, return-pin allocation, and receiver/component selection are ICD/design-package scope.

This decision intentionally keeps utility-converter synchronization separate from the function-board sequencer `CLOCK`/`SYNC` behavior in ADR-004:

- `UTILITY_DCDC_SYNC[0..4]` applies only to centrally generated backplane utility rails.
- ADR-004 timing applies to sequencer timing, watchdog timing-domain qualification, and board-local special-purpose converters that explicitly derive switching clocks from distributed timing.
- Utility synchronization or phase offset is not an FSM readiness gate unless an instrument ICD adds a measured, project-specific requirement.

---

## Function-Board Input Filtering

A function board that supplies noise-sensitive analog circuitry from a backplane analog utility rail shall provide a local, damped input low-pass filter **inside the module, immediately after the backplane connector and before the low-noise LDO or analog point-of-load regulator**. The intended physical partition is:

```text
backplane connector -> protection/inrush -> dirty-side capacitor
                    -> series filter element -> clean-side capacitor
                    -> low-noise LDO/regulator -> sensitive analog load
```

A damped C-L-C (pi) network is the normal implementation, but this ADR specifies the required isolation and attenuation rather than mandating one topology for every load. Filter stability (damping/Q, impedance interaction with the backplane source, regulator, and load) and component-level engineering concerns (derating, parasitics, saturation, inrush, dropout, load transients) are design-specification scope, verified per the board ICD/design package.

Each function-board ICD/design specification shall define the required attenuation at 2 MHz and relevant harmonics, the implemented topology and damping method, and the maximum input capacitance/inrush presented to the backplane. Digital-only loads do not require the same analog input filter unless their board-level noise or transient budget requires one.

Local module filtering is additional isolation, not a substitute for a compliant backplane rail. The common-power design shall still meet the ICD-defined ripple, conducted-noise, transient, and stability limits at the backplane interface.

---

## Connector and Return-Domain Partitioning

The architecture does not require separate physical analog and digital connector bodies. A single mechanically integrated connector is acceptable, but its pinout and the backplane routing shall provide physically segregated analog-power and digital/infrastructure zones.

The connector design shall:

- allocate dedicated analog-power return and digital/infrastructure return contacts;
- place return contacts adjacent to the `UTILITY_DCDC_SYNC` LVDS pair group and other fast differential pairs;
- separate analog utility-rail contacts from fast digital signals and digital power using return contacts or an equivalent grounded boundary;
- provide enough parallel power and return contacts for rated current, contact-resistance, temperature-rise, and reliability limits; and
- keep chassis/shield contacts distinct from circuit returns.

The intended relationship and bonding between analog and digital circuit returns shall be defined deliberately in the common-power and backplane ICD/design package; it shall not be created accidentally by connector pin allocation or module layout. Separate connector bodies may be selected when current capacity, routing, mechanical, EMC, or measured detector-noise requirements justify them. Exact connector selection, pin numbers, mating sequence, hot-plug behavior, and return allocation are ICD scope.

---

## Constraints

1. `+3.3V_DIG_AUX` is a current-limited auxiliary digital rail, not a processor, FPGA, memory, or other high-current load rail. Its maximum per-slot and aggregate current shall be defined by the ICD. Analog circuits must use appropriate analog utility rails or local analog regulation/filtering.
2. Utility-voltage current budgets, tolerances, sequencing, ripple/noise limits, connector pins, protection, inrush behavior, and telemetry are ICD/design-package scope. The backplane must protect each rail and supervise all rail conditions designated as safety relevant.
3. Backplane utility voltages do not replace the need for board-local specialized rails where the voltage is not common across modular boards.
4. Safety-critical watchdog and fail-safe `OK` paths must remain independent of processor/FPGA rails and of `+3.3V_DIG_AUX` as required by ADR-001. The auxiliary rail is not, by itself, an acceptable independent watchdog/fail-safe supply.
5. A board-local converter that generates a specialized rail from `+12V_RAW` may optionally synchronize its switching frequency according to ADR-004, but that is a board-specific design choice justified in the board ICD/design spec.

---

## Consequences

- Common rail generation moves out of most function-board designs, reducing duplicated converter circuitry and aggregate switching-noise sources.
- The backplane/common-power design becomes responsible for utility-rail capacity, protection, PGOOD-to-`OK` compatibility, 2 MHz fixed-frequency operation, output filtering, synchronization receivers, and optional phase-interleaved operation.
- Common-rail faults produce a fast shared interlock trip, while main-board analog measurements provide rail-level diagnostic context without separate PGOOD inputs.
- The main-board connector and timing logic reserve five independently phase-capable LVDS synchronization outputs even when an instrument does not use them.
- Function-board ICDs must list which utility rails they consume and the local regulation/filtering used for noise-sensitive analog loads.
- Backplane and connector designs must preserve analog/digital power zoning and intentional return-current paths.
- Specialized high-voltage or detector-specific rails remain local to the boards that need them.
- EMC/noise validation decides whether a given instrument must connect its utility converters to the provided synchronization outputs and whether phase offsets provide a useful improvement.
