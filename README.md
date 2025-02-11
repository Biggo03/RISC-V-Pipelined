# RISC-V Pipelined with Branch Prediction
A pipelined implementation of a RISC-V microprocessor in Verilog.

## Introduction
This project implements a pipelined RISC-V microprocessor using Verilog, building on the single-cycle design from my previous project, which can be found here: [Single-Cycle-Processor](https://github.com/Biggo03/RISC-V-Single-Cycle). The processor aims to achieve approximately 1 instruction per cycle (IPC), although inefficiencies due to hazards may affect overall performance. It implements the RV32I instruction set architecture (ISA). This compact yet powerful architecture is widely used in both academia and industry for building RISC processors.

Pipelined processors boast a higher clock speed when compared to single-cycle processors, which is due to splitting the design up into sections called pipeline stages. Having less combinational logic between registers is what allows for the higher clock speed. Because of these pipeline registers, multiple instructions can run in parallel to each other, one in each pipeline stage. This processor contains 5 pipeline stages fetch, decode, execute, memory, and writeback. These pipeline stages cause both control and RAW hazards, which are handled by a Hazard Control Unit, another feature of this processor.

This project demonstrates a deeper understanding of complex processor architectures and the ability to manage increasingly sophisticated designs.

The working schematic of the microarchitecture, as well as a project development log, and technical documentation will be found in the "Documentation" folder.

## Performance Improvements over Pipelined Processor (without branch prediction):
There were changes in synthesis between this implementation, and the previous pipelined implementation. However, this is most likely due to the synthesizer finding more efficient ways to route the design. Regardless, the synthesized performance changes will be listed here.

In addition, the main performance improvements will come from cycles saved by the branch prediction, but this can't be properly measured without running a proper benchmark program. To run a proper benchmark program, a proper memory system will be needed, and as such, the performance improvements in terms of cycles saved (or IPC improvement) will be added here once they are attained following the implementation a more sophisticated memory system.

###  Timing:
Optimizing synthesis for performance, the design was able to achieve an **Fmax** of **73.757MHz** corresponding to a minimum clock period of 13.558ns. This reflects a **0.368%** increase in clock speed compared to the previous pipelined processor fmax of **73.486MHz**. This increase is likely due to optimizations made by the synthesizer that weren't found previously.

The logic delay was again 2.527ns, having no change compared to the last implementation of the processor. This supports the idea that the improvement in clock speed was primarily due to optimizations made by the synthesizer.

### Power:
The total on chip power was measured at **0.1W**, a  **43%** decrease compared to the previous pipelined processor. Of this 0.1W, **10%** is related to the dynamic power, with the other **90%** being related to static power.

The dynamic power can further be broken down as follows:
| Process | Power Consumption |
| :----   | :----             |
| Clocks  | 0.010W (93%)      |
| Signals | <0.001W (4%)      |
| Logic   | <0.001W (3%)      |
| I/O     | <0.001W (0%)      |

This overall decrease in power is far more than what could be expected, but it's likely to do with the decreased clock speed, lower utilization, and possibly other optimizations made by the synthesizer.

### Utilization:
The processor utilized the following when synthesized on the Zybo Z7-10 development board:

| Module      | LUTs (17600)  | Registers (35200) | F7 Muxes (8800) | F8 Muxes (4400) | Bonded IOB (100) |
| :----       | :----         | :----             | :----           | :----           | :----            |
| Top         | 1805 (10.26%) | 1660 (4.72%)      | 361 (4.10%)     | 160 (3.64%)     | 67 (67%)         |
| rvpipelined | 1605 (9.12%)  | 1660 (4.72%)      | 297 (3.38%)     | 128 (2.91%)     | 0 (0%)           |
| dmem        | 168 (0.95%)   | 0 (0%)            | 64 (0.73%)      | 32 (0.72%)      | 0 (0%)           |

Comparing utilization to previous pipelined processor:

| Component | Change in Utilization |
|-----------|-----------------------|
| Lut's     | 1.31% Decrease        |
| Registers | No Change             |
| F7 Muxes  | 6.72% Decrease        |
| F8 Muxes  | No Change             |
| IOB's     | No Change             |


## Implemented Key Features
- 5-stage pipelined architecture
- Branch prediction for reduced control hazards
- RV32I ISA implementation
- Hazard detection and forwarding logic
- Separate Instruction and data memories
- Testbenches for hardware validation

## Technical Details
For a detailed explanation of the architecture, supported instructions, control signals, testing procedures, and hazard handling information, please refer to [Technical_Documentation.md](Documentation/Technical_Documentation.md).