# ADR-005: Backplane Utility Voltage Distribution

**Status:** Resolved
**Last updated:** 2026-09-07

---

## Context

Most modular boards need the same analog utility rails. If every board generates these modest common analog supplies locally from the distributed `+12V` input, the system duplicates converter area, thermal load, layout effort, and switching-noise sources across the backplane.

Digital loads are different. Processors, FPGAs, and memory can require high current and create fast load transients, while low-power digital support has no common use case that justifies another shared rail. All ordinary digital supplies therefore remain locally converted from `+12V`. This avoids extra connector allocation and an additional shared low-voltage noise path. Local converters and digital loads shall still meet the conducted-disturbance limits on protected `+12V`.

Specialized boards may still need uncommon detector-specific voltages such as +40V, -40V, +100V, or -100V. Those rails are not common to all boards and shall not be distributed as standard backplane resources.

---

## Decision

Every standard backplane board shall generate and distribute the complete set of **utility rails** below:

| Rail | Intended use |
|---|---|
| `+6V_ANA` | Common positive low-voltage analog utility rail |
| `-6V_ANA` | Common negative low-voltage analog utility rail |
| `+16V_ANA` | Common positive analog utility rail |
| `-16V_ANA` | Common negative analog utility rail |

The protected `+12V` distribution is also mandatory. It is the required input for board-local conversion that supplies digital loads, including processors, FPGAs, memory, identification, monitoring, and management/support circuits. It is also the preferred input for specialized converters that generate non-common rails such as high-voltage detector rails.

Utility-voltage converters are physically located on the backplane board, not on the main board and not independently on every function board. Their standard connector contacts shall remain assigned to these rails and shall not be omitted, left unpowered, or repurposed in a compliant standard backplane. Individual boards need not consume every rail. A specialized instrument that removes or changes a standard rail is a separate architecture variant requiring an explicit decision and ICD, not an option within this ADR.

Function boards may consume any subset of the shared analog utility rails, leave unused rail contacts unconnected, generate supplies locally from protected `+12V`, or combine both approaches. Selection is application-dependent and shall consider voltage, current, noise, transient response, efficiency, and thermal requirements. Local generation is permitted even when an equivalent nominal voltage is available from the backplane and does not constitute an architecture variant. Each board ICD shall declare its consumed backplane rails and associated power and noise budgets. Local protection, filtering, LDOs, and point-of-load regulation are board-design choices. Board-local digital supplies are generated from protected `+12V`; the standard backplane does not distribute a low-voltage digital utility rail.

## System 12 V Input Protection

The external power input is named `+12V_IN`. One central eFuse on the backplane shall protect the complete system and produce the distributed rail named `+12V`:

```text
+12V_IN -> central backplane eFuse -> protected +12V
                                           |
                                           +-> utility converters
                                           +-> main, function, and bridge boards
```

The central 12 V protection shall provide hardware protection against sustained input undervoltage, overvoltage, reverse polarity, excessive aggregate current, and system inrush. It shall also ensure that protected `+12V` remains within the verified input range of every downstream converter. If protected `+12V` cannot be maintained within that range, the central eFuse shall disconnect the complete downstream distribution. Exact thresholds, delays, current limits, component ratings, supervision method, and latch-or-retry behavior belong to the backplane hardware design specification.

The eFuse shall not be disabled by `EN`, `OK`, or an FSM state. A normal interlock fault makes hazardous functions safe but does not command system power off. Complete eFuse cutoff is already a safe condition because active boards and normally-open relays lose power; the architecture does not require `OK` or telemetry to remain valid after complete system-power removal.

Local board eFuses are not mandatory. Both main and function boards may use input eFuses on protected `+12V` or any consumed analog utility rail, using protection circuitry suitable for the rail's voltage and polarity. Each board shall meet its allocated steady-state, peak, and inrush current and shall include whatever local protection its hardware design needs to avoid damaging the board, connector, or shared distribution. A fuse, protected converter, load switch, eFuse, or another justified method may satisfy that requirement. The common analog utility rails normally feed board-local filters and LDOs and do not require an eFuse at every board input.

## Utility-Rail Fault Protection and Diagnostics

This section applies to the protected `+12V` distribution and the common utility rails generated by the backplane. It does not define function-board watchdogs, fail-safe logic, or supervision of board-local converters; those are separate local mechanisms defined by ADR-001.

The backplane board owns supervision of shared power while system power remains available. It shall produce one qualified open-drain rail-health contribution for protected `+12V` and for each utility rail. These outputs shall connect directly to the shared `OK` bus. A common rail fault therefore uses the hardware interlock path without relying on the main processor or an individual telemetry link. The central 12 V protection independently owns complete cutoff for an unsafe `+12V_IN` condition or protected `+12V` outside its verified range. A utility-rail fault does not command this complete cutoff.

For a utility rail, a converter's native PGOOD may provide this contribution when it has verified coverage and is electrically compatible with the `OK` bus in powered, unpowered, startup, shutdown, and fault states. In this architecture, **PGOOD means a native converter power-good output**; watchdog timeout, fail-safe, and interlock-supply supervisor outputs are not called PGOOD. If native PGOOD is insufficient, the backplane shall add a simple compatible rail supervisor or open-drain interface; redundant supervision is not required when native PGOOD already provides the necessary coverage.

The central eFuse's protected-output PGOOD or fault indication may provide the `+12V` rail-health contribution when its behavior is compatible with `OK`; otherwise the backplane shall add a simple protected-output supervisor or interface. The same indication, or another dedicated hardware path, shall make the central eFuse disconnect if protected `+12V` cannot remain within its verified range. This cutoff is not produced by connecting the shared `OK` bus to the eFuse control.

The main board shall measure protected `+12V` and the utility-rail voltages and may measure their currents for telemetry and root-cause diagnosis. These analog measurements are diagnostic only and do not replace the direct rail-health-to-`OK` path. Individual PGOOD copies shall not be routed to the main board: avoiding those copies removes the need for a buffer or isolation channel for every converter. Consequently, a very brief self-clearing event may be reported only as a generic backplane-power trip unless the backplane retains additional local evidence.

A function-board converter PGOOD is not a backplane rail-health output, and the architecture does not require every local converter to have an independent `OK` contribution. Loss of processor or FPGA power is covered by the `V_INTERLOCK_LOCAL`-powered fail-safe path. A board shall add local voltage or output supervision only when a failure could leave a safety-relevant function in a hazardous state not already covered by the fail-safe or watchdog paths; such a monitor enters that board's normal local-fault trip path.

All mandatory utility converters shall remain enabled whenever protected `+12V` is available. They shall not be disabled as a consequence of `EN`, `OK`, or an FSM state; this avoids a circular condition in which an interlock trip removes a rail and prevents its PGOOD from recovering. Selective software shutdown of a mandatory utility rail is outside this architecture.

During power-up, qualified rail-health outputs may hold `OK` LOW until all mandatory rails are valid. ADR-003 owns startup qualification: the fleet cannot reach `IDLE` until `OK` becomes stable, and a rail that never becomes valid causes the startup deadline to fail. During operation, loss of any mandatory common rail pulls `OK` LOW. If the electrical condition later clears, the system remains latched in `ERROR` and must complete explicit recovery through ADR-003.

---

## Utility Converter Frequency and Synchronization

Predictable conducted-noise patterns during acquisition are an architectural objective. Every enabled backplane utility-converter switching channel shall therefore use a synchronization signal during acquisition and shall operate in forced continuous-switching, fixed-frequency mode whenever enabled. Burst mode, pulse skipping, automatic low-frequency operation, and spread spectrum are prohibited for these utility converters. Protective current limiting, thermal shutdown, and fault shutdown remain permitted.

The **main board is the utility synchronization authority** and shall implement five point-to-point LVDS outputs as part of the standard main-board/backplane interface:

```text
UTILITY_DCDC_SYNC[0]_P/N
...
UTILITY_DCDC_SYNC[4]_P/N
```

These outputs reserve synchronization capability for up to five independent switching channels and are not permanently assigned one-to-one to the utility rails. The main-board connector pins, drivers, and timing-generation capability are mandatory even when a backplane uses fewer channels.

Every output frequency shall be coherent with the common 2 MHz baseline:

```text
f_sync[i] = 2 MHz / N_i
```

`N_i` is a positive integer defined by the backplane ICD. The ICD also defines channel mapping, enabled channels, phase behavior, phase resolution, converter capture range, free-running tolerance, and electrical implementation. Settings that affect switching timing shall remain fixed during acquisition.

Before synchronization is available, or after it is lost, an enabled converter shall remain in a defined forced continuous-switching, fixed-frequency free-running mode. Synchronization loss shall not create an uncontrolled rail or require processor intervention. Receiver, termination, routing, and component details belong to the backplane ICD and hardware design.

This decision intentionally keeps utility-converter synchronization separate from the function-board sequencer `CLOCK`/`SYNC` behavior in ADR-004:

- `UTILITY_DCDC_SYNC[0..4]` applies only to centrally generated backplane utility rails.
- ADR-004 timing applies to sequencer timing, optional watchdog-refresh alignment for noise control, and board-local special-purpose converters that explicitly derive switching clocks from distributed timing.
- Utility synchronization details do not add a shared FSM state or readiness bus. The backplane design shall ensure that converters have reached their defined operating mode before acquisition.

---

## Function-Board Shared-Rail Conditioning

Every function board shall provide conditioning at its power-entry boundary for each consumed shared rail, including protected `+12V` and any shared analog utility rails. This requirement applies to analog and digital loads, including board-local converters, and serves both directions:

1. reject shared-rail disturbances sufficiently for its local circuitry; and
2. limit its load transients and conducted emissions returned to the rail within the shared interface limits.

Protected `+12V` may supply sensitive analog circuitry through local conversion on other boards. Digital loads and their converters are therefore not exempt from shared-rail conducted-disturbance limits.

The backplane ICD shall define source impedance, ripple/noise and transient limits, and the maximum conducted disturbance that one board may return to a shared rail. Each function-board ICD shall declare its steady-state and transient current, input capacitance, inrush, required incoming-noise rejection, and permitted injected disturbance.

Filter and regulator topology, damping, component values, and exact placement belong to the board hardware design. An LDO alone, RC/LC/pi network, ferrite and reservoir, active filter, or another solution is acceptable when verified against the shared-rail interface and detector-performance requirements. No per-board analog-rail eFuse is required by this architecture.

---

## Connector and Return-Domain Partitioning

The architecture does not require separate physical analog and digital connector bodies. A single mechanically integrated connector is acceptable, but its pinout and the backplane routing shall provide physically segregated analog-power and digital/infrastructure zones.

The connector design shall:

- allocate dedicated analog-power return and digital/infrastructure return contacts;
- place return contacts adjacent to the `UTILITY_DCDC_SYNC` LVDS pair group and other fast differential pairs;
- separate analog utility-rail contacts from fast digital signals and digital power using return contacts or an equivalent grounded boundary;
- provide enough parallel power and return contacts for rated current, contact-resistance, temperature-rise, and reliability limits; and
- keep chassis/shield contacts distinct from circuit returns.

The intended relationship and bonding between analog and digital circuit returns shall be defined deliberately in the backplane ICD/design package; it shall not be created accidentally by connector pin allocation or board layout. Separate connector bodies may be selected when current capacity, routing, mechanical, EMC, or measured detector-noise requirements justify them. Exact connector selection, pin numbers, mating sequence, hot-plug behavior, and return allocation are ICD scope.

---

## Constraints

1. Every board shall generate its ordinary digital supplies locally from protected `+12V`; no low-voltage digital utility rail is distributed by the standard backplane.
2. Each function-board ICD shall declare, for every consumed rail, its maximum steady-state current, peak/transient demand, inrush or input capacitance, tolerance, and sequencing requirements.
3. The backplane ICD shall define per-slot and aggregate limits, protection thresholds, voltage-drop budgets, connector-contact allocation, converter and copper thermal limits, sequencing, ripple/noise limits, and telemetry. System integration shall verify that the installed fleet remains within every limit under worst-case simultaneous operation. Physical slot availability does not imply electrical capacity.
4. Backplane utility voltages do not replace board-local specialized rails where a voltage is not common across modular boards.
5. Safety-critical watchdog and fail-safe `OK` paths shall use the board-local `V_INTERLOCK_LOCAL` supply defined by ADR-001, independently of processor, acquisition/processing FPGA, and other ordinary digital rails. A dedicated safety CPLD may use this interlock supply as permitted by ADR-001.
6. A board-local converter that generates a specialized rail from `+12V` may synchronize its switching frequency according to ADR-004 when justified by the board ICD/design specification.

---

## Consequences

- One central backplane eFuse defines the boundary between external `+12V_IN` and the protected distributed `+12V` rail and disconnects if that protected output cannot remain within its verified range.
- A central eFuse cutoff removes power from the complete system; local board eFuses are optional implementation choices rather than architecture requirements.
- Shared analog rails offer function boards a way to reduce duplicated converter circuitry; each board may instead use local conversion when suitable for its application.
- Ordinary digital supplies remain board-local because no common low-voltage digital use case justifies another distributed rail.
- A single standard backplane power definition is retained even when a specialized detector does not consume every available rail.
- The backplane design becomes responsible for utility-rail capacity, protection, qualified rail-health-to-`OK` compatibility, coherent synchronization, continuous-switching operation, and the shared conducted-noise interface.
- Common-rail faults produce a fast shared interlock trip, while main-board analog measurements provide rail-level diagnostic context without separate PGOOD inputs.
- The main-board connector and timing logic reserve five LVDS synchronization outputs; mapping, divisors, and phase behavior are ICD-defined.
- Function-board ICDs must list which shared rails they consume, including protected `+12V`, and demonstrate compliant bidirectional rail conditioning.
- Backplane and connector designs must preserve analog/digital power zoning and intentional return-current paths.
- Specialized high-voltage or detector-specific rails remain local to the boards that need them.
- EMC/noise validation verifies synchronized continuous-switching behavior and determines whether phase offsets provide a useful improvement.
