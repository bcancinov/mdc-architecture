# Architecture Handbook Publication Plan

**Status:** Draft publication plan; non-normative

This file defines how the architecture handbook will be planned, generated, reviewed, and distributed. It does not define controller architecture or add requirements.

## Source-of-Truth Model

- Resolved ADRs remain the authoritative source for architectural decisions and requirements.
- The handbook is a derived, non-normative explanation of those decisions as one coherent system story.
- Architectural changes shall be made in the controlling ADR before they are reflected in the handbook.
- If the handbook conflicts with an ADR, the ADR controls.
- Publication-planning material describes what to explain, how to explain it, and which sources to use. It shall not become a parallel copy of the architecture requirements.
- Exact requirements should be referenced or extracted from their authoritative sources when practical rather than copied into publication-planning files.

## Planned Publication Sources

The initial publication plan will remain in this file. It will define:

- the intended audience and reader outcomes;
- the chapter sequence and narrative flow;
- the authoritative ADR sources for each chapter;
- diagrams and examples needed for explanation;
- details that should remain outside the handbook; and
- chapter-level review questions.

Separate chapter-plan files will be introduced only if this file becomes difficult to maintain. Directly maintained LaTeX chapter files will contain the derived handbook narrative; this Markdown file remains the architectural content and explanation plan.

## Audience and Scope

The primary audience is electronics, firmware, software, systems, and integration engineers who are technically competent but unfamiliar with this controller. Secondary readers may include technical reviewers, project engineers, maintainers, and managers. The technical newcomer determines the explanation level.

After reading the handbook, a reader should be able to:

- draw the major system blocks and their connections;
- explain the responsibilities of each board type and the remote host;
- follow system power from its external input to each class of load;
- explain how hardware places the detector in a safe state;
- follow startup, configuration, arming, acquisition, disarm, fault, and recovery;
- explain the relationship between management clocks, sequencer timing, acquisition `SYNC`, and converter synchronization;
- understand board identification, communication, host supervision, and acquisition-data ownership;
- distinguish architectural, interface, and board-design responsibilities; and
- locate the authoritative decision behind an explanation.

The handbook covers the architecture between the external host, power, and timing boundaries and the detector-facing clock, bias, control, and video-data boundaries.

The handbook is not:

- a complete electrical interface specification;
- a connector pinout or protocol reference;
- a component-level hardware design;
- an FPGA or firmware implementation specification;
- an operator or maintenance procedure;
- a chronological history of ADR discussions; or
- a replacement for the ADRs.

Design rationale is included only where it helps the reader understand the architecture. Rejected alternatives and detailed decision history remain in the ADRs.

## Narrative Model and Opening

The handbook uses a hybrid narrative:

1. introduce the project's origins and guiding ideas, then provide a short complete system story;
2. explain the architecture by concern so each concept has one principal explanatory location;
3. use integrated operating and fault scenarios to show how those concerns cooperate; and
4. finish with integration boundaries and responsibilities.

The opening is written for the broader observatory and detector-engineering community. It presents NOIRLab as the project origin and initial use case, not as the only reason for the architecture.

The opening material consists of:

- a short preface covering document status, project provenance, and release information;
- a general detector-controller context covering long instrument lifetimes, electronics and vendor obsolescence, maintainability, concentrated knowledge, increasing channel counts, and the limits of monolithic controllers;
- the guiding ideas behind the approved architecture: modularity, scalability, standardization with specialization, open interfaces, independent module replacement, hardware-enforced safety, predictable timing and noise behavior, and support for multiple detector technologies; and
- a brief NOIRLab project-origin section pointing to the official project documents.

The opening chapter should occupy approximately two to three pages. It explains the thinking behind the approved project and does not reopen the project decision or repeat its business case. Detailed local inventory tables, controller maintainability scores, commercial cost comparisons, staffing and schedule constraints, complete business-option analysis, approval history, and phase-specific resource planning remain in the official project documents rather than the architecture handbook.

Historical local quantities are identified with their source date rather than presented as permanently current facts. Phase-specific status belongs in the preface or release information, not in the stable architectural narrative.

The official project documents under `docs/` provide project motivation, history, and organizational context. Resolved ADRs remain authoritative for the current technical architecture when earlier architecture descriptions differ.

The controlled-document conventions in `docs/Skipper CCD collaboration - Phase II Mandate.docx` guide the publication structure and document-control presentation. The architecture handbook does not inherit that mandate's project-specific content, approval roles, comments, or incidental formatting inconsistencies.

## Explanation-Quality Principles

A technically strong architecture is not sufficient if readers cannot build a correct mental model of it. Explanation quality is therefore a publication requirement.

Each major architectural topic should be presented in layers:

1. the problem or design pressure being addressed;
2. the architectural response in plain language;
3. the participating elements and their interactions;
4. normal behavior and relevant failure behavior;
5. the consequences and tradeoffs; and
6. references to the controlling ADRs.

The handbook should:

- introduce terminology before relying on it;
- use one controlled vocabulary consistently;
- provide a simple overview before detailed mechanisms;
- use diagrams to answer a specific reader question rather than for decoration;
- use operating and fault scenarios to connect mechanisms across chapters;
- separate required behavior from illustrative implementation examples;
- explain the reason for an unusual design choice near its first appearance; and
- avoid assuming that a reader has followed the chronological ADR discussions.

Chapter review questions should test reader understanding, not merely confirm that source material was copied. A chapter is successful when a technically competent new reader can explain its main mechanism, boundaries, and consequences without first consulting the ADRs.

## Technology and Toolchain Context

The opening chapter includes a concise section titled **Modern Enabling Capabilities**. It explains why a modular in-house controller is more cost-effective and achievable than comparable developments were decades ago because of advances such as:

- highly integrated processor/FPGA System-on-Modules;
- commodity Ethernet infrastructure and removal of custom host-interface cards;
- modern high-performance ADCs, DACs, power converters, and timing components;
- improved PCB fabrication and assembly access;
- mature HDL, software, simulation, version-control, and automated-build toolchains; and
- open-source design practices that support review, reuse, and collaboration.

This section describes enabling capabilities and their architectural consequences. It does not name or compare specific System-on-Modules, FPGA or processor families, component lines, vendors, software brands, or temporary product generations. The handbook explains what modern technology makes possible without presenting a product-selection recommendation. Cost figures and lifecycle claims are included only when useful, dated, and sourced to official project material.

## Provisional Handbook Structure

The initial chapter sequence is:

### Front Matter

- document status and non-normative notice;
- document version and generation date/time;
- abstract;
- brief project provenance; and
- references to the official project documents.

### Part I: Context and Overview

1. **Origins and Guiding Ideas** — Lifecycle and maintainability context; modularity; standardization without eliminating specialization; composable scaling; open design; shared safety and predictable behavior; modern enabling capabilities; project origin; scope; and non-goals.
2. **The System at a Glance** — A concise block diagram, board roles, system boundaries, and a short power-up-to-safe-shutdown walkthrough.

### Part II: Architecture

3. **Modular System Structure** — Main, function, bridge, backplane, and passive elements; board independence; and scaling principles.
4. **Power, Supervision, and Noise Architecture** — Protected input, common utilities, local conversion, supervision, synchronization, filtering, and return domains.
5. **Hardware Safety and Interlock Architecture** — Shared interlocks, continuity, watchdogs, fail-safe paths, local interlock power, and relay permissives.
6. **Operating Lifecycle and State Coordination** — Startup, readiness, configuration, arming, acquisition, disarm, fault entry, and recovery.
7. **Timing Domains and Synchronization** — Independent management clocks, distributed sequencer timing, acquisition synchronization, clock-loss detection, and converter synchronization.
8. **Identity, Communication, and Data Architecture** — Identity, recovery access, operational configuration, host inventory, sequencer loading, armed supervision, and acquisition-data ownership.

### Part III: Applying the Architecture

9. **Operating and Fault Scenarios** — Normal acquisition and representative clock, power, communication, and board-failure stories.

### Generated Appendices

- glossary;
- ADR traceability index;
- shared-signal summary;
- power-rail summary;
- official project references; and
- revision and source information.

This structure is a starting point. Chapter boundaries may change when detailed chapter plans reveal duplication or a clearer narrative order.

## Agreed Chapter Plans

### Chapter 1: Origins and Guiding Ideas

Chapter 1 explains why the approved architecture has its present direction. It covers lifecycle and maintainability context, modularity, standardization without eliminating specialization, composable scaling, open design, shared safety and predictable behavior, modern enabling capabilities, project origin, scope, and non-goals. It does not repeat the project business case or reopen project approval.

Target length is approximately two to three pages. NOIRLab is presented as the project origin and initial use case, while the underlying engineering concerns are framed for the broader observatory and detector-engineering community.

### Chapter 2: The System at a Glance

Chapter 2 is the second half of the introduction. Chapter 1 answers why the architecture exists; Chapter 2 explains what the architecture is at a high level; Chapter 3 begins the detailed explanation of how it works.

Chapter 2 contains:

- one overall architecture diagram;
- a concise explanation of board roles and system boundaries;
- the principal power, safety/coordination, timing, and communication/data flows;
- one brief walkthrough from power-up through acquisition and safe shutdown; and
- pointers to the detailed chapters.

It does not explain individual rails, watchdog internals, complete state behavior, detailed signal timing, communication protocols, or the complete fault taxonomy. Target length is approximately two to three pages.

### Chapter 3: Modular System Structure

Chapter 3 is the first detailed architecture chapter. It explains how the controller is divided into replaceable and scalable elements and assigns responsibility to each element.

After reading it, the reader should understand:

- why the architecture uses independent boards rather than one monolithic controller;
- what is common across the platform and what remains detector-specific;
- the roles of main, function, backplane, bridge, and passive elements;
- why the host communicates directly with active boards;
- how additional function boards or backplanes extend the system; and
- which boundaries allow one part to evolve without redesigning the complete controller.

The narrative order is:

1. system decomposition and controlled-interface principle;
2. main-board responsibilities and explicit non-responsibilities;
3. function-board responsibilities and detector-specific specialization;
4. backplane-board infrastructure responsibilities;
5. bridge-board and multi-backplane extension;
6. passive-terminator purpose;
7. host-owned logical roles and direct board communication;
8. common platform versus specialized front ends; and
9. scaling by adding boards, network capacity, power capacity, and backplanes within verified system limits.

The principal sources are ADR-002 for host inventory and board endpoints, ADR-003 for main-board scope and shared coordination, ADR-004 for slot timing and multi-backplane structure, ADR-005 for backplane power responsibilities, and ADR-006 for direct acquisition-data ownership.

The chapter begins with a deliberately simple physical concept diagram: a main board and representative function boards plugged into a common backplane. The overall diagram in Chapter 2 provides the wider host, network, bridge, and detector context. A responsibility table maps major functions to their architectural owner.

It does not explain detailed rail values, interlock mechanisms, complete state transitions, exact timing, communication protocols, connector pinouts, or board circuit design. Physical expansion is not presented as proof of adequate power, thermal, network, or timing capacity. Target length is approximately four to five pages.

### Chapter 4: Power, Supervision, and Noise Architecture

Chapter 4 follows energy from the external input through system protection, shared distribution, common utilities, and board-local conversion. It explains how the same architecture limits connector current, detects shared-rail faults, and controls conducted noise.

After reading it, the reader should understand:

- the distinction between external `+12V_IN` and protected distributed `+12V`;
- the central backplane eFuse's role as the system input circuit breaker;
- why `+12V` is the bulk input for high-current local conversion;
- why common modest-load utility rails are generated on the backplane;
- why ordinary digital supplies are generated locally from protected `+12V` rather than distributed as a common low-voltage rail;
- why boards need not consume every utility rail and specialized detector voltages remain local;
- the difference between backplane rail-health reporting, main-board measurement, local fail-safe power detection, interlock-supply supervision, and watchdog liveness detection;
- the purpose and boundary of board-local `V_INTERLOCK_LOCAL`;
- how coherent continuous switching, board-entry conditioning, and deliberate return planning control noise; and
- why physical slot capacity does not imply electrical capacity.

The narrative follows this order:

1. external input and complete system power tree;
2. central eFuse and protected `+12V` distribution;
3. common backplane utility generation;
4. auxiliary digital power versus high-current local processor conversion;
5. board-local conversion and protection responsibilities;
6. shared-rail protection, direct rail-health contribution, and main-board diagnostic measurement;
7. local interlock power and its distinction from functional power;
8. predictable utility-converter switching during acquisition;
9. bidirectional board-entry conditioning; and
10. return domains, connector allocation, power budgets, voltage drop, and thermal limits.

The exact utility-rail table should be extracted from or generated from ADR-005 rather than maintained independently in the handbook. A comparison table distinguishes backplane rail-health/PGOOD, main-board telemetry, local fail-safe detection, the interlock-power-loss reporting path, and the external watchdog.

The chapter uses a complete system power-tree figure and a bidirectional shared-rail noise figure. It explains that synchronization makes switching patterns predictable but does not claim that synchronization eliminates noise.

The principal source is ADR-005, with ADR-001 controlling `V_INTERLOCK_LOCAL` and local protection paths and ADR-003 controlling the state-level consequence of a power fault.

The chapter does not specify eFuse thresholds, converter part numbers, filter or LDO component values, mandatory local-eFuse topology, provisional current limits, exact synchronization mapping or phase, detailed `OK` electrical design, or board schematics. Target length is approximately six to eight pages.

### Chapter 5: Hardware Safety and Interlock Architecture

Chapter 5 explains how a detected hazardous condition removes detector-facing permission without depending on host software or continued FPGA operation. It begins at the protected output and works backward through the mechanisms that remove its permission.

After reading it, the reader should understand:

- the principle of going safe through hardware and arming deliberately;
- the separation between hardware interlock, board safety FSM, and host management;
- normally-open detector protection relays and the `local_arm_request AND EN AND OK` permissive;
- the complementary purposes of the continuity loop and shared open-drain `OK` bus;
- the different paths for local electronic faults, processor/FPGA power or reset loss, frozen logic, clock loss, shared-rail failure, local interlock-power loss, and armed host-supervision timeout;
- why complete central power removal is safe without preserving `OK` or telemetry;
- why safe-state entry precedes root-cause diagnosis;
- why recovery is explicit even after a condition disappears; and
- how maintenance detects a latent damaged fault-output path.

The narrative order is:

1. normally-open detector-facing outputs and the hardware permissive;
2. hardware interlock, safety-FSM, and host-management layers;
3. shared open-drain `OK` behavior;
4. passive or active continuity-loop behavior;
5. failure classes and their independent protection paths;
6. power and clock independence of protection mechanisms;
7. immediate safe action followed by retained diagnostic evidence;
8. latched-safe behavior and the boundary to Chapter 6 recovery;
9. safe maintenance verification of latent output-path failures; and
10. safety scope and limitations.

The chapter uses a relay-permissive figure and a fault-convergence figure showing independent sources reaching `OK` and every board's safe response. A simplified failure-to-protection table is preferred to copying complete diagnostic tables.

The principal sources are ADR-001 for the fault taxonomy and detection paths, ADR-003 for safety layers, recovery invariants, and relay permissives, ADR-004 for independent clocks and clock-loss evidence, and ADR-005 for shared-rail protection.

The chapter does not specify watchdog frequency or timeout, FPGA register/latch implementation, component selections, detailed voltage thresholds, formal safety certification, complete maintenance procedures, full diagnostic schemas, or duplicated state-transition detail. It explicitly states that board-specific hazardous functions may require additional monitoring and verification. Target length is approximately six to eight pages.

### Chapter 6: Operating Lifecycle and State Coordination

Chapter 6 explains how independently controlled boards behave as one system from power-up through acquisition, fault, and recovery. It presents the common externally visible lifecycle rather than prescribing identical internal FSM implementations.

After reading it, the reader should understand:

- local board state and readiness responsibilities versus main-board fleet coordination;
- the purpose of the `START`, `IDLE`, `RUN`, and `ERROR` state families;
- the distinction between Not Ready and Fault;
- the place of configuration and sequencer loading in the lifecycle;
- distributed arm acceptance through `EN` and local readiness checks;
- the arm-to-first-trigger guard;
- repeated acquisition behavior within `RUN`;
- hardware de-arm before residual FSM cleanup;
- shared fault entry and retained local evidence;
- explicit recovery through startup requalification; and
- armed-only protocol-neutral host supervision.

The narrative order is:

1. distributed coordination model and externally standardized behavior;
2. state-family overview;
3. safe startup and bounded qualification;
4. `IDLE` configuration and the Not Ready/Fault distinction;
5. distributed arming and independent function-board acceptance;
6. `RUN.init`, `RUN.wait`, `RUN.run`, and `RUN.stop` acquisition behavior;
7. hardware-first disarm and return to `IDLE`;
8. local and shared fault entry;
9. explicit clear, live-condition evaluation, and startup requalification;
10. armed host supervision; and
11. ownership of required timing categories without embedding values.

The chapter uses one state-family diagram with the `RUN` and `ERROR` families expanded and one sequence diagram showing host, main, and function-board behavior during configuration, arm, acquisition, and disarm. Detailed fault/recovery scenarios remain in Chapter 9.

The principal source is ADR-003, supported by ADR-002 for configuration and sequencer readiness, ADR-004 for acquisition timing ownership, and ADR-006 for host supervision during data transfer.

The chapter does not specify exact timer values, debounce counts, registers or latch names, command strings or responses, board-specific acquisition sequences, CDC implementations, or fault-detection circuits already explained in Chapter 5. Target length is approximately six to eight pages.

### Chapter 7: Timing Domains and Synchronization

Chapter 7 distinguishes the timing systems, identifies which relationships require phase coherence, and explains what remains operational after distributed timing is lost.

After reading it, the reader should understand:

- the separation between the distributed sequencer domain, acquisition `SYNC`, independent management clocks, watchdog liveness, utility synchronization, and optional local-converter synchronization, including alignment by an `EN=0` `SYNC` event on entry to `START`;
- full-rate 100 MHz point-to-point sequencer-clock distribution;
- the falling-edge launch and following-rising-edge capture of acquisition `SYNC` and its purpose in avoiding one-cycle ambiguity;
- the absence of a phase requirement for management-domain `SYNC` observation;
- management and protection operation after distributed-clock loss;
- independent clock-loss monitoring and separate watchdog evidence;
- explicit recovery rather than automatic acquisition restart after timing restoration;
- the separation between utility-converter and sequencer synchronization; and
- timing-budget ownership in the applicable ICDs.

The narrative order is:

1. timing-domain map and purpose of each timing function;
2. distributed 100 MHz sequencer clock;
3. point-to-point LVDS slot distribution;
4. acquisition `SYNC` half-cycle relationship;
5. CDC-safe management-domain observation;
6. independent local management clocks;
7. separate clock-loss detection and watchdog evidence;
8. safe response, restoration, requalification, and explicit re-arm;
9. five dedicated backplane utility-synchronization outputs using `2 MHz / N` during acquisition;
10. optional board-local converter synchronization from distributed timing, with boards accepting an `EN=0` alignment event in any local state and main sending it on entry to `START`; and
11. application timing-budget verification.

The chapter uses a timing-domain relationship diagram and a falling-edge-launch/rising-edge-capture diagram. A compact timing-chain figure may be added if it clarifies source-to-slot budget ownership. Detailed multi-backplane topology examples remain in the non-normative ADR reference.

The principal source is ADR-004, supported by ADR-003 for acquisition lifecycle and management ownership, ADR-001 for clock-loss and watchdog evidence, and ADR-005 for utility synchronization.

The chapter does not specify clock or fanout components, FPGA-family I/O techniques, universal jitter or skew limits, mandatory phase resolution, exact divider ratios or pet frequency, a mandatory CDC implementation, or converter-noise rationale already owned by Chapter 4. An implementation may align a local management clock for convenience, but safety and recovery shall not depend on that alignment or on the continued presence of distributed `CLOCK`. Target length is approximately five to seven pages.

### Chapter 8: Identity, Communication, and Data Architecture

Chapter 8 explains how the host identifies, configures, supervises, and receives data from independent boards without depending on slot position or a main-board communication proxy.

After reading it, the reader should understand:

- the independent service/recovery purpose of UART;
- persistent identity/bootstrap/factory data versus volatile operational configuration;
- why Ethernet cannot be the sole recovery path for invalid network configuration;
- host-owned mapping between logical roles, capabilities, endpoints, MAC addresses, and serial identities;
- why physical slot position is not operational identity;
- direct host-to-board communication and main's non-proxy role;
- replacement-board commissioning at an architectural level;
- volatile sequencer loading and readiness;
- protocol-neutral bidirectional armed supervision;
- direct video-board-to-host acquisition data;
- the distinction between data overrun and host-supervision failure; and
- ICD ownership of link rate, transport, framing, commands, and data format.

The narrative order is:

1. direct host-to-board communication model;
2. information classes organized by channel and lifetime;
3. persistent UART service and recovery;
4. board identity categories;
5. host-owned logical inventory;
6. replacement-board commissioning;
7. volatile operational configuration while safely disarmed;
8. sequencer transfer and readiness;
9. armed host supervision using an ICD-defined bidirectional interaction;
10. direct acquisition-data ownership;
11. data overrun versus supervision timeout;
12. trusted instrument-network boundary; and
13. communication-ICD responsibilities.

The chapter uses a direct host-to-board network diagram and an information-class/channel/lifetime matrix. A concise commissioning sequence may be added if it materially improves replacement-board understanding.

The principal source is ADR-002, supported by ADR-003 for legal operational states and supervision consequences and ADR-006 for acquisition transport and overrun behavior.

The chapter does not mandate Ethernet speed, TCP or another transport, UART framing, port numbers, command strings, NVM technology or format, a separate heartbeat message, hash algorithms, or a complete security architecture beyond the declared trust boundary. Target length is approximately six to eight pages.

### Chapter 9: Operating and Fault Scenarios

Chapter 9 integrates the architecture through end-to-end scenarios. It does not introduce new mechanisms or requirements. Every scenario follows a common structure: initial condition, initiating event, detection, hardware response, state response, diagnostic evidence, recovery, and controlling ADR sources.

The agreed scenario set is:

1. normal startup, inventory/configuration, arm, acquisition, and disarm;
2. arm attempted while one board is Not Ready;
3. comparison of a common utility-rail fault, one board losing `V_INTERLOCK_LOCAL`, and complete central-eFuse cutoff;
4. comparison of processor/FPGA power or reset collapse with powered-but-frozen logic;
5. distributed sequencer-clock loss with separate clock and watchdog evidence;
6. host communication loss during acquisition;
7. data overrun without host-supervision timeout;
8. physical discontinuity detected by the continuity loop; and
9. generic explicit fault correction, clear, requalification, and re-arm.

The damaged-`OK`-driver maintenance check remains in Chapter 5 and receives only a cross-reference here.

The chapter uses one normal-operation sequence diagram, one clock-loss or shared-trip sequence diagram, one comparison diagram for the three power-loss cases, and concise structured tables for other scenarios. Scenario diagrams are explanatory views of ADR-controlled behavior and shall not create new requirements.

All resolved ADRs may contribute to this chapter. Each individual scenario lists only the ADRs that control its behavior.

The chapter does not specify timeout values, command names, register-level diagnostic reads, component-level fault mechanisms, operator repair procedures, exhaustive simultaneous-failure combinations, or fault probabilities. Target length is approximately eight to ten pages because scenarios are the principal method for testing and communicating the complete mental model.

### Deferred Integration Material

Scaling budgets, multi-backplane implementation guidance, ICD declarations, and verification ownership are useful engineering material but are outside the present architecture handbook. The existing draft source is retained for possible reuse in a future integration guide and is not included in the distributed PDF or generated traceability.

## Diagram Strategy

Every handbook diagram is a non-normative explanatory view derived from authoritative decisions. Each figure answers one explicit reader question; figures that do not materially improve understanding are omitted.

TikZ is the preferred source format for final handbook diagrams. Each figure is kept in a separate source file, compiled independently with a shared publication preamble and the LaTeX `standalone` class, and included in the handbook as a generated vector PDF. Another source format may be used when TikZ would add substantial complexity without improving the result, but the exception and its build process are documented.

The intended structure is:

```text
publication/
├── figures/
│   ├── source/
│   │   ├── system_overview.tikz.tex
│   │   ├── power_tree.tikz.tex
│   │   └── interlock_paths.tikz.tex
│   └── generated/
│       ├── system_overview.pdf
│       ├── power_tree.pdf
│       └── interlock_paths.pdf
└── latex/
    └── noirlab/
        └── noirlab-document.sty
```

`noirlab-document.sty` defines the common appearance of main boards, function boards, backplanes, hosts, detectors, and power, safety, timing, and data flows together with the rest of the publication presentation. Individual figures describe semantic relationships rather than repeating fonts, colors, line widths, and arrow styles. Color may assist interpretation but shall not be the only visual distinction.

Each figure source begins with a traceability header identifying:

- figure ID;
- reader question;
- controlling ADRs or project-context documents;
- non-normative status;
- required concepts; and
- misleading implications the figure must avoid.

One maintained figure is preferred per explanatory concept. Existing Mermaid diagrams remain acceptable in ADR and reference material and are not automatically converted. A simpler handbook TikZ view may be created when it answers a different reader question, but identical Mermaid and TikZ publication copies shall not be maintained independently.

The initial target is approximately 12 to 16 principal handbook figures. Generated PDFs are build artifacts, not architectural sources. Automated checks cover source availability, successful compilation, references, controlled vocabulary, captions, and ADR traceability. Visual figure review remains the user's responsibility as defined above.

## Traceability Presentation

Traceability is visible without making the handbook read like a requirement database.

Each chapter ends with one short source note naming its main ADRs and project documents. Sources are not repeated throughout ordinary explanatory prose. A claim-level citation is used only when a precise or dated statement would otherwise be unclear.

Important figures and tables identify their derived, non-normative status in the caption when needed. Detailed source traceability remains in the maintained figure source and the generated traceability appendix instead of being repeated in the narrative. Content extracted directly from an ADR identifies the ADR and is regenerated during the publication build.

The build generates two traceability views:

1. handbook section to controlling ADR or official project document; and
2. ADR to the handbook sections that explain it.

Official project documents under `docs/` are represented as normal bibliography entries and are used primarily for Chapter 1 provenance and dated context. Historical quantities include their source date.

References use the ADR identifier plus a descriptive topic or section title, for example `ADR-005 — Utility Converter Frequency and Synchronization`. Repository line numbers, exported-page numbers, bare requirement numbers, and repeated raw repository URLs are avoided. The generated appendix may include filenames or repository links for source access.

The PDF front matter identifies:

- document version and generation date/time;
- generation date;
- handbook status as derived and non-normative; and
- whether the source tree contained uncommitted changes.

A release PDF should be generated from a clean committed repository snapshot. Working PDFs are identified by their 0.x version and generation timestamp without a draft watermark.

## Generation and Rendering

The intended flow is:

```text
authoritative ADRs + handbook publication plan
                    |
                    v editorial maintenance
       reviewed modular LaTeX chapters
                    |
                    v LaTeX build
        distribution architecture PDF
```

Pandoc is not part of the selected publication pipeline. Complete chapters are maintained as separate LaTeX files and assembled from `main.tex` with `\include`; sections, generated metadata, exact extracted tables, and reusable fragments use `\input`.

The intended source structure is:

```text
publication/
├── handbook_plan.md
├── README.md
├── Makefile
├── latexmkrc
├── metadata.tex
├── handbook/
│   ├── main.tex
│   ├── frontmatter/
│   ├── chapters/
│   ├── appendices/
│   └── generated/
├── latex/
│   ├── architecture.sty
│   └── noirlab/
│       ├── noirlab-document.sty
│       └── noirlab-assets/
├── scripts/
└── figures/
    ├── source/
    └── generated/
```

LaTeX chapter files are reviewed, version-controlled publication sources but remain derived and non-normative. Exact source-controlled lists, traceability indexes, and build metadata are generated into small LaTeX fragments rather than copied manually. Generated figure PDFs, auxiliary files, and final build products are not architectural sources of truth. Each released PDF is archived with the matching repository snapshot under the same formal document version.

## Incremental Construction and Review

The complete handbook is not written before the first review. The full LaTeX framework is created first, and content is then developed in coherent increments. The complete PDF is regenerated after every increment so local chapter work is continuously checked in the context of the whole document.

### Step 0: Complete Skeleton

Create the main document, metadata, title/status pages, table of contents, placeholder chapter and appendix files, bibliography infrastructure, shared LaTeX and TikZ styles, build commands, and draft-status marking. The result is a complete but mostly empty PDF suitable for early user review of document structure and presentation.

### Step 1: Introductory Part

Implement Chapters 1 and 2 together because they form one short introductory unit. Add the first complete system figure, rebuild the full PDF, run automated checks, and provide it for user visual review.

Before completing the full introductory part, Chapter 1 may be implemented and reviewed alone as a style and explanation-quality pilot. This intermediate review may change publication presentation and prose conventions but does not change the agreed boundary between Chapters 1 and 2.

### Subsequent Steps

Implement and review one chapter at a time in this order:

1. Chapter 3 — Modular System Structure;
2. Chapter 4 — Power, Supervision, and Noise Architecture;
3. Chapter 5 — Hardware Safety and Interlock Architecture;
4. Chapter 6 — Operating Lifecycle and State Coordination;
5. Chapter 7 — Timing Domains and Synchronization;
6. Chapter 8 — Identity, Communication, and Data Architecture;
7. Chapter 9 — Operating and Fault Scenarios;
8. generated appendices and final traceability.

For every increment:

1. write the chapter from its agreed plan and controlling sources;
2. create or update its diagrams;
3. compile the chapter independently during development;
4. rebuild the complete handbook;
5. run automated textual and build checks;
6. identify the new chapter, changed figures/tables, affected earlier sections, and changed cross-references;
7. provide the complete PDF for focused user visual review; and
8. apply corrections before beginning the next increment.

Broader integration reviews occur after Part I, after Part II, and after Part III plus appendices. These reviews focus on repetition, terminology, narrative flow, chapter boundaries, and cross-chapter consistency.

The assistant does not perform visual PDF inspection. The user reviews typography, layout, figure and table appearance, page breaks, and overall presentation. The assistant reports automated results and the pages or sections likely affected by each increment.

## Verification Responsibilities

Automated verification performed during handbook generation is limited to:

- successful LaTeX chapter, TikZ figure, and complete-handbook compilation;
- missing references, citations, figures, or source files;
- fatal build errors and relevant compiler warnings;
- correct document version and generation metadata; and
- consistency checks that can be performed without judging rendered page appearance.

The user owns visual review of the generated PDF, including:

- typography and readability;
- page and section breaks;
- table and diagram appearance;
- figure placement;
- page balance and whitespace; and
- overall presentation quality.

The assistant shall not render PDF pages for image-based inspection or perform visual layout review unless the user explicitly changes this instruction for a later task.

## Resolved Publication Conventions

### Document-control profiles

Working builds carry a 0.x document version and generation date/time without a draft watermark. They may be replaced freely and do not imply formal approval. Git information remains internal to the build and is not printed in the distributed PDF.

Official release builds require an explicit document reference code, owner, release version, release date, status, effective date, distribution classification, and approval record. Approval data is entered deliberately and is never inferred from Git history. Release PDFs are generated from a clean committed revision and preserved as immutable artifacts.

Publication metadata has one maintained LaTeX source. The cover, document-control pages, headers, footers, and generated revision appendix reuse that metadata rather than maintaining independent copies. Author, optional reviewers, and formal approvers remain separate fields.

### Controlled-document format

The handbook uses a reusable NOIRLab LaTeX presentation layer derived from the official controlled-document example under `docs/`. It includes the institutional color band, vector NOIRLab and AURA marks, cover metadata, paragraph and heading spacing, running identification, pagination, and a control notice. The architecture layer adds only handbook-specific technical presentation. Project-mandate sections, six-level heading styling, mixed legacy fonts, unrelated table palettes, unresolved template expressions, and document-specific approval roles are not copied.

The technical foundation is LuaLaTeX with KOMA-Script `scrreprt`, US Letter paper, 11-point type, one-sided pages, Source Sans Pro or its open successor, `scrlayer-scrpage` page styles, and `latexmk` as the build entry point. TikZ remains the preferred diagram format.

The assistant performs build and textual verification only. The user owns all visual review, including typography, spacing, logo scale, page breaks, tables, and figures.

### Identity assets

`publication/latex/noirlab/noirlab-assets/source/noirlab_logo.svg` and `aura_logo.svg` are the authoritative repository copies used by the document style. The publication system does not maintain second editable copies. Build-time vector PDF derivatives are placed in `noirlab-assets/` for LaTeX inclusion. Asset provenance and the exact official download URLs are recorded before formal release.

Formal public releases follow the current NOIRLab visual-identity guidance for NOIRLab, NSF, and AURA marks.
