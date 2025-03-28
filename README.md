# RISC-V Pipelined
A pipelined implementation of a RISC-V microprocessor in Verilog.

## Introduction
This project implements a pipelined RISC-V microprocessor using Verilog, building on the single-cycle design from my previous project, which can be found here: [Single-Cycle-Processor](https://github.com/Biggo03/RISC-V-Single-Cycle). The processor aims to achieve approximately 1 instruction per cycle (IPC), although inefficiencies due to hazards may affect overall performance. It implements the RV32I instruction set architecture (ISA). This compact yet powerful architecture is widely used in both academia and industry for building RISC processors.

Pipelined processors boast a higher clock speed when compared to single-cycle processors, which is due to splitting the design up into sections called pipeline stages. Having less combinational logic between registers is what allows for the higher clock speed. Because of these pipeline registers, multiple instructions can run in parallel to each other, one in each pipeline stage. This processor contains 5 pipeline stages fetch, decode, execute, memory, and writeback. These pipeline stages cause both control and RAW hazards, which are handled by a Hazard Control Unit, another feature of this processor.

This project demonstrates a deeper understanding of complex processor architectures and the ability to manage increasingly sophisticated designs.

The working schematic of the microarchitecture, as well as a project development log, and technical documentation will be found in the "Documentation" folder.

## Planned Key Features
- Improved memory system
  - Main memory using Zybo boards 1GB DDR3 off chip memory
  - Turn instruction and data memory into L1 instruction and data caches
  - Larger shared L2 cache

## Implemented Key Features
- 5-stage pipelined architecture
- Branch prediction for reduced control hazards
- RV32I ISA implementation
- Hazard detection and forwarding logic
- Separate Instruction and data memories
- Testbenches for hardware validation

## Technical Details
For a detailed explanation of the architecture, supported instructions, control signals, testing procedures, and hazard handeling information, please refer to [Technical_Documentation.md](Documentation/Technical_Documentation.md).
