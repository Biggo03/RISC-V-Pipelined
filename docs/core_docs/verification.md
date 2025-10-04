# Verification

## Overview
This document describes the verification methodology used to validate the correctness and performance of the processor.  
Verification focuses on module-level testing, directed assembly tests, and full-system benchmarking.  
A combination of simulation-based testing and automated regression infrastructure is used to ensure consistent behavior as the design evolves.

---

## Verification Objectives
The verification process aims to:
- Confirm functional correctness for all implemented instructions.  
- Verify proper interaction between pipeline stages and control logic.  
- Ensure caches and branch prediction mechanisms behave as expected under realistic workloads.  
- Provide cycle-accurate performance measurement across benchmarks.  

---

## Directed Assembly Tests
Directed assembly programs are used to verify instruction behavior and specific microarchitectural scenarios.  
Each test focuses on a particular functionality but also includes supporting instructions required for setup and result validation.

**Examples:**
- Arithmetic and logical operations (ADD, SUB, AND, OR, etc.)  
- Load and store behavior, including alignment handling and correct sign or zero extension.  
- Branch and jump operations, verifying correct PC updates, target calculation, and offset sign-extension.  
- Pipeline interactions such as forwarding, data hazards, and load-use stall behavior.  

Each program writes its results to a reserved memory address for automated checking during simulation.  
Tests are compiled and executed individually to simplify debugging and isolate failures.

---

## Test Framework
A Python-based test framework automates the execution of both module-level and full-system simulations.  
It serves as the primary driver for all verification workloads, including directed assembly programs, individual module testbenches, and benchmark runs.  
The framework provides a consistent environment for running, analyzing, and comparing results across the entire design.

**Key features:**
- Unified interface for running module, integration, and full-system tests.  
- Automatic waveform generation for all runs.  
- Configurable test lists to control scope and coverage.  
- Pass/fail detection based on module-specific criteria, such as internal signal checks, assertions, or memory-mapped output values.  

The framework is used continuously throughout development to verify correctness, monitor performance, and detect regressions as the design evolves.  
Future plans include adding support for comparing simulation outputs across design revisions to track functional and performance changes.

---

## Benchmarking
Full-system benchmarks are used to evaluate overall processor performance, including pipeline efficiency and cache behavior.  

**Current benchmarks:**
- **Dhrystone:** Measures baseline integer performance and provides IPC estimates.  

**Planned benchmarks:**
- **CoreMark:** Tests arithmetic, logical, and control operations with greater diversity.  
- **Embench:** A modern embedded benchmark suite representing realistic small-program workloads.  

Benchmark results are currently gathered manually using cycle and instruction counters.  
Future work will focus on automating result collection and enabling comparisons across design revisions.

---

## Verification Infrastructure
The following infrastructure supports simulation and testing:  
- **Cycle and instruction counters:** Measure total cycles, retired instructions, and IPC during program execution.  
- **Automated build and run scripts:** Compile, assemble, and execute all tests through the unified Python-based framework.  
- **Automated output checking:** Pass/fail detection is based on module-specific criteria, such as internal signal checks, assertions, or memory-mapped output values.  

All infrastructure is compatible with open-source simulation tools such as Icarus Verilog and GTKWave.  

Future planned enhancements include internal monitors for tracking pipeline state and expanded result checking against reference outputs.

---

## Future Verification Work
Verification development will continue alongside architectural updates to maintain correctness and reliability as new features are introduced.  
Planned areas of focus include:

- Continuing to expand and refine the test framework as the design evolves.  
- Extending directed and integration tests to cover new functionality as it is implemented.  
- Introducing coverage tracking to quantify test completeness once the design stabilizes.  
- Preparing infrastructure for future interrupt-handling and CSR testing when those features are added.

---

## Summary
The current verification flow validates instruction-level correctness, pipeline control behavior, and overall processor functionality.  
It combines directed assembly testing, a unified Python-based test framework, and benchmarking to maintain correctness and stability as the design evolves.