

# 

# NOIRLab Detector controller

# Architecture overview

**Author(s): NOIRLab Detector Group**  
Release Date: 2026-02-16

**Table of Contents**

[**1.- Current detector controller status in NOIRlab	2**](#1.--current-detector-controller-status-in-noirlab)

[1.1 NOIRLab’s Detector Controllers Survey	2](#1.1-noirlab’s-detector-controllers-survey)

[1.2 Why we are building a new controller	4](#1.2-why-we-are-building-a-new-controller)

[**2.- The Proposed Controller	5**](#2.--the-proposed-controller)

[2.1 Functional and Performance Requirements summary	6](#2.1-functional-and-performance-requirements-summary)

[2.2 Architectural Block Diagram	7](#2.2-architectural-block-diagram)

[2.2.1 Communications	7](#2.2.1-communications)

[2.2.2 Backplane	8](#2.2.2-backplane)

[2.2.2 Boards	9](#2.2.2-boards)

[2.3 Boards General Block Diagram	9](#2.3-boards-general-block-diagram)

[2.3.1 Common Modules	11](#2.3.1-common-modules)

[2.3.2 Front End Electronics (FEE)	12](#2.3.2-front-end-electronics-\(fee\))

[2.3.2.1 Video Boards	12](#2.3.2.1-video-boards)

[2.3.2.2 Clock Boards	12](#2.3.2.2-clock-boards)

[2.3.2.3 Bias Boards	12](#2.3.2.3-bias-boards)

[2.3.2.4 Master Board	13](#2.3.2.4-master-board)

[2.4 Sequencer/Readout	13](#2.4-sequencer/readout)

[2.5 Architectural Notes	14](#2.5-architectural-notes)

[**3.- Prototyping	15**](#3.--prototyping)

[**Appendix A	16**](#appendix-a)

## 

# **1.- Current detector controller status in NOIRlab** {#1.--current-detector-controller-status-in-noirlab}

## **1.1 NOIRLab’s Detector Controllers Survey** {#1.1-noirlab’s-detector-controllers-survey}

Table 1, based on an internal survey, summarizes the variety of controller systems in use, the number of controllers, and a maintainability score (0–10) derived from local knowledge, available spares, the availability of vendor/user support, and the age of the equipment. Scores below five indicate a risk of significant downtime due to limited spares and/or expertise; scores of seven or above indicate low maintenance risk.

| Controller Type | Quantity in Use | Metric for maintainability | Commentary |
| :---- | ----- | ----- | :---- |
| ARC (SDSU) | 15 | **4** | Limited spares, obsolete equipment, no vendor support, limited knowledge for repair. |
| MONSOON Orange/Fermi | 11 | **6** | Obsolete technology, sufficient inventory of spares, some local knowledge available. |
| MONSOON Torrent | 4 | **4** | Only in MSO South. Full inventory of spares, little local knowledge |
| Sinistro | 4 | **4** | Responsibility is LCO and maintained by joint LCO/NOIRLab effort, no local knowledge, limited spares. |
| Spectral Instruments | 3 | **2** | SOAR principle instrument Maintained by NOIRLab. No spares available. Old technology with limited vendor support. |
| Ed Loh Special | 1 | **1** | Soon to be decommissioned. No spares, no documentation, no knowledge. |
| MCE4 | 2 | **3** | Obsolescent technology. Condition and state of spares unknown. Limited manufacturer support. Limited local knowledge  |
| Sidecar ASIC | 10 | **5** | Reasonably recent technology, few spares, low vendor support level, limited local knowledge. |
| Andor | 4 | **6** | Recent technology, strong vendor support, no spares. |
| ARCHON | 4 | **6** | Reasonably recent technology, good vendor support, no spares. |
| Redstar | 2 | **3** | NICI instrument (decommissioned). Obsolescent technology. Condition and number of spares unknown. |
| Barcelona (DESI) | 10  | **8** | Recent technology, some local knowledge, adequate vendor support, some spares. |
| LBNL (DESI) | 30 | **8** | Recent technology, some local knowledge, adequate vendor support, some spares. |
| FLI | 1 | **5** | The vendor is actively servicing these cameras. No spares on site. |
| QSI | 2 | **7** | The vendor is actively servicing these cameras. No spares on site but cameras are Interchangeable. |
| Stargrasp | 8 | **4** | Principle WIYN instrument. Obsolescent technology, few spares, low vendor support level. |
| GNAAC | 2 | **3** | Only in Gemini North. Obsolete technology. One system soon to be replaced with an ARC controller which is obsolete itself. The remaining controller may benefit from spares gained from the decommissioned unit. |
| MACIE | 4 | **5** | The vendor is currently servicing these controllers, but this will change in the near future. There are some obsolete components |
| **TOTAL** | **117** | **\-** | **Total number of controllers** |

**Table 1** \- Variety of Detector Controller types in use at the AURA Observatories

## 

## **1.2 Why we are building a new controller** {#1.2-why-we-are-building-a-new-controller}

The decision to develop a new detector controller architecture is driven by the need to secure the long-term operational viability of NOIRLab’s instrumentation suite. By bringing controller technology back in-house, the organization gains **full control over the architecture and its entire lifecycle**, moving away from a reliance on external vendors whose roadmaps may not align with the decadal needs of ground-based astronomy. This transition reduces the current diversity of disparate technologies, consolidating "local knowledge" into a shared organizational asset. This centralization of expertise not only streamlines training but also creates a more resilient engineering environment where knowledge is preserved across teams.

A fundamental advantage of this new platform is that it enables a **planned and programmed approach to obsolescence management**. By decoupling the core processing and power systems from the specific detector interfaces, we eliminate the risks associated with single-source components. This modularity supports incremental replacement strategies, allowing for the update of a single board or module without the prohibitive cost of a complete system overhaul. Investing in this standardized platform today provides a flexible foundation for the next generation of instrument needs, ensuring that future projects can leverage a proven, high-performance baseline.

Furthermore, the architecture is designed to simplify long-term maintenance and lower resource consumption through its focus on commonality and simplicity. This project serves as a significant driver for talent retention, as it provides our engineering staff with ownership over a complex, high-impact project that pushes the boundaries of detector control technology. Ultimately, by establishing a **supported, open-source standard**, NOIRLab provides a roadmap that can be adopted across the broader astronomical community, fostering a collaborative ecosystem where improvements made by one institution can benefit the entire field.

# 

# **2.- The Proposed Controller** {#2.--the-proposed-controller}

The new controller’s architecture is designed to support the most extreme performance requirements of current instrumentation while maintaining the headroom necessary to handle future developments. To establish a baseline for current operations, we reference the minimum requirements derived from our most demanding existing systems. These benchmarks ensure that any new platform maintains continuity with the high standards already established across the observatory's fleet.

For forward-looking capacity, the platform must accommodate the massive channel counts of emerging devices. For example, a single 4k x 4k MAS Skipper CCD, such as those currently under development by STA, would require the controller to manage 128 parallel channels. A modest mosaic of only four such devices would scale the requirement to 512 channels. **Given that we cannot fully predict every future detector evolution, the platform must be inherently modular and scalable.** These two principles—modularity and scalability—stand as the most critical requirements of the architecture, ensuring that the system can grow through the addition of standardized boards rather than through complete architectural redesigns.

| Specification | Value | Instrument | Observatory |
| :---- | ----- | ----- | ----- |
| Bandwidth (MB/s) | 62 | Newfirm | CTIO |
| Number of channels | 256 | Newfirm | CTIO |
| Number of clocks | 138 | DEcam | CTIO |
| Number of biases | 72 | DEcam | CTIO |
| Number of detectors | 72 | DECam | CTIO |
| Maximum H2RG detectors | 4 | SCORPIO | Gemini South |
| Maximum EMCCD | 3 | CANOPUS | Gemini South |

**Table 2** \- minimum requirements of new controller to support current instrumentation

## **2.1 Functional and Performance Requirements summary** {#2.1-functional-and-performance-requirements-summary}

The NOIRLab Detector Controller architecture is defined by a set of core principles designed to balance cutting-edge scientific performance with long-term operational sustainability. These requirements ensure that the system remains flexible enough to support a wide variety of detectors while minimizing the complexity of the hardware itself.

**Modular and Scalable Design:** The architecture must be highly modular and scalable, particularly regarding the number of video channels supported. By utilizing a distributed board approach, the controller can be expanded to meet the needs of large-format focal planes without necessitating a redesign of the underlying infrastructure.

**Open Hardware Ecosystem:** All electronic designs will be developed within an open-source framework to foster accessibility and international collaboration. **All PCB designs must utilize KiCad 9+**, and all source code, gateware, and hardware design files will be shared publicly via GitHub. This ensures that the global astronomical community can audit, improve, and reproduce the hardware as needed.

**Standardization and Communication Protocols:** Wherever possible, the system utilizes commercially available standards for hardware modules and interfaces. **Ethernet is the primary protocol for command and video data transmission**, providing a robust and ubiquitous link between the host and the controller boards. For internal board management, standard low-level protocols such as SPI and I2C are mandated to ensure compatibility across various components and sensors.

**Simplicity and Reliability:** A primary goal is to keep the design and construction as simple as possible. The architecture includes only the functionality strictly required for optimal performance, effective hardware-debug mechanisms, and detector safety. **By avoiding unnecessary technical complexity**, the system gains reliability and becomes easier for technicians to maintain in remote observatory environments.

**Board Commonality and Vendor Independence:** To streamline maintenance and reduce the inventory of spare parts, the system maximizes hardware commonality. **The processing unit, power distribution, and communications modules are identical across all boards**; specific boards differ only in their specialized front-end functions, such as video ADCs or clock drivers. Furthermore, while the system uses commercial processing units, the architecture is designed to be vendor-neutral, ensuring that the controller is not locked into a specific manufacturer's proprietary ecosystem.

**Host-Side Processing:** To keep the controller firmware lean and deterministic, every function that can be safely offloaded to the host computer should be implemented there. This includes pixel or image preprocessing, complex software debugging tools, and high-level control logic. This approach ensures that the "on-instrument" hardware remains focused on the critical, time-sensitive tasks of detector operation and data acquisition.

## **2.2 Architectural Block Diagram** {#2.2-architectural-block-diagram}

Figure 1 shows the proposed general architecture.   
![][image1]

***Figure 1: proposed general controller architecture:** a) Ethernet protocol. b) A small, minimal backplane. c) Naturally scalable in number of boards and number of downlinks required.*

### 

### 

### **2.2.1 Communications** {#2.2.1-communications}

All boards use Ethernet to communicate both between them and with the host, as illustrated by the **blue connectivity lines in Figure 1**. Historically, high-speed acquisition systems required costly fiber-optic transceivers and specialized, custom interface cards to transport data. By adopting standard Ethernet, we leverage commodity switches and Network Interface Cards (NICs), effectively eliminating the need to design and maintain custom transmission hardware or proprietary computer boards.

Using Ethernet in each board also removes the requirement for a dedicated, complex backplane protocol. This significantly simplifies the internal design of each board and enables straightforward scalability: if an instrument requires more boards, they simply connect to the network switch. For video boards, a Gigabit Ethernet link provides approximately 110 MB/s of effective throughput. As shown in **Table 2**, even a single connection exceeds current NOIRLab requirements, with the fastest existing system (NEWFIRM) peak at 62 MB/s. Multiple video boards can share the same switch and still operate with a single host downlink.

For future multi-channel, higher-speed systems—such as H4RG arrays or multiple Skipper devices—expanding the bandwidth is straightforward. As indicated by the **grayed-out shapes in Figure 1**, adding a second switch and a second downlink simply entails adding a second receiving computer. Adopting Ethernet further decouples the software layer from any device-specific drivers or proprietary languages for data reception.

To summarize, using commercially available Ethernet transceivers and modules provides a robust, well-tested downlink for both commands and data. This approach avoids the maintenance burden inherent in custom protocols or fiber-based host boards, which historically represent a significant point of failure and obsolescence. **Ethernet remains universal and backward-compatible**, and because most modern SoC/SoM platforms include native, mature Ethernet support, the integration risk is minimal.

### **2.2.2 Backplane** {#2.2.2-backplane}

Most controllers implement a complex backplane to share signals (clocks, ADC/video conversion, timing, parallel buses for the detector clocks, inter-board communications, etc.). Our proposal is to reduce the backplane to a minimal set of lines, so the system grows naturally—just add boards, without new addresses, slots, or protocol layers. In **Figure 1**, the backplane is represented by the orange line.

Because inter-board communications are handled over Ethernet, no separate backplane protocol or board addressing is required (beyond IP). Synchronization relies on distributing a single master clock and running (largely) the same code on each board; if all boards start on the same clock edge, required signals land at the right times. Consequently, the proposed backplane has **six** logical lines:

1. **Clock:** A **10 MHz LVDS reference clock** is shared; all other boards derive local high-frequency sequencer clocks from it to remain in phase.  
2. **Sync:** A global trigger signal that asserts image-readout “start” to align all distributed sequencers.  
3. **Enable:** A global signal used to enable or disable the power outputs of the modules.  
4. **Safety Interlock (Active Chain):** A daisy-chained interlock topology where each board receives an incoming fault signal and generates an outgoing signal as a logical **AND** of the incoming signal and its own health status. Any board fault (or physical disconnection of a board) breaks the chain, propagating an immediate system-wide safe state to protect the detector.  
5. **DC Power:** Raw \+12 V input from which each board derives its power rails.  
6. **GND Return:** Common ground reference.

This hybrid approach removes a data backplane, simplifies mechanics, and adds robust system-level fault detection. The physical backplane—including connector types and slot counts—will be defined in upcoming **Interface Control Documents (ICDs)**. The design is intended to be a selectable option, supporting various form factors and slot counts without changing the board architecture.

These are logical lines; physically, there may be multiples (e.g., several VCC and GND conductors).

### **2.2.2 Boards** {#2.2.2-boards}

Function boards have defined detector-specific roles. Video boards perform analog acquisition and application-specific processing, such as digital CDS, decimation, or window selection, before sending their supported data products directly to the host over Ethernet. Clock and bias boards provide their respective detector-facing functions. ADR-006 defines the data path; processing and link capacity belong to the application ICD.

The **Main Board (MCB)** coordinates arming and recovery through `EN`, `CLEAR`, `OK`, and `LOOP_IN`, distributes `CLOCK` and `SYNC`, and supplies backplane utility-converter synchronization. It does not execute detector sequencers or carry science data. Detector-specific and instrument utility functions belong to function boards, as defined by ADR-003.

Because every board includes its own independent Ethernet interface, the host computer can upload the specific sequencer code directly to each unit. This decentralized approach avoids centralizing sequencer responsibilities on the Master Board and ensures a uniform, simple design across the system. This reflects the core design principle that **any function that can be safely performed by the host should be offloaded there**, keeping the controller hardware lean and reliable.

## **2.3 Boards General Block Diagram** {#2.3-boards-general-block-diagram}

Boards share standard power, safety, timing, and communication contracts while selecting processing hardware, Ethernet capacity, and front-end electronics for their applications. Common interfaces do not require identical internal circuitry.

Mezzanines are an optional board implementation technique. Standard backplanes generate the shared analog utility rails; function boards may consume these rails or convert protected `+12V` locally. Layout separates sensitive analog circuitry from switching conversion and fast digital signals.

Every standard backplane provides protected `+12V` and fixed-pin `±6V_ANA` and `±16V_ANA` rails. Function-board consumption is optional; filtering and local regulation are selected against power, noise, and thermal budgets. Main supplies the utility-converter synchronization defined by ADR-005. Acquisition timing uses the directly distributed 100 MHz sequencer clock and point-to-point `SYNC` defined by ADR-004; management and safety clocks remain independent.

Figure 2 is a conceptual illustration of board functions, not a mandatory hardware partition. Processing, power, and timing implementations may differ between boards; the current ADRs define the shared interfaces.

***Figure 2: general boards diagram***

### **2.3.1 Common Modules** {#2.3.1-common-modules}

Common board functions include processing, communications, local power, timing reception, and independent safety hardware. They may be integrated or modular. Ethernet carries commands, telemetry, and application data at an application-selected rate, which may be 100 Mb/s, 1 Gb/s, or another supported capacity. No link speed is mandated by board role.

Timing hardware receives the distributed 100 MHz `CLOCK` and acquisition `SYNC` directly; no board PLL multiplying a 10 MHz backplane reference is required by the architecture. ADC sampling rate and its relationship to sequencer events are application-specific. Power hardware uses shared analog utilities and/or local conversion from protected `+12V`. A dedicated safety CPLD may implement the independent watchdog and other interlock functions under ADR-001, with independent interlock-supply supervision and verified safe failure behavior.

The intelligence of each board is hosted on a commercial **System-on-Module (SoM)** (processing unit plus RAM/EEPROM in figure 2). To minimize software overhead and ensure strictly deterministic timing for detector control, this unit runs bare-metal firmware rather than a complex operating system. The SoM hosts the lightweight IP stack for communications and the "sequencer core" gateware that directly controls the hardware pins. **Using a standardized SoM socket allows the processing core to be upgraded to newer devices**, such as Zynq or PolarFire SoCs, without the need to redesign the complex carrier board. Supporting this intelligence is a dedicated non-volatile Configuration Memory (EEPROM/Flash), which stores board-specific identification data including the IP address, board type, and revision. This allows the system software on the host computer to automatically detect, identify, and configure every board in the chassis immediately upon boot-up, supporting identification and maintenance; operational hot-swap is not supported under ADR-001.

### **2.3.2 Front End Electronics (FEE)** {#2.3.2-front-end-electronics-(fee)}

The Front-End Electronics (FEE) represents the board-specific portion of the architecture, where the generalized processing core meets the specialized requirements of different detector types. The guiding principle for this section is to maintain a **strictly defined interface** between the common digital backplane and the FEE, allowing for rapid updates to newer components without redesigning the entire system. Because the basic designs for most FEE stages are already well-proven, the focus remains on modernization and obsolescence management rather than reinventing core topologies.

#### ***2.3.2.1 Video Boards*** {#2.3.2.1-video-boards}

Video boards are designed to handle both optical and NIR/CMOS signal chains through two primary methodologies. For **optical CCDs**, a classical analog video chain utilizes low-noise instrumentation amplifiers as a first stage, followed by an analog Correlated Double Sampling (CDS) integrator and an ADC. Alternatively, a digital approach bypasses the analog integrator by feeding the instrumentation amplifier directly into a high-speed differential ADC. **NIR and CMOS systems typically follow this digital chain architecture**, where any necessary difference processing is handled downstream in the digital domain. ADC samples may be processed locally into application-defined data products before transmission through the board’s Ethernet endpoint; sampling rate and link capacity are application-specific. While 4-channel boards provide sufficient density for most optical instruments, the architecture supports 8-channel configurations for high-density NIR systems, ensuring that total bandwidth is scaled by adding boards rather than complicating individual board design.

#### 

#### ***2.3.2.2 Clock Boards*** {#2.3.2.2-clock-boards}

The FEE for clock generation consists of buffers and DAC converters that define the voltage levels, which are then switched by multiplexers driven by the sequencer's GPIO. This design prioritizes flexibility, allowing for simple level shifting or more sophisticated waveform shaping and telemetry depending on the detector's needs. **Optical CCDs require bipolar clock levels, often reaching ±15V**, while NIR and CMOS detectors generally utilize unipolar levels at 5V or 3.3V. Clock-board Ethernet capacity is selected for the application’s control, telemetry, and supervision traffic; 100 Mb/s is one possible implementation.

#### ***2.3.2.3 Bias Boards*** {#2.3.2.3-bias-boards}

Bias boards provide the stable DC voltages required to polarize detector outputs and must deliver sufficient current to maintain performance under load. Following the philosophy of simplicity and modularity, **biases are implemented as a standalone board** rather than being integrated into video or clock circuitry. This separation provides ample physical space for high-quality telemetry and prevents sensitive bias levels from being affected by the high-speed switching of the clock drivers. For optical devices, these boards can be configured for bipolar operation up to 25V, with specialized versions reaching 100V for fully depleted substrates. Bias-board processing hardware and Ethernet capacity are application-dependent; an STM32 and 100 Mb/s link are possible implementation choices.

#### ***2.3.2.4 Master Board*** {#2.3.2.4-master-board}

The **Main Board (MCB)** coordinates arming and recovery through `EN`, `CLEAR`, `OK`, and `LOOP_IN`, distributes `CLOCK` and `SYNC`, and supplies backplane utility-converter synchronization. It does not execute detector sequencers or carry science data. Detector-specific and instrument utility functions belong to function boards, as defined by ADR-003.

## **2.4 Sequencer/Readout** {#2.4-sequencer/readout}

The processing unit on each board contains a standardized core that implements identical functions across the system, including Ethernet stack management, command processing, and a dedicated memory region for sequencer code. By utilizing a "decentralized" execution model, the system achieves complex coordination without requiring a master controller to manage every pulse.

In the standard operating mode, the sequencer code is identical for every video and clock board. The output of this code is a parallel bus (GPIO) that generates the clock phases and ADC conversion triggers. **Because every board runs on the same phase-aligned clock, the system-wide SYNC signal ensures that every sequencer executes in lock-step.** When a readout sequence begins, the clock boards generate their respective phases and the video boards trigger their integration and conversion cycles at the exact same moment. This synchronization occurs naturally through the shared timing reference, removing the need for boards to communicate with one another during a transition.

Each video board operates as an independent data source, streaming its pixel data through its own Ethernet interface. The host computer then assumes the responsibility of sorting and reassembling the image based on the source IP addresses. For more specialized applications, this architecture allows the host to distribute unique code to different boards. For example, one clock board could be configured to output only parallel phases while another handles only serial phases. This flexibility allows the system to be tailored to specific detector geometries while maintaining a **common hardware and firmware baseline**.

## **2.5 Architectural Notes** {#2.5-architectural-notes}

The design considerations for the NOIRLab Detector Controller are rooted in long-term sustainability, precision performance, and fiscal responsibility. By moving away from monolithic designs, this architecture ensures that the system can evolve alongside detector technology rather than being rendered obsolete by a single component's end-of-life.

**Modular Architecture Mitigates Obsolescence:** Standard board interfaces support replacement and evolution of individual implementations. Ethernet capacity is chosen for each application’s data products, processing, buffering, control, and supervision requirements. A video board does not inherently require 1 Gb/s, and a control board is not restricted to 100 Mb/s.

**SoM-Based Flexibility and Longevity:** By defining only the processor-unit interface in our architecture standard, any SoM can be integrated, ensuring future migrations to next-generation SoCs require minimal hardware redesign. This abstraction layers the system's intelligence, allowing us to leverage vendor roadmap assurances and long-term supply commitments that provide a guaranteed ten-year technology lifecycle. This strategy effectively "future-proofs" the controller's brain.

**EMC and Low-Noise Physical Layout:** Digital and switching-converter circuitry is separated from sensitive analog circuitry. Shared-rail consumers provide board-entry conditioning against incoming disturbances and outgoing conducted emissions. Filter and regulator topology are board-design choices verified against the shared-rail interface and detector-noise requirements in ADR-005.

**Open-Source Ecosystem and ROI:** We prioritize an open-source toolchain to maximize community review and reuse. All design files—including schematics, layouts, and HDL code—are released under OSI-approved licenses. This approach provides a compelling Return on Investment (ROI) by significantly reducing direct development and QA costs through community contributions.

# **3.- Prototyping** {#3.--prototyping}

Earlier prototyping work explored power-management and clock/synchronization mezzanines as reusable building blocks. These are implementation examples; the current ADRs define shared backplane power and direct 100 MHz timing distribution.

Prototype power and timing hardware must be validated against the current interfaces, noise, power, and timing budgets before integration into function boards.

**Next Milestone:** Validate a four-channel video-board implementation against the current power, safety, timing, and application-specific data-transport contracts.

# 

# **Appendix A** {#appendix-a}

1. [Detector System Inventory for AURA](https://docs.google.com/spreadsheets/d/1xhiuAg_WzDHXfP1aNfx-rzMJFSdcwyWxjbFj4VP8cTI/edit?usp=sharing)   
2. Controllers:  
   1. [MONSOON Controller information](https://noirlab.edu/science/programs/ctio/ccd-controllers/monsoon/What-MONSOON)   
   2. [ESO Detector controller information](https://www.eso.org/sci/facilities/develop/detectors/controllers.html)   
   3. [Low Threshold Acquisition controller](https://lss.fnal.gov/archive/2020/pub/fermilab-pub-20-180-ae-scd.pdf)  
3. [Common Mezzanine Modules design report](https://docs.google.com/document/d/1oKW6-eBUfSovnxKBEUYCuKsL65J-khK8RRH2-YRRKgU/edit?usp=sharing)  
4. [Trenz Zynq module](https://wiki.trenz-electronic.de/display/PD/TE0720+TRM)

[image1]: <data:image/png;base64,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>
