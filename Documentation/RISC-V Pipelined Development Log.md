## **Preamble:**  
Before delving into the rest of this development log, I would like to outline a few key points: the organization of the log, the dating of entries, and the connection between this pipelined RISC-V processor and my previously designed single-cycle RISC-V processor.

### **Organization:**  
This development log will be structured into sections that cover each major aspect of the processor's development. As the project progresses, additional sections will be added, so I will not provide an exhaustive overview of all sections at this time. However, an example of a section to expect is one that outlines the actual pipelining of the design.

Within each section, there will be subsections dedicated to specific elements of the design addition. For instance, one subsection may detail the design of a new module, while another may explain a particular design choice. These subsections will represent the final state of the design and will not include any information preceding a change.

Changes made to the design will be documented in a “Changelog” section, with subsections linking to relevant entries within the changelog.

Additionally, there will be a section titled “Challenges.” This section will contain entries discussing the challenges encountered during the processor's design process, with subsections again linking to pertinent entries.

### **Dates:**  
I will include the date range for each section and subsection, along with any specific dates when changes were made. If a project day is not explicitly mentioned within a range, no work was done on that day.

## **Connection to Single-Cycle Processor:**  
This pipelined processor is built upon the foundation of my single-cycle processor, which was based on the architecture outlined in *Digital Design and Computer Architecture: RISC-V Edition* by Sarah L. Harris and David Harris. This design will incorporate many of the same modules that were developed and tested in the single-cycle processor.

The primary enhancement in this project will be the introduction of pipelining, followed by the integration of additional features such as unified memory, memory mapping, interrupt handling, branch prediction, and caching. I intend to start with pipelining and gradually add functionality from there.

Unified memory will enable a more realistic organization of memory, while memory mapping, which focuses on the specification of intended use rather than hardware implementation, will further streamline memory management. These features will pave the way for interrupt handling, which requires memory space to store the processor's current architectural state.

Pipelining, along with branch prediction and caching, aims to enhance the overall performance of the design. Pipelining will improve clock speed and allow for instructions to execute in parallel, while branch prediction will enable the pipeline to more accurately anticipate the occurrence of branches. Caching will increase the efficiency of memory accesses.

I will benchmark the power, performance, and area of the processor after each feature addition in order to provide an idea of the tradeoffs between each addition. These measurements will be taken from the post-synthesis result.

## **Pipelining (September 26th \- ):**

### **Overview (September 26th):**  
The implementation of the pipeline is based on the 5-stage pipeline design in *Digital Design and Computer Architecture: RISC-V Edition* by Sarah L. Harris and David Harris. This means that a lot of the functionality will be very similar to the processor provided within the textbook. 

Backing up a bit, a pipelined processor shares a similar architecture to a single-cycle processor, but is split up into stages by **pipeline registers**. These stages have two main outcomes that improve performance, one being an increase in clock speed. This increase in clock speed is due to the fact that there’s less combinational logic between registers, meaning that less propagation delay must be accounted for by the clock speed. 

For example, let's say that the combinational logic between two registers has a propagation delay of 100ns, and the registers have a setup time of 10ns, and a clock-to-q propagation delay of 10ns, then the clock period must be 120ns or greater. To review, setup time is the minimum time time the register needs it’s input values to be stable, and clock-to-q propagation delay is the time it takes the output of a register to change after the clock edge, this is why 100ns \+ 10ns \+ 10ns \= 120ns is the lowest possible clock period. By dividing the combinational logic in half, the clock period becomes 50ns \+ 10ns \+ 10ns \= 70ns, a marked improvement.  
The other key improvement is the fact that multiple instructions are able to execute in parallel, meaning that the processor can maintain approximately 1 CPI (slightly less due to hazards, discussed later). If only one instruction was run at a time, then the clock speed would almost be 5x faster, however it would take 5 clock cycles to execute an instruction, meaning there would actually be a decrease in performance.

### **Pipeline Stages (September 26th):**

- Fetch  
  - Instruction is fetched from the instruction memory  
- Decode  
  - The instruction is decoded, and data is read from the register file   
  - Immediates are also extended in this stage  
- Execute  
  - The processor executes any arithmetic operations on the operands  
  - The PCTarget address is calculated  
- Memory  
  - The data memory is accessed for either a read or a write  
- Writeback  
  - Data fetched from the datamemory is written back to the register file

### **Hazard Overview: (September 26th)**  
This section explains the hazards that the processor will have to deal with due to the addition of pipelining. The actual handling of hazards will be discussed in the section covering the creation of the Hazard Unit.

#### **RAW Hazards:**  
In pipelined processor designs, multiple instructions are executed concurrently, which can lead to hazards that affect data integrity. One such hazard is the Read After Write (**RAW**) hazard, which occurs when an instruction depends on the result of another instruction that has not yet completed its **writeback** phase. For instance, if an instruction in the **execute** stage requires the value of a register currently being written to in the **writeback** stage, a **RAW** hazard arises.

To resolve this issue, **forwarding** can be employed. **Forwarding** allows the result from the **memory** or **writeback** stage to be sent back to the execute stage, ensuring that the instruction receives the most recent value.

For example, consider an instruction in the **execute** stage that needs the value of x4, while x4 is being written to in the **writeback** stage. Without forwarding, the **execute** stage would use an outdated value of x4. By sending the current value from the **writeback** stage to the **execute** stage, the correct value of x4 is utilized.

Forwarding is sufficient to deal with cases where the result is calculated in the **execute** stage, however loads don’t have the data available until the end of the memory stage. Because of this, the pipeline must be **stalled** in order to allow the data to be fetched from memory. A **stall** is when instructions repeat the same pipeline stage for an extra clock cycle. This requires pipeline registers to either be frozen (stages prior to stall), or cleared (stages post stall). This prevents new instructions from being sent to the pipeline, reducing the efficiency of the processor, but this is necessary in order to ensure data integrity.

Effectively managing RAW hazards through techniques like forwarding and stalling is crucial for maintaining pipeline efficiency and ensuring correct program execution.

#### **Control Hazards:**  
The only control hazard that needs to be dealt with initially is that caused by branching instructions. Because branches are conditional and depend on the result calculated in the **execute** stage, a prediction must be made on which instructions are to begin execution in the preceding **fetch** and **decode** stages. If the prediction is incorrect, then the pipeline registers in these sections must be flushed, and the correct PC address must be fetched. This leads to a delay of two clock cycles, as incorrect instructions are flushed. However, this is better than delay caused by simply stalling and waiting for the correct branch to be calculated as the prediction can be correct, allowing for the steady flow of instructions through the pipeline. This processor will begin with always assuming that no branch is taken. This approach has the simplest level of complexity but also results in the highest number of mispredictions. More sophisticated branch prediction will be added later in development, which will decrease misprediction rate, and improve pipeline efficiency.

### **Creation of Pipeline (September 26th \- ):**

### **Initial Design (September 26th \-)**  
The pipelined architecture is built on the single-cycle architecture that has already been constructed. The main task in this phase is to insert pipeline registers and ensure all signals reach their correct destination. Each pipeline stage's schematic design will be discussed in this section.

In some cases, signals need to be routed back to earlier stages. These will be addressed in the stage where they are generated, rather than the stage they are routed back to. This approach mirrors the design process and provides a clearer picture of signal flow.

#### **Fetch Stage (September 27th)**
This stage contains the PC register, the instruction memory, an addition unit for calculating PCPlus4, and a multiplexer to determine if a branch address is to be jumped to or not. This largely remained the same as the single cycle, but with the following signals being routed to the **decode** stages pipeline register: Instr, PC, and PCPlus4. The PCTarget address is calculated in the **execution** section, and as such will be covered there.

#### **Decode Stage (September 27th)**
This stage contains the register file, control unit, and extension unit. In this stage, the register file handles all read operations, while writes occur in the **writeback** stage.

One challenge was deciding how to handle branching logic, which is detailed in [Challenges Section #1](#1-reworking-branching-logic-september-27th). To determine proper branching, the funct3 field of the instruction and BranchOp signal are routed to the **execute** stage. The extension unit receives the appropriate portions of the instruction word along with ImmSrc.

The following signals are routed to the **execute** stage's pipeline register: RD1, RD2 (also called WriteData), PC, Rd (destination register for writes), ImmExt, PCPlus4, funct3, BranchOp, and all control signals except ImmSrc.

#### **Execute Stage (September 27th)**
This stage contains the ALU, the branch decoder, and the addition unit for calculating the PCTarget address. In this stage, the ALU performs arithmetic operations, and generates flags, the branch decoder determines if a branch is to occur or not, and the PC target address is calculated.

The same multiplexers used in the single-cycle design are used here. One determines if an immediate or a register is to be the second input to the ALU. The other determines the base that is to be added onto PC to calculate the PC target address (this will either be PC or RD1).

The following signals are routed to the **memory** stage's pipeline register: ALUResult, WriteData, Rd (destination register for writes), PCTarget, PCPlus4, WidthSrc, ResultSrc MemWrite, and RegWrite.

## **Challenges**

### **#1 Reworking Branching Logic (September 27th)**
This was quite a challenge, as my initial design of the branching decoder relied on having both funct3, BranchOp, and the flags available at the same time. However, as the pipelined design calculates the flags in the Execution stage, if the branch decoder remained the same, it would use the flags from the execution stage, but the instruction from the decode stage. 

Ultimately I decided to route the funct3 and BranchOp signals to the **execute** stages pipeline register, and determine PCSrc there. Then I needed to decide how to represent this on the schematic. I could either route the signals in the **exectution** stage back to the control unit, or display the branch decoder as it's own module within the **execute** stage. I decided on the later, as this reduces the sprawl of the schematic. Even though it leads to a subsection of the control unit not being within the control unit, I believe the clarity it provides is worth the tradeoff.