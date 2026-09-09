

# 

# Obsolescent Detector Controller Phase II

# Project Mandate

**Author(s): NOIRLab-ES Detector Group**  
**Project Reference Code**   
Release Version: 1.0  
Release Date: 20250909  
Distribution: Internal Use

**Approvals** 

| Title: Obsolescent Detector Controller Replacement Strategy Study |  |
| :---- | :---- |
| **Author(s)**  | **Release Date**  |
| Marco Bonati | 2025-09-09 |
| [Braulio Cancino](mailto:braulio.cancino@noirlab.edu) |  |
| **Document Owner**  | **Approval Date**  |
| Marco Bonati | 2025-09-09 |
| **Approved By** | **Signatures/Stamp** |
| [Felipe Daruich](mailto:felipe.daruich@noirlab.edu) NOIRLab Head of Electrical Engineering (sponsor) |   |
| [Michiel Van Der Hoeven](mailto:michiel.vanderhoeven@noirlab.edu) NOIRLab ES Director |  |

**Change Record**

| Release Version  |  Release Date |  Description | Change Owner |
| :---- | :---- | :---- | :---- |
| Draft | 2025-09-01 |  First Draft | Marco Bonati |
|  1.0 |  2025-09-09 |  Final version before submission |  Marco Bonati |
|   |   |   |   |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |

**Table of Contents**

[**Purpose / Scope of Document	4**](#purpose-/-scope-of-document)

[**Project Definition	5**](#project-definition)

[Project Background	5](#project-background)

[Project Objectives	5](#project-objectives)

[Constraints	6](#constraints)

[Assumptions	6](#assumptions)

[**Outline Business Case	7**](#outline-business-case)

[Reasons and Benefits for doing this project	8](#reasons-and-benefits-for-doing-this-project)

[Potential Downsides (dis-benefits)	9](#potential-downsides-\(dis-benefits\))

[Business Option Analysis	9](#business-option-analysis)

[**Project Approach	10**](#project-approach)

[​Recommended Approach	10](#​recommended-approach)

[Needed Project Resources for Completion	11](#needed-project-resources-for-completion)

[Project Scope	11](#project-scope)

[High Project Risks	12](#high-project-risks)

[**Proposed Project Tolerances	13**](#proposed-project-tolerances)

[**Project Baseline	13**](#project-baseline)

[Deliverables	13](#deliverables)

[Resource Plan	13](#resource-plan)

[**Appendix A.  Applicable Reference Documents \- Associated Products	15**](#appendix-a.-applicable-reference-documents---associated-products)

[**Appendix B. List of Acronyms	16**](#appendix-b.-list-of-acronyms)

# **Purpose / Scope of Document** {#purpose-/-scope-of-document}

The purpose of this project is to mitigate both the near-term and long-term risks to the operational reliability and maintainability of detector controller technology across AURA observatories. **The risk of obsolescence has increased significantly in the past 24 months, primarily due to the closure of Astronomical Research Cameras, Inc. (ARC)**—a major supplier of detector controllers—and is further compounded by the proliferation of more than 17 distinct controller technologies across 117 active systems. This diversity creates substantial challenges for maintenance, spare-part management, and staff expertise.

The scope of this mandate is to transition from feasibility analysis into the structured execution of a replacement strategy. Building upon the 2025 Project Report (obsolescence study), which delivered an architecture, rationale, and the completed design of a prototype video board, this mandate commits to:

* **Defining** a cost-effective, modular, and scalable controller platform capable of supporting both current instruments (e.g., up to 256 channels), future detectors (e.g., Skipper CCD mosaics, H4RG-class NIR devices, potentially requiring 512+ channels) and massive multi-controller instrumentation (similar or bigger than SCORPIO), etc).  
* **Documenting** functional and performance requirements (FPRD) and system architecture through controlled deliverables.  
* **Supporting** an open-source, collaborative development model, leveraging contributions from peer observatories (Fermilab, GMTO, Harvard, University of Hawaii SSEI group) to reduce costs and accelerate innovation.  
* **Establishing** a long-term pathway to mitigate obsolescence, improve maintainability, and ensure continuity of detector operations across AURA observatories.

This scope addresses both the immediate necessity of replacing obsolete ARC and Torrent controllers and the strategic opportunity to unify NOIRLab’s detector technology under a single, flexible architecture. This phase focuses on design, documentation, and laboratory validation, while full system integration and on-sky testing are reserved for subsequent phases. By doing so, it reinforces NOIRLab’s leadership in astronomical instrumentation and secures the observatories’ scientific productivity for the next decade and beyond.

# 

# **Project Definition** {#project-definition}

## **Project Background** {#project-background}

The closure of **Astronomical Research Cameras, Inc. (ARC) in 2023** exposed the vulnerability of our detector controller infrastructure. ARC systems remain in use at multiple AURA observatories and account for roughly **25% of all operational instruments.** With no vendor support and a dwindling stock of spares, these controllers now pose a critical risk to operational reliability. In parallel, MONSOON systems, still heavily relied upon, employ obsolete components despite their required operational lifetimes extending beyond this decade.

Compounding this challenge, NOIRLab and AURA observatories collectively operate **117 controllers across 17 distinct technologies,** each with varying levels of support, documentation, and available expertise. This uncontrolled diversification, combined with localized and non-transferable knowledge, increases the likelihood of downtime and raises the cost and complexity of sustaining detector operations.

The **2025 Project Report by the NOIRLab Detector Group** provided a comprehensive survey of all controllers, their maintainability, and associated risks. It concluded that a **unified, modular, open-source controller architecture is the only viable long-term path forward.** Such an approach reduces technology diversity, mitigates obsolescence, and strengthens maintainability across observatories.

Peer institutions—including Fermilab, GMTO, Harvard, and the University of Hawaii SSEI group—share these concerns and have expressed strong interest in collaborating on an open, flexible architecture. This collective effort promises to lower costs, expand the engineering knowledge base, and accelerate deployment of a next-generation controller platform.

Building on this consensus, NOIRLab has **completed the design of a prototype 4-channel ADC video board** based on a Zynq SoM platform. This design illustrates the feasibility of the Ethernet-based, modular architecture described in the 2025 report. Fabrication and **laboratory testing of this board along with the design of complementary clock, bias, and master boards, will be part of the present mandate.**

This mandate therefore defines **Phase II of the program:** moving beyond background studies and prototype designs into a structured development path, with clear objectives, committed resources, and collaborative frameworks for delivering a scalable, maintainable, and future-proof detector controller system. Full system integration as well as clock, bias and master board implementation and on-sky testing will be carried out in **subsequent phases.**

## **Project Objectives** {#project-objectives}

The primary objective of this project is to deliver a clear pathway and actionable plan for the development of a new, generic detector controller architecture that addresses both the current risks of obsolescence and the needs of future instrumentation. Specifically, the objectives of Phase II are:

* **Produce a Functional & Performance Requirements Document (FPRD)** that captures the operational, temporal, and interface requirements of existing and emerging detector systems.  
* **Define a modular system architecture** with controlled Interface Control Documents (ICDs) that allow incremental expansion and independent module upgrades.  
* **Advance the design work by completing the prototype suite of boards:** extending to the clock, bias, and master board designs based on the already designed 4-channel ADC video board.  
* **Fabricate and validate the video board through laboratory testing,** including functional testing with all the submodules and artificial video data. Laboratory testing with a real CCD, as well as on-sky integration and system-level validation will be part of subsequent phases.

These objectives move beyond the earlier focus on producing only a pathway document, expanding the mandate to include concrete architectural work, specific ICDs, prototype design, fabrication, and laboratory validation.

## **Constraints** {#constraints}

This project will be carried out principally by NOIRLab-ES engineers with specialization in detectors, electronics design, and project management. While primary responsibility rests within NOIRLab, engineering resources and expertise from other observatories may be consulted to ensure commonality of the architectural design and alignment with stakeholder needs.

Constraints include the limited availability of key staff due to their operational responsibilities and the challenge of balancing project tasks with ongoing observatory support. To accommodate this, a 30% contingency buffer is included in delivery estimates to cover scheduling conflicts.

Overall, the constraints are primarily organizational and resource-based rather than technical. The architecture relies on proven design principles, commodity hardware (Ethernet, SoM modules), and existing in-house expertise, all of which reduce technical risk.

## **Assumptions** {#assumptions}

Several key assumptions guide this project:

* **Resource Availability**: NOIRLab-ES engineers will balance project tasks with ongoing operational responsibilities. A 30% contingency in schedule is assumed to accommodate competing demands.  
* **Technology Readiness**: Advances in System-on-Modules (SoMs), Ethernet networking, FPGA/ARM hybrids, and modern DC/DC converters allow significantly shorter development cycles compared to ARCON and MONSOON eras.  
* **Testing Infrastructure**: NOIRLab’s detector laboratories are assumed to be sufficient for Phase II validation

These assumptions provide the basis for realistic planning, ensuring that the scope of Phase II remains achievable within available resources, while anticipating collaborative and technological opportunities in later phases.

# **Outline Business Case** {#outline-business-case}

The obsolescence of ARC and MONSOON systems, combined with the proliferation of 17 controller technologies across 117 total units, presents a **systemic risk** to observatory operations. Without intervention, downtime, rising maintenance costs, and loss of technical expertise will increasingly undermine NOIRLab’s ability to deliver reliable science.

The **2025 Project Report** confirmed that the most cost-effective, future-proof strategy is **Option 5: in-house development of a modular, scalable, open-source controller platform.** This approach directly addresses obsolescence while reducing technology diversity, enabling maintainability, and providing a platform adaptable to future instrumentation.

**Key Business Drivers:**

* **Operational Continuity**: Prevents loss of observing time due to failures in obsolete ARC, Torrent, MONSOON and various other control systems.  
* **Cost Avoidance**: Commercial replacement with systems such as Archon would cost over $480k for ARC units alone and would not scale to future detector requirements. The modular architecture lowers both upfront and lifecycle costs. It would also lock us with an external supplier, exactly as we were with the  ARC vendor.   
* **Future-Proofing**: Supports next-generation detectors (e.g., Skipper CCDs, H4RG-class arrays) requiring hundreds of video channels beyond the capacity of any current commercial controller.  
* **Knowledge Retention**: Preserves and strengthens in-house detector engineering expertise, ensuring continuity as staff retire.  
* **Open Collaboration**: Creates opportunities to share costs and accelerate development with peer institutions (Fermilab, GMTO, Harvard, University of Hawaii SSEI group), with broader community participation expected in later phases.

**Return on Investment:**

* Unit cost projected at less than half that of commercial alternatives like Archon.  
* Reduced maintenance costs through standardization and simplification.  
* Extended lifecycle of at least 10 years per module, with modular upgrades to mitigate obsolescence.  
* Open-source framework ensures adaptability, transparency, and freedom from vendor lock-in.  
* NOIRLab becoming a hub of detector controller development across multiple institutions

**Conclusion:** The business case strongly supports proceeding with **Phase II**: formalizing requirements, designing the modular architecture, fabricating and testing prototypes in the laboratory, and publishing controlled documentation. This will safeguard operations, reduce costs, and position NOIRLab as a leader in community-driven detector controller technology.

## 

## **Reasons and Benefits for doing this project** {#reasons-and-benefits-for-doing-this-project}

The success of NOIRLab’s observatories depends on maintaining uninterrupted, high-quality detector operations. Detector controllers are among the most complex and unique components of this chain, and their obsolescence poses one of the highest single-point failure risks. The reasons and benefits for pursuing this project are therefore both operational and strategic:

**Reasons:**

* **Operational Reliability**: Prevent loss of observing time and scientific productivity caused by failure of obsolete ARC, MONSOON, Torrent, and other unsupported controller types.  
* **Technical Risk Mitigation**: Eliminate dependence on vendor-locked, proprietary systems and ensure a robust, maintainable controller infrastructure.  
* **Future Instrumentation Needs**: Address the requirements of next-generation detectors such as Skipper CCD mosaics and H4RG-class NIR arrays, which demand hundreds of video channels not supported by any current commercial solution.  
* **Staff Knowledge Continuity**: Preserve and expand in-house detector engineering expertise, ensuring that knowledge is not lost as staff retire or transition.  
* **Community Alignment**: Coordinate with peer institutions facing similar challenges, fostering collaboration and resource sharing.

**Benefits:**

* **Prestige and Scientific Productivity**: Reliable operations maintain NOIRLab’s reputation and competitive advantage as a provider of forefront astronomical data.  
* **Cost Efficiency**: The in-house modular controller is projected to cost less than half the unit cost of commercial systems like Archon, while being more flexible and scalable.  
* **Sustainability**: A modular, open-source design ensures a lifecycle of at least 10 years per module, with incremental upgrades mitigating obsolescence.  
* **Collaboration and Open-Source Innovation**: Partner contributions (Fermilab, GMTO, Harvard, University of Hawaii SSEI, and others) will expand functionality and reduce development time and costs, particularly in later phases.  
* **Leadership Role**: Establishes NOIRLab as a leader in community-driven instrumentation technology, reinforcing commitments outlined in the ITDC survey and five-year plan.

**In summary, Phase II provides immediate relief from obsolescence risks while laying the groundwork for long-term flexibility and sustainability. By moving forward now, NOIRLab secures continuity of operations and ensures leadership in detector controller technology, with subsequent phases completing system integration and on-sky validation.**

## 

## **Potential Downsides (dis-benefits)** {#potential-downsides-(dis-benefits)}

The potential downsides of this project are limited. A dedicated staff within the Detector Group is already engaged, and the primary requirement is **sufficient time over next year**  to fabricate  and test the video board, and to design clock, bias, and master boards..

Collaboration risks are minimal at this stage, as NOIRLab is fully responsible for delivering the first functional prototypes. Broader external participation is expected only in subsequent modules, once the foundation has been validated.

**In summary, the principal risk lies in scheduling and staff availability rather than technical feasibility or external collaboration.** This reinforces the importance of managing resources and maintaining focus during Phase II.

## **Business Option Analysis** {#business-option-analysis}

To address the obsolescence challenge, five options were evaluated:

* **Option 1 – Do nothing**: No additional cost, but unacceptable risk of downtime and loss of observing capability.  
* **Option 2 – Specialize in repairs**: Builds local expertise, but unsustainable due to component unavailability and does not prepare for future instrumentation.  
* **Option 3 – Redesign obsolete boards with modern parts**: Improves readiness for specific cases but is resource-intensive and only addresses single points of failure.  
  **Option 4 – Buy commercial controllers**: Defers capital until failure, but costly over time, increases technology diversity, and re-introduces vendor lock-in.  
  **Option 5 – Develop in-house modular controller**: Chosen option. Provides a unified, scalable, open-source platform; reduces system diversity; ensures maintainability; supports current and future detectors; and maximizes return on investment.

**Conclusion:** **Option 5 is the only sustainable and cost-effective path**. It gives NOIRLab full control of architecture and lifecycle, ensures long-term maintainability, and positions the observatories to meet both current and future detector requirements. Phase II focuses on establishing this foundation through design, fabrication, and laboratory validation of prototypes, while upcoming phases will deliver full system integration and on-sky testing.

# 

# **Project Approach** {#project-approach}

**Phase II will focus on finalizing requirements, defining the modular architecture, and advancing into the fabrication and laboratory validation of prototype boards.** Laboratory validation will include electrical testing and functional testing in NOIRLab’s laboratory facilities.

This phase does not include actual detector testing, full system integration or on-sky testing—those activities are explicitly reserved for next phases. By separating these phases, the project reduces risk and ensures that only fully validated designs progress to system-level implementation.

The approach emphasizes iterative progress, strong documentation control, and the use of NOIRLab’s in-house expertise and laboratory infrastructure. It provides the framework to transition from feasibility studies into concrete prototype designs, laying the foundation for the next phases, when full integration and on-sky validation will be conducted.

A flexible schedule will be maintained, supported by regular bi-weekly coordination meetings. **Testing during Phase II will be limited to laboratory validation in NOIRLab’s facilities.**

## **​Recommended Approach** {#​recommended-approach}

The recommended approach ensures that Phase II establishes the foundation of the new controller architecture while advancing into fabrication and laboratory validation of prototype boards. This phase will deliver the controlled documents and validated prototypes required to confidently proceed to Phase III.

**Phase II (Current Mandate) Goals:**

* Produce the **Functional & Performance Requirements Document (FPRD)** to capture all detector, timing, and system requirements.  
* Define the **modular system architecture** and prepare **Interface Control Documents (ICDs)** covering module boundaries, communication protocols, and host interfaces.  
* Complete **detailed designs for all core board types** (video, clock, bias, master) following the common-module structure defined in the Project Report.  
* **Fabricate prototype video board** and perform laboratory validation. The testing will be done module by module (each module has been  already defined on Phase I of this project) , then testing  the FEE, and finally a full board test, including sequencer (Zynq) full code and low level  software (API) interface. The development will then follow a **modular and iterative approach.**  
* Establish controlled documentation: FPRD, ICDs and prototype design reports, all based on the experience/corrections done during the iterative hardware testing.

**Summary:** Phase II is focused on requirements, modular architecture, and the design, fabrication, and laboratory validation of prototype video boards. Subsequent phases  will deliver full system integration, CCD laboratory testing  and operational on-sky testing. This staged approach reduces risk, ensures thorough validation, and positions NOIRLab for long-term success in detector controller development.

## **Needed Project Resources for Completion** {#needed-project-resources-for-completion}

| Needed Project Resources for completion |  |
| ----- | :---- |
| **Specific Competencies /Skills /People needed (all part time)** | 1 Electronics Engineer: Detector specialist. 2 Electronics Engineers: Electronic design. 1 Electronic technician. |
| **Internal labor effort (FTE) until completion** | 0.6  FTE total. |
| **Non-labor Cost (USD)** | 10,000 USD for performance testing of COTS modules and components / boards |
| **Project Duration (Months)** | 11.0 Months. |
| **Impact on Telescope Operations** | Zero Impact. |
| **Contract Complexity** | No formal interaction required between project players and external entities. |
| **Track Record** | Yes; Two successful projects similar in nature have been completed and deployed within NOAO/CTIO. Same personnel envisaged. |
| **Infrastructure** | Electronic and detector laboratory infrastructure and equipment, all already in place. |
| **Technology/ Standards** | Commercial System-on-Modules (SoMs), Ethernet networking, FPGA/ARM hybrids, and modern DC/DC converters. Open source design and deployment tools. |
| **Recurring Costs** | No recurring costs however, a successful completion of this project will lead to a further project mandate for more boards building and tests. |

## **Project Scope** {#project-scope}

There will be four parallel lines of work (threads):

* Test designed video board  
  * Define submodules to be manufactured on the already designed video board.  
  * Manufacture sub-modules (boards manufacturing) and assemble/test one by one   
  * Assemble all modules for a system-wide test (full board).  
  * Test a full system with artificial video data. This part will require the software thread to be done.  
* Software development  
  * Define registers / addresses / ports on SoM.  
  * Define and implement low level functions based on register definitions.  
  * Define and implement Ethernet-based low level functions and system  call / callbacks.  
  * Define and implement communications protocol / hand shaking / TCP packages.  
  * Implement some simple host-based client.  
* Design remaining base prototype boards:  
  * Design clock FEE (common modules should be identical to those already designed and in-testing on the video board.  
  * Design FEE bias board.  
  * Design Master board.  
* ICD and FPR definition and writing:  
  * Once the video board has been tested / redesigned so it works as expected, define and write detailed ICD and FPR documents. Retrofit documentation onto clock, bias and master board designs.

## **High Project Risks** {#high-project-risks}

The primary project risk is insufficient prioritization, which could prevent participants from dedicating the necessary time. Technical risks are minimal, as all technologies involved are well-established. While new designs might cause delays, none are considered high-risk.

# 

# **Proposed Project Tolerances** {#proposed-project-tolerances}

| Project Area | Baseline value | Proposed Project Tolerance |
| ----- | :---: | ----- |
| Time (+/- time on target completion dates) | 11.0 Months | 1.0 months due to unforeseeable lack of time from personnel |
| Costs (+/- amounts of planned budget) | 10,000 USD | Plus zero / minus 50% |
| Scope (permitted scope variations) | full scope of deliverables  | Zero tolerance on scope. |
| Risk (permitted aggregate/individual threat value) | N/A |  |
| Quality (permitted quality variations within a range) | full scope of deliverables | Zero tolerance on scope. |
| Benefits (permitted benefit variations within a range) | N/A |  |

Whenever the tolerance for one of these baseline values is exceeded (or forecasted to be exceeded), the Project Advisory Board (PAB) should be alerted of the exception.

# **Project Baseline**  {#project-baseline}

## **Deliverables** {#deliverables}

1. Document \- Functional performance requirements (FPRD) (controlled).  
2. Document \- Definition of interfaces between modules  \- Interface Control Documentation (ICDs) (controlled).  
3. Working video board prototype (in lab.)  
4. Design of clock, bias and master boards  
5. Software low-level  interface design and partial implementation  
6. Document \- Project completion and report.

   

## **Resource Plan** {#resource-plan}

**Labor plan**

| Resources  (Hours) | Month Oct | Month Nov | Month Dec | Month Jan | Month Feb | Month Mar | Month Apr | Month May | Month Jun | Month Jul | Month Ago | Sub Total) |
| ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- |
| Braulio Cancino. Electronics Engineer.  | 24 | 36 | 36 |  36 |  36 | 24  |  24 |  24 |  24 |  24 |  56 |  |
| Marco Bonati. Detector Engineer. |  24 | 36 | 36 | 36 |  36 |  24 |  24 |  24 |  24 |  24 |  56 |  |
| Norman Diaz Electronic Engineer. | 24 | 36 | 36 | 36 | 36 | 24 | 24 | 24 | 24 | 24 | 56 |  |
| Marcel Taiba Electronic technician |  0 | 30 |  30 | 30 | 30 |  24 |  24 |  24 |  24 |  24 |  0 |  |
| **Monthly Totals** |  72 |  138 | 138 |  138 | 138 | 96 |  96 |  96 |  96 |  96 |  168 |  |
|  |   |   |   |   |   |   |   |   |   |   |   |  |
| **Total Hours \-  2025   .**           |  |  |  |  |  |     1272 |  |  |  |  |  |  |

**Non-labor plan**

| Non-labor Costs (K USD \- committed) | Month Oct | Month Nov | Month Dec | Month Jan | Month Mar | Month  | Month  | Month  | Month  | Month  | Month  | Month  | Sub Total (k$) |
| ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- |
| COTS devices for performance testing |  2.0 |  2.0 |  2.0 |  2.0 |  2.0 |   |   |   |   |   |   |   |  |
|  |   |   |   |   |   |   |   |   |   |   |   |   |  |
| **Total  Non-Labor k$**  |  |  |  |  |  |  |  |    10.0 USD |  |  |  |  |  |
| **Risk budget :** |  |  |  |  |  |  |  |        0 |  |  |  |  |  |
| **Change Budget:** |  |  |  |  |  |  |  |        0 |  |  |  |  |  |

     

# **Appendix A.  Applicable Reference Documents \- Associated Products** {#appendix-a.-applicable-reference-documents---associated-products}

| Document Number / Link / Identifiers | Document Title |
| :---- | :---- |
| [NSF 21-107 (December 2021\)](https://www.nsf.gov/publications/pub_summ.jsp?ods_key=nsf21107) | NSF Research Infrastructure Guide |
| [Link](%20https://drive.google.com/file/d/1VoREp4LqIGmzkzEefz99-uvmBefDsx-Z/view?usp=sharing)     \-  | Obsolescence controller study report (Phase I) |
| [Link](https://drive.google.com/file/d/1YQQJNa59cVHOlFnF5fFR3BAfqpYymjsT/view?usp=sharing)    \- | CCD Controllers in 2024: A Survey for GMACS |
| [Link](https://docs.google.com/spreadsheets/d/1xhiuAg_WzDHXfP1aNfx-rzMJFSdcwyWxjbFj4VP8cTI/edit?gid=0#gid=0)    \- | Detector system inventory of AURA |

# 

# 

# **Appendix B. List of Acronyms** {#appendix-b.-list-of-acronyms}

* ARC	: 	Astronomical Research Cameras Inc.  
* AURA	: 	Association of Universities for Research in Astronomy  
* CMP	: 	Configuration Management Plan  
* ICD	:	Interface Control Document  
* FPRD	: 	Functional Performance Requirements Document

# 

# 

