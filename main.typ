#import "template.typ": capstone-report, back-matter-heading

#show: capstone-report.with(
  title: "Title of the project",
  course-code: "<Course code>",
  course-name: "Capstone Project <Phase placeholder>",
  academic-period: "<Academic period>",
  footer-period: "<Footer period>",
  semester: "<Semester word>",
  semester-ordinal: "<Semester ordinal>",
  // Replace with the logo from the university's official documents.
  logo-path: "logo.png",
  students: (
    (name: "Student One", srn: "<SRN>"),
    (name: "Student Two", srn: "<SRN>"),
    (name: "Student Three", srn: "<SRN>"),
    (name: "Student Four", srn: "<SRN>"),
  ),
  guide: (
    name: "Guide Name",
    designation: "Designation",
  ),
  chairperson: "Chairperson Name",
  registrar: "Registrar Name",
  coordinator: "Coordinator Name",
  founder: "Founder Name",
  chancellor: "Chancellor Name",
  vice-chancellor: "Vice-Chancellor Name",
  pro-vice-chancellor: "Pro Vice-Chancellor Name",
  abstract-body: [
    Write your abstract here in no more than two paragraphs (maximum 150 words). Summarize the core problem, the architectural approach, key implementation highlights, and primary experimental findings using SI units.

    Keep the second paragraph focused on quantitative evaluation results, performance improvements, and practical utility of the completed system.
  ],
)

= Introduction
== Background and Motivation
Modern analytical workloads increasingly demand sub-second query latencies over tens of millions of records @dorsey2019. Traditional row-oriented embedded engines execute predicates sequentially on the CPU, leaving data-parallel throughput untapped.

=== Scope of Work
This dissertation presents an asynchronous, double-buffered execution pipeline integrated directly into an embedded virtual database engine.

= Problem Definition
Define the exact bottlenecks, hardware constraints, and formal problem statement addressed in Phase-3.

= Literature Review
== Prior Work in Hardware-Accelerated Databases
Discuss existing literature and highlight limitations regarding PCIe transfer overheads and query plan eligibility.

= Project Requirements Specification
Detail functional requirements, non-functional requirements (latency in ms, throughput in GB/s), and hardware/software specifications.

= System Design
== High-Level Design (HLD)
Present system architecture diagrams and component interactions.

// Example figure — numbered automatically as Figure 5.1
// #figure(
//   image("architecture.png", width: 85%),
//   caption: [High-Level System Architecture],
// ) <fig:hld>

== Low-Level Design (LLD)
Detail module interfaces, memory layouts, state machines, and data structures.

== Buffer Sizing and Synchronization
Provide detailed design specifications, buffer sizing calculations, and synchronization protocols. The pipeline latency is given by @eq:pipeline.

$ T_"total" = max(T_"H2D", T_"kernel", T_"D2H") $ <eq:pipeline>

= Proposed Methodology
Explain the algorithmic design, query eligibility validation rules, and execution pipeline.

= Implementation and Pseudocode
Include clean pseudocode blocks, kernel launch configurations, and integration details.

= Experimentation Results and Discussion
Present benchmark setups, dataset scales, and comparative charts/tables using strict SI units. Results are in @tab:results.

// Example table — numbered automatically as Table 8.1
#figure(
  table(
    columns: (auto, auto, auto),
    inset: 8pt,
    align: (left, right, right),
    [*Row Count*], [*CPU Execution (ms)*], [*GPU Execution (ms)*],
    [$10^6$], [$42.5$], [$6.1$],
    [$10^8$], [$4180.0$], [$312.4$],
  ),
  caption: [Predicate Evaluation Latency Comparison],
) <tab:results>

= Conclusion and Future Work
Summarize the work accomplished, its practical utility, the progression from Capstone Phase-2 to Phase-3, and directions for future optimization.

#back-matter-heading[References / Bibliography]
#bibliography("refs.bib")

#back-matter-heading[Appendix A: Definitions, Acronyms and Abbreviations]
- *CPU*: Central Processing Unit
- *GPU*: Graphics Processing Unit
- *HLD*: High-Level Design
- *LLD*: Low-Level Design
- *PCIe*: Peripheral Component Interconnect Express
- *VDBE*: Virtual Database Engine

#back-matter-heading[Appendix B: User Manual]
Provide build instructions, runtime flags, and CLI usage examples here.
