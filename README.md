# RISC-V Processor Project
A from-scratch RISC-V RV32I processor implemented in SystemVerilog, developed to explore computer architecture, pipelining, caching, and performance monitoring through hands-on design.

---

## Overview
This project implements a five-stage pipelined RISC-V processor with branch prediction, instruction caching, and an extensible verification and benchmarking framework.  
It serves as both a learning platform and a demonstration of practical digital design.

**Key architectural components include:**
- Five-stage pipeline with hazard detection and forwarding  
- Two-level branch prediction (local and global predictors)  
- Instruction cache with LRU replacement  
- Benchmark support (Dhrystone) and cycle-accurate performance measurement  
- Python-based test framework for regression and benchmark automation  

The design targets FPGA implementation and is developed with synthesis compatibility in mind.

---

## Current Stage

The project is in a **Consolidation and Alignment** phase, focusing on documentation consistency, CSR implementation, and expanded performance monitoring.  
See the [project roadmap](docs/roadmap.md) for an up-to-date view of active work and future plans.

---

## Repository Structure

- **rtl/** – Processor source files (SystemVerilog)  
- **tb/** – Testbenches and verification infrastructure  
- **common/** – Global macro definitions used across RTL and testbench code  
- **docs/** – Comprehensive project documentation and specifications  
  - **core_docs/** – High-level specifications (architecture, pipeline, memory, etc.)  
  - **blocks/** – Module-level overviews for major RTL components  
  - **spreadsheets/** – Signal, CSR, and instruction decode reference data  
  - **devlogs/** – Chronological development logs  
  - **roadmap.md** – Current development focus and long-term plans  
  - **style_guide.md** – Naming, formatting, and documentation conventions  
- **scripts/** – Build, simulation, and automation scripts  
- **test_inputs/** – Software toolchain and test programs for the processor, including:  
  - RISC-V C/assembly compilation flow and programs
  - Custom linker script and startup code  
  - Makefile for building and running programs  
  - Compiled binaries, and input/output vectors used for simulation and benchmarking  
- **archive/** – Legacy or deprecated files retained for reference  
- **README.md** – Repository overview (this file)  

For detailed technical documentation, see the [documentation index](docs/README.md).

---

## Goals
- Build a modular, readable RISC-V processor with emphasis on correctness and clarity  
- Develop a strong verification infrastructure supporting benchmarking and analysis  
- Gradually expand toward realistic architectural features such as caching, CSRs, and I/O peripherals

---

*This repository is an ongoing development effort intended to showcase digital design methodology, and continuous architectural improvement.*

