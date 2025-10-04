# Project Roadmap

This roadmap outlines the current direction and development priorities for the RISC-V processor project.  
It emphasizes focus and sequence — completing one area of work before progressing to the next.

---

## Current Stage: Consolidation and Alignment

The processor has exited the refactor phase and now includes greater functionality than before, including a working benchmark flow for Dhrystone and a unified verification framework.  
The design is stable, synthesizable, and ready for structured enhancement.

The focus of this stage is to ensure **consistency, observability, and correctness** across the project before pursuing new architectural features.

---

## Active Areas of Work

Current areas of active development are limited and sequential.  
Each area will be completed before new work begins.

### 1. Documentation Consistency
- Standardize terminology and formatting across all specification and block documents.  
- Verify that control signals, CSR references, and architectural descriptions are consistent across specs, spreadsheets, and RTL.  
- Finalize the structure of `docs/` as the permanent foundation for future documentation.  

### 2. CSR Implementation
- Implement the baseline CSR subsystem, including `mcycle` and `minstret`.  
- Integrate CSR instruction decoding into the control unit.  
- Verify correctness using targeted assembly tests.  
- Ensure the implementation supports future extension for additional CSRs and privileged behavior.  

---

## Next Focus Area

After CSR functionality is implemented and documented, development will shift back toward **performance measurement and analysis**.  

### Performance Monitoring
- Collect detailed cycle and instruction logs for benchmark runs.  
- Automate log generation and result extraction within the test framework.  
- Calculate and record key performance metrics:
  - Total cycles
  - Instructions retired
  - Instruction mix
    - ALU ops count
    - Loads count
    - Stores count
    - Branches/jumps count
  - IPC and CPI
  - Load stalls
  - Branch misprediction penalty cycles
  - Branches executed
  - Branch mispredicts
  - Branch misprediction rate
  - I-cache misses
    - I-cache miss penalty cycles
- Use the gathered data to evaluate pipeline efficiency and cache effectiveness.  

This phase will focus on understanding and validating the processor’s behavior through quantitative measurement, with the collected data serving as a reference point for future optimization work.

---

## Future Direction

After the completion of performance monitoring work, development will shift toward the next major expansion phase.  
Two parallel directions are planned — one focused on architectural growth, and the other on integration and practical usability.  
The order in which these are pursued is intentionally undecided.

### Architectural Expansion
This path focuses on deepening the processor’s microarchitecture and instruction set support:
- Introduce a **sixth pipeline stage** to improve timing and accommodate more complex operations.  
- Implement the **RV32M extension**, adding hardware multiplication and division instructions that motivate the deeper pipeline structure.  
- Add a **data cache** and define the unified memory interface between instruction and data caches.  

These changes represent the next stage of architectural maturity, bringing the design closer to a complete and efficient RISC-V core.

### Integration and Practical Enhancements
This path focuses on improving system-level functionality and real-world usability:
- Add **UART support** for program output, debugging, and FPGA interaction.  
- Integrate essential I/O peripherals and control registers required for on-board execution.  
- Expand benchmarking capabilities to include programs utilizing these hardware interfaces.  

These enhancements will move the design from a simulation-only environment toward an interactive, FPGA-deployable system.

---

The specific order of development between these two paths will be determined organically.  
Both represent core components of the processor’s continued evolution toward a complete, usable, and measurable hardware system.

---

## Continuous Infrastructure Development

Alongside architectural and integration work, ongoing improvement of the project’s supporting infrastructure will continue.  
This includes all software, documentation, and tooling surrounding the hardware design that enable efficient development and clear communication.

### Focus Areas
- **Software Toolchain:** Improve the compilation and linking flow for C and assembly programs, ensuring consistent and reproducible builds.  
- **Test Infrastructure:** Extend the Python-based test driver for more flexible test configuration, improved result reporting, and easier integration of new benchmarks.  
- **Documentation and Visualization:** Continue refining existing documentation for clarity and consistency, and expand the use of diagrams to illustrate architecture, data flow, and module relationships.  
- **Project Organization:** Maintain a clean, scalable repository structure with clear separation between specifications, RTL, verification, and supporting materials.  

Infrastructure development will remain an ongoing effort throughout all stages of the project, ensuring that each new feature or subsystem is supported by reliable tooling and clear documentation.

---

## Guiding Principles

- Maintain a narrow focus — complete one defined area before expanding scope.  
- Keep documentation and implementation synchronized.  
- Use measurement and verification to drive future design choices.  
- Prioritize correctness, consistency, and understanding over speed of development.

---

This roadmap will evolve as milestones are completed.  