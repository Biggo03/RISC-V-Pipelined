# **Preamble:**  
Before delving into the rest of this development log, I would like to outline a few key points: the organization of the log, the dating of entries, and the connection between this pipelined RISC-V processor and my previously designed single-cycle RISC-V processor.

## **Organization:**  
This development log will be structured into sections that cover each major aspect of the processor's development. As the project progresses, additional sections will be added, so I will not provide an exhaustive overview of all sections at this time. However, an example of a section to expect is one that outlines the actual pipelining of the design.

Within each section, there will be subsections dedicated to specific elements of the design addition. For instance, one subsection may detail the design of a new module, while another may explain a particular design choice. These subsections will represent the final state of the design and will not include any information preceding a change.

Changes made to the design will be documented in a “Changelog” section, with subsections linking to relevant entries within the changelog.

Additionally, there will be a section titled “Challenges.” This section will contain entries discussing the challenges encountered during the processor's design process, with subsections again linking to pertinent entries.

## **Dates:**  
I will include the date range for each section and subsection, along with any specific dates when changes were made. If a project day is not explicitly mentioned within a range, no work was done on that day.

# **Connection to Single-Cycle Processor:**  
This pipelined processor is built upon the foundation of my single-cycle processor, which was based on the architecture outlined in *Digital Design and Computer Architecture: RISC-V Edition* by Sarah L. Harris and David Harris. This design will incorporate many of the same modules that were developed and tested in the single-cycle processor.

The primary enhancement in this project will be the introduction of pipelining, followed by the integration of additional features such as unified memory, memory mapping, interrupt handling, branch prediction, and caching. I intend to start with pipelining and gradually add functionality from there.

Unified memory will enable a more realistic organization of memory, while memory mapping, which focuses on the specification of intended use rather than hardware implementation, will further streamline memory management. These features will pave the way for interrupt handling, which requires memory space to store the processor's current architectural state.

Pipelining, along with branch prediction and caching, aims to enhance the overall performance of the design. Pipelining will improve clock speed and allow for instructions to execute in parallel, while branch prediction will enable the pipeline to more accurately anticipate the occurrence of branches. Caching will increase the efficiency of memory accesses.

I will benchmark the power, performance, and area of the processor after each feature addition in order to provide an idea of the tradeoffs between each addition. These measurements will be taken from the post-synthesis result.

# **Pipelining (September 26th \- October 5th):**

## **Overview (September 26th):**  
The implementation of the pipeline is based on the 5-stage pipeline design in *Digital Design and Computer Architecture: RISC-V Edition* by Sarah L. Harris and David Harris. This means that a lot of the functionality will be very similar to the processor provided within the textbook. 

Backing up a bit, a pipelined processor shares a similar architecture to a single-cycle processor, but is split up into stages by **pipeline registers**. These stages have two main outcomes that improve performance, one being an increase in clock speed. This increase in clock speed is due to the fact that there’s less combinational logic between registers, meaning that less propagation delay must be accounted for by the clock speed. 

For example, let's say that the combinational logic between two registers has a propagation delay of 100ns, and the registers have a setup time of 10ns, and a clock-to-q propagation delay of 10ns, then the clock period must be 120ns or greater. To review, setup time is the minimum time time the register needs it’s input values to be stable, and clock-to-q propagation delay is the time it takes the output of a register to change after the clock edge, this is why 100ns \+ 10ns \+ 10ns \= 120ns is the lowest possible clock period. By dividing the combinational logic in half, the clock period becomes 50ns \+ 10ns \+ 10ns \= 70ns, a marked improvement.  
The other key improvement is the fact that multiple instructions are able to execute in parallel, meaning that the processor can maintain approximately 1 CPI (slightly less due to hazards, discussed later). If only one instruction was run at a time, then the clock speed would almost be 5x faster, however it would take 5 clock cycles to execute an instruction, meaning there would actually be a decrease in performance.

## **Pipeline Stages (September 26th):**

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

## **Hazard Overview (September 26th):**  
This section explains the hazards that the processor will have to deal with due to the addition of pipelining. The actual handling of hazards will be discussed in the section covering the creation of the Hazard Unit.

### **RAW Hazards (September 26th):**  
In pipelined processor designs, multiple instructions are executed concurrently, which can lead to hazards that affect data integrity. One such hazard is the Read After Write (**RAW**) hazard, which occurs when an instruction depends on the result of another instruction that has not yet completed its **writeback** phase. For instance, if an instruction in the **execute** stage requires the value of a register currently being written to in the **writeback** stage, a **RAW** hazard arises.

To resolve this issue, **forwarding** can be employed. **Forwarding** allows the result from the **memory** or **writeback** stage to be sent back to the execute stage, ensuring that the instruction receives the most recent value.

For example, consider an instruction in the **execute** stage that needs the value of x4, while x4 is being written to in the **writeback** stage. Without forwarding, the **execute** stage would use an outdated value of x4. By sending the current value from the **writeback** stage to the **execute** stage, the correct value of x4 is utilized.

Forwarding is sufficient to deal with cases where the result is calculated in the **execute** stage, however loads don’t have the data available until the end of the memory stage. This means if the instruction directly following a load uses the register the load writes to, the pipeline must be **stalled** in order to allow the data to be fetched from memory. A **stall** is when instructions repeat the same pipeline stage for an extra clock cycle. This requires pipeline registers to either be frozen (stages prior to stall), or cleared (stages post stall). This prevents new instructions from being sent to the pipeline, reducing the efficiency of the processor, but this is necessary in order to ensure data integrity.

Effectively managing RAW hazards through techniques like forwarding and stalling is crucial for maintaining pipeline efficiency and ensuring correct program execution.

### **Control Hazards (September 26th):**  
The only control hazard that needs to be dealt with initially is that caused by branching instructions. Because branches are conditional and depend on the result calculated in the **execute** stage, a prediction must be made on which instructions are to begin execution in the preceding **fetch** and **decode** stages. If the prediction is incorrect, then the pipeline registers in these sections must be flushed, and the correct PC address must be fetched. This leads to a delay of two clock cycles, as incorrect instructions are flushed. However, this is better than delay caused by simply stalling and waiting for the correct branch to be calculated as the prediction can be correct, allowing for the steady flow of instructions through the pipeline. This processor will begin with always assuming that no branch is taken. This approach has the simplest level of complexity but also results in the highest number of mispredictions. More sophisticated branch prediction will be added later in development, which will decrease misprediction rate, and improve pipeline efficiency.

## **Initial Design (September 26th \- 28th):**  
The pipelined architecture is built on the single-cycle architecture that has already been constructed. The main task in this phase is to insert pipeline registers and ensure all signals reach their correct destination. Each pipeline stage's schematic design will be discussed in this section.

Also note that in this section, signal names will not have a suffix implying the stage they're in, as it is implyed, however in later section a suffix will denote the stage that signal originated from.

### **Fetch Stage (September 27th):**
**Changes made on October 2nd:** See [Changelog Sections #1](#Changelog)
This stage contains the PC register, an addition unit for calculating PCPlus4, a multiplexer to determine if a branch address is to be jumped to or not, and interfaces with the instruction memory. This largely remained the same as the single cycle, but with the following signals being routed to the **decode** stages pipeline register: PC, and PCPlus4. Instruction signal is routed from the instruction memory to the **decode** stages pipeline register. The PCTarget address is calculated in the **execution** section, and as such will be covered there.

### **Decode Stage (September 27th):**
**Changes made on October 2nd:** See [Changelog Sections #1](#Changelog)
This stage contains the extension unit, and interfaces with the register file and control unit. In this stage, data is sent to the register file, which handles all read operations.

I initially had a challenge deciding how to handle branching logic, which is detailed in [Challenges Section #1](#1-reworking-branching-logic-september-27th). This became a non-issue after the changes made in the mentioned changelog entry, and more can be read about it in said entry. 

To determine proper branching, the funct3 field of the instruction and BranchOp signal are routed to the control unit. The extension unit receives the appropriate portions of the instruction word along with ImmSrc.

The following signals are routed to the **execute** stage's pipeline register: PC, Rd (destination register for writes), Rs1, Rs2, ImmExt, PCPlus4, funct3, BranchOp, and all other control signals except ImmSrc.

### **Execute Stage (September 27th):**
**Changes made on October 2nd:** See [Changelog Sections #1](#Changelog)
This stage contains the ALU, an addition unit for calculating the PCTarget address, and interfaces with the control unit (branch decoder). In this stage, the ALU performs arithmetic operations, and generates flags, and the PC target address is calculated.

The same multiplexers used in the single-cycle design are used here. One determines if an immediate or a register is to be the second input to the ALU. The other determines the base that is to be added onto PC to calculate the PC target address (this will either be PC or RD1). This section will not go into hazard handelling multiplexers.

The following signals are routed to the **memory** stage's pipeline register: ALUResult, WriteData, Rd (destination register for writes), PCTarget, PCPlus4, WidthSrc, ResultSrc MemWrite, RegWrite, and ImmExt.

### **Memory Stage (September 28th):**
**Changes made on October 2nd:** See [Changelog Sections #1](#Changelog)
This stage contains the reduce unit, which adjusts the width of fetched data as necessary, and interacts with the data memory. In this stage, an address and data is sent to data memory where it is stored, or data from the given address is loaded. The control signals MemWrite and WidthSrc governing these actions.

The following signals are routed to the **writeback** stage's pipeline register: ResultSrc, RegWrite, ALUResult, ReducedData (the result after any necessary width adjustment), Rd (destination register for writes), PCTarget, PCPlus4, and ImmExt.

### Writeback Stage (September 28th):**
This stage contains the result multiplexer and interacts with the register file. In this stage, the result multiplexer selects the appropriate value ALUResult, data fetched from memory, PCPlus4, ImmExt, or PCTarget to be written back to the register file, provided that RegWrite is enabled. The possible values are: ALUResult, data fetched from memory, PCPlus4, ImmExt, or PCTarget.

As this is the final stage in the pipeline, no signals from this stage are routed to any further sections.

## **Hazard Unit Design (September 29th):**
The design of the hazard unit is largely based on the design of the hazard unit within Digital Design and Computer Architecture by David and Sarah L. Harris. It will deal with the hazards discussed in the [Hazard Overview Section](Hazard-Overview-September-26th). The specific type of handelling for each type of hazard will be discussed here.

Signals are referred to with a suffix indicating the stage they originated from (for example, RdE for a signal from the execute stage) for clarity in tracking data as it progresses through the pipeline stages.

### **Forwarding (September 29th):**
Forwarding is employed to resolve RAW (Read After Write) hazards wherever possible, except for hazards caused by load instructions. When forwarding is possible, the value that the destination register is to be set to in the **memory** or **writeback** stage is forwarded to the **execution** stage, provided the RegWrite signal is active. If RegWrite is inactive, the destination register is not modified, and no forwarding is needed.

Since the execution stage can receive forwarded data from either the **memory** or **writeback** stages, a three-input multiplexer is required to select the correct data for each operand of the ALU. The sources for operand SrcA of the ALU are either RdM (the register in the **memory** stage), RdW (the register in the **writeback** stage), or RD1E (the register read from the **execute** stage itself). Similarly, for operand SrcB, the inputs are RdM, RdW, or RD2E.

To control these multiplexers, two signals are defined:
 - ForwardAE: This signal selects the source for SrcA between RdM, RdW, and RD1E.
 - ForwardBE: This signal selects the source for SrcB between RdM, RdW, and RD2E.

The control logic for ForwardAE and ForwardBE will check the values of the destination register in the **memory** and **writeback** stages against the source registers in the **execution** stage. If there is a match, and the RegWrite signal is high, forwarding occurs. 

The specifics of these signals and how they are implemented can be found in the [Technical_Documentation](Documentation/Technical_Documentation.md).

### **Stalling (September 29th):**
Stalling is used to handle load instructions by delaying the instruction that follows a load in the **decode** stage. This allows the load to complete both its **execute** and **memory** stages before the next instruction enters the **execute** stage. Once the load reaches the **writeback** stage, the following instruction can access the data read from memory. Therefore, stall detection must occur between the instruction in the **decode** stage and the instruction in the **execute** stage.

A stall should occur if a load instruction is in the **execute** stage, and the following instruction requires the loads destination register as a source. When this stall occurs, both the **fetch** and **decode** stages pipeline registers must be frozen, and the **execution** stages pipeline register must be flushed. The freezes perform the actual stall, and the flush ensures that garbage data isn't propogated through the pipeline. Note that when an all 0 instruction propagates through the pipeline nothing of consequence occurs, as no write enable signals are enabled.

To simplify the stall logic, the ResultSrc signal was adjusted from the single-cycle implementation:
 - auipc: 100 -> 001
 - Load instructions 001 -> 100
 - B-type instructions xxx -> 0xx
 - S-type instructions xxx -> 0xx

This change allows a single bit from the ResultSrc signal to identify a load, rather than two. B-type and S-type instructions were updated to ensure no accidental stalls occur. Although the risk of accidental stalls is low, given the organization of S- and B-type instructions, this change eliminates any possibility of accidental stall occuring.

The signals used to control flushing and stalling in the case of load instructions are as follows:
 - LoadStall: determines if a stall due to a load should occur
 - StallF: Determines if a freeze should occur on the **fetch** stages pipeline register
 - StallD: Determines if a freeze should occur on the **decode** stages pipeline register
 - FlushE: Determines if a flush should occur on the **execute** stages pipeline register

Details on these signals can be found in the [Technical_Documentation](Documentation/Technical_Documentation.md).

### **Control Hazard Handelling (September 29th):**
Control hazards arise due to the processor not knowing if a branch will occur or not. As discussed in previous sections, initially this processor will use static branch prediction, meaning it assumes that no branches will be taken. Because of this, implementing control hazard stalling will be relatively simple. The hazard unit needs to check if a branch is taken by checking PCSrcE. If a branch is taken, the decode and execute stage pipeline registers must be flushed. This is because these hold the values corrosponding to the next two instruction directly after the branch, and should not be executed if a branch is taken.

The signals used to control flushing in the case of a control hazard are as follows:
 - FlushE: Determines if a flush should occur on the **execute** stages pipeline register
   - Also used in load hazards
 - FlushD: Determines if a flush should occur on the **decode** stages pipeline register

The specifics of these signals and how they are implemented can be found in the [Technical_Documentation](Documentation/Technical_Documentation.md).

## **Verilog Coding (September 29th \- October 5th):**

### **Overview (September 29th, Oct 2nd):**
**Changes made on October 2nd:** See [Changelog Sections #1 and #2](#Changelog)

This design will be implemented by creating an individual module for each pipeline stage. This module is to include all the combinational logic within the module, as well as it's pipeline register. For example the Execute stages pipeline register would be the pipeline register with decode stage inputs, and will output signals used in the execute stage. 

In addition, general modules will not be included within the pipeline stage modules, but rather either a datapath module, or a top-level module. The hierarchy of the design, as well as the modules within each abstraction level are as follows:
 - Top-Level
   - Data Memory
   - Instruction Memory
   - Processor
     - Control Unit
     - Datapath
       - Pipeline Stages
       - Register File 

This organization will allow for each level of abstarction to have a defined role, and will ensure modules higher within the hierarchy aren't burdened with low-level signal management.

### **Fetch Stage (September 29th \- October 1st):**
**Changes made on October 2nd:** See [Changelog Section #1](#Changelog)
This stage contains the PC register, which is effectively the fetch stages pipeline register. This stage also contains a multiplexer to determine the PC registers next input, an adder for calculating PCPlus4, and will interface with the instruction memory. The PCTarget address for branches and jumps is recieved from the **execute** stage. The PC register recieves the StallF signal, which disables its contents from being updated, effectively freezing the processor for a cycle.

The actual code within this module is just instantiation of the lower level modules mentioned above.

**Testing:**

This module was tested in three different cases using SystemVerilog assertions. These casese included:
 - Standard operation (No branching, simply read from instruction memory as normal)
 - Stalling (Assert the stall signal and ensure nothing changes)
 - Branching (Branch to an instruction and ensure everything changes appropriately)

By ensuring the module can handle the above scenarios, I can be relatively confident in its functionality during actual operation, as these tests effectively cover the actions that occur in a clock cycle within the fetch stage.

### **Decode Stage (October 1st):**
**Changes made on October 2nd:** See [Changelog Sections #1 and #2](#Changelog)

This pipeline stage interfaces with the register file, but since the register file has been moved to a higher abstraction level, the only module within this stage is the extension unit, responsible for extending immediates. The primary functionality of the **decode** stage is to generate signals used by other modules, particularly the control unit and the **execution** stage.

Most control signals are derived from the instruction within this pipeline stage. Portions of the instruction related to control signal decoding are sent to the control unit, while the source and destination register numbers are sent to the **execution** stage.

Additionally, this stage uses the signal DReset, which is the OR of the reset and FlushD signals. This ensures that the pipeline register is flushed whenever either reset or FlushD is asserted, maintaining proper control flow.

The design of this module primarily involves signal assignments for generating these control and forwarding signals, as well as the instantiation of the extension unit, and pipeline register.

**Testing:**

Given that this module contains larger submodules than previous stages and has a broad range of acceptable inputs and outputs, I plan to leave the verification of this module to the top-level tests of the design. This strategy allows for functional testing of the **decode/writeback** Stage while minimizing the time spent on ensuring that the structural components instantiated within it interact correctly at just the stage abstraction level. Since the components themselves have already been validated, any issues that arise are more likely due to interactions with other modules, making top-level testing a more effective approach.

### **Execute Stage (October 1st):**
**Changes made on October 2nd:** See [Changelog Sections #1 and #2](#Changelog)

The **execute** stage is by far the most complex in the pipeline, primarily due to the large number of inputs and outputs it handles. This complexity is reflected in the sheer volume of input and output ports, as well as the number of signals included within the pipeline registers assignemnt statements.

Within this stage, several multiplexers handle the selection of inputs to arithmetic modules and manage forwarding paths. The arithmetic units include the ALU and an adder used to calculate the PCTarget address for branching. There are a number of intermediate signals within the module, being the intermediate signals between the multiplexers, and their associtted arithmetic unit. 

The outputs of this stage are sent to various other modules, including the hazard control unit, the memory stage’s pipeline register, and the branch decoder, which resides within the control unit.

The key challenge in the execute stage lies in managing the numerous signals and ensuring they are correctly routed and processed by the respective components.

**Testing:**

Similar to the **decode** stage, I have opted to defer the testing of this module to the top-level tests of the design. Since this module is essentially a structural combination of already verified components, it makes more sense to focus on the overall functionality of the system rather than on unit tests for this particular module. This approach minimizes the time spent on verification while still ensuring that the entire system operates as intended, allowing for a more efficient development process.

### **Memory Stage (October 1st):**
**Changes made on: October 2nd and October 4th:** See [Changelog Sections #1, #2, and #4](#Changelog)
This stage contains the reduction unit for adjusting data width and interfaces with the data memory module. The primary role of this stage is to handle the exchange of data between the processor and data memory, with control signals managing these interactions.

Data read from memory is passed to the **writeback** stage's pipeline register, along with other outputs from this stage. Additionally, some of this data is sent to the hazard unit or used in forwarding register values to the **execution** stage.

Note that this stage also contains a multiplexer that determines which data is to be sent to the execution stage for forwarding, as different instructions have different values written to a register.

**Testing:**

While it is certainly possible to create a testbench for this stage due to its relative simplicity, I believe that it is not necessary. The internal components have both been verified, and the only activity within the module occurs between these two components. Therefore, I will leave the verification of this component to be confirmed through the successful verification of the top-level module.

### **Writeback Stage (October 3rd):**
This stage contains a multiplexer responsible for selecting the result to be written back to the register file. Its primary function is to manage the write-back of data into the register file, and thus it does not interface with another pipeline stage register but focuses on completing the pipeline process by updating the register file.

Additionally, the result signal generated here is sent back to the execute stage for potential forwarding. To facilitate forwarding, the destination register number and the RegWrite control signal are passed to the hazard control unit, ensuring proper handling of dependencies.

**Testing**

As with the other pipeline stages, functionality verification will be integrated into the testing of the overall top-level system. Since this stage's internal operations rely primarily on already verified components, top-level testing ensures proper interaction with the rest of the design.


### **Hazard Control Unit (October 2nd):**
This unit was designed at the behavioral level rather than the structural level, as this performs logic functions in order to determine the value of hazard control signals. I designed this module by first creating an always statement to calculate the forwading signals, as they have three values, an if-else statement was the most natural way to implement it. This used temporary reg type signals that were then assigned to the actual outputs. Note I also used local parameters to add clarity in what each forward signal value represents.

All load and stall logic was only one-bit, meaning it was simplest to implement them using assign statements. I created a temporary wire signal to hold the LoadStall signal, which was then used in the assignment statements of corresponding signals. This was just the of the appropriate logic equations to their appropriate signals. The actual logic equations that were implemented can be found in [Technical_dDocumentation](Documentation/Technical_Documentation.md).

**Testing:**

As this module isn't structural in any way it makes sense to ensure the outputs are as expected. I created a testbench using only SystemVerilog. It likely wasn't necessary, but I designed the testbench to test every combination of registers for both ForwardAE and ForwardBE. For stall and flush testing, I setup the inputs to cover a large number of combinations to ensure that the correct flush and stall signals were always produced.

I started the design by creating tasks to deal with asserting the correct values, and printing informitive error messages. For both forwading and stall/flush testing I used nested for loops. In forward testing these for loops looped through each possible register combination and ensured that the correct hazard signal was produced. This was done for both ForwardAE and ForwardBE. The inner loop went up to 64, with the first 32 iterations changing the register value associated with ForwardAE, and the last 32 iterations changing the register value associated with ForwardBE.

As mentioned above, stall and flush signal inputs were varied in order to ensure many combinations were calcualted correctly. This was done by again making the inner for loop go up to 64. Different ranges of this inner loops variable lead to different inputs being given differnt values, resulting in many possible combinations being covered.

### **Datapath (October 3rd):**
This module is essentially used as a place to instantiate all the modules within it, which includes all the pipeline stage modules, as well as the register file. Signals are sent and recieved to and from all other top level modules, being the control unit, hazard control unit, data memory, and instruction memory. All signals not needed externally are declared within the module. These are grouped by the pipeline stage they are outputted from (and a small section for register file outputs).

There is only a single assignment statement within this module, used to manage a specific signal that requires only the most significant bit (MSB) for external access, while the complete signal is used internally. This simple assignment ensures that external components receive only the necessary data without redundant information.

**Testing:**

Given that the Datapath module is part of the top-level design, its functionality will be confirmed during the testing of the overall system. The top-level tests will validate the correct interaction between all components.

### **Updated Register File (October 4th):**
For the pipelined design, the register file must be write first as to allow values written to the register file to be accessed within the same clock cycle. As such, the previously designed register file needed to be slightly redesigned. The details of the change, and more about why this module was changed see [Challenges section #3](#3-register-file-read-before-write-hazard-october-4th).

**Testing:**

As of now, the modules correctness has been verified through the succeful simulation of the top-level module, however I soon plan on updating the register files testbench to reflect the changes made to it.

### **RISC-V Pipelined (October 3rd):**
This is the module containing all subcomponents of the RISC-V processor, those being the datapath, control unit, and the hazard control unit. It consists of the instantation of all of these components, with wire signals instantied to connect the modules accordingly. It is meant to interface with a data memory and an instruction memory.

**Testing:**

Given that the processor module is part of the top-level design, its functionality will be confirmed during the testing of the overall system. The top-level tests will validate the correct interaction between all components.

### **Top-Level Module (October 3rd \- 5th):**
This is the top-level module of the system, and contains the pipelined RISC-V module, as well as the instruction and data memory modules. It is effectively the same as the top-level module for the single-cycle processor I created previously, but with some different signal names.

**Testing:**

This module was tested behaviorally using the same testbench file and RISC-V assembly programs as the single-cycle processor. This means that the program was run on the processor, and a final value was written to memory, and checked to ensure it was the correct value. The RISC-V assembly code was written s.t the final result is only written to memory correctly if all instructions were run correctly.

This testing revealed a number of bugs, which I will now cover:

**Problem 1:** Numerous typo's, and incorrect widths within numerous modules. 
**Solution:** The typo's and incorrect widths were found through running behavioral simulation and either following an error message, or determining where the issue first occurred, and tracking down the signal that caused the error. In the second case the error was almost always an incorrect width.

**Problem 2:** Unexpected data hazards caused by additional instructions. This was because the memory stage only forwarded one signal, when multiple possible signals could be written to a register.More on this problem can be found in [Challenges section #2](#2-unexpected-hazards-october-4th).
**Solution:** Added a multiplexer to the **memory** stage that determined the signal that was to be forwarded back to the **execute** stage. The control signal was ResultSrc, as this is already used to determine what is to be written back to the register file.

**Problem 3:** Register file read data couldn't access written data on the clock cycle it was written in.
**Solution:** Made the register file write-first, meaning if the either read address (A1 or A2) was equal to the write address (A3), and the register file had writing enabled, then the write data would be forwarded to the read port before it was actually written to a register. More on this can be found in [Changelog section #3](#3-register-file-read-before-write-hazard-october-4th).

## **Post-Pipelining Performance Summary:**
The performance can be split into three measurable areas: utilization (area), power, and timing (performance). These are measured post-synthesis with the instruction memory being initialized with the RISC-V program that runs every implemented instruction.

### **Utilization:**
The processor utilized the following when synthesized on the Zybo Z7-10 development board:

| Module      | LUT’s (17600) | Registers (35200) | F7 Muxes (8800) | F8 Muxes (4400) | Bonded IOB (100) |
| :----       | :----         | :----             | :----           | :----           | :----            |
| Top         | 1829 (10.39%) | 1660 (4.72%)      | 387 (4.40%)     | 160 (3.64%)     | 67 (67%)         |
| rvpipelined | 1597 (9.07%)  | 1660 (4.72%)      | 297 (3.38%)     | 128 (2.91%)     | 0 (0%)           |
| dmem        | 168 (0.95%)   | 0 (0%)            | 64 (0.73%)      | 32 (0.72%)      | 0 (0%)           |

Comparing utilization to single-cycle processor:

| Component | Change in Utilization |
|-----------|-----------------------|
| Lut's     | 3.38% decrease        |
| Registers | 62.1% increase        |
| F7 Muxes  | 5.44% increase        |
| F8 Muxes  | 150% increase         |
| IOB's     | no change             |

The increase in registers is likely due to the introduction of pipeline registers (need mroe to store the intermediate data), and the decrease in LUT's with an increase in multiplexers is likely due to optimizations made possible by the introduction of the pipeline stages. As multiplexers are simpler components than LUT's, it's possible the synthesizer prioritizes using multiplexers where possible.

### **Timing:**
Optimizing synthesis for performance, the design was able to achieve an **fmax** of **73.486Mhz**, corrosponding to a minimum clock period of **13.608ns**. This reflects an **11.3%** improvement over the single-cycle design's fmax of **66.05 MHz**.

Another noteworthy improvement is in total logic delay. The single-cycle design had a maximum logic delay of **4.486ns**, while the pipelined design achieved a minimum logic delay of **2.527ns**, resulting in a **43.7%** enhancement in this area.

The fmax improvemnt is far lower than the expected near **500%** increase expeceted from a 5-stage pipeline. After inspecting the critical path schematic, it seems that the execution stage introduces a significant bottleneck. This could possibly be improved through playing with synthesis settings, or changing post-synthesis mapping. This may be something that is looked into more at a later time.

### **Power:**
The total on-chip power was measured at **0.176W**, with **48%** attributed to dynamic power and **52%** to static power. This represents a **2.22%** decrease compared to the single-cycle design. 

The dynamic power further broke down as follows:

| Process | Power Consumption | %change from siingle-cycle |
| :----   | :----             | :----                      |
| Clocks  | 0.010W (12%)      | 66.7% increase             |
| Signals | 0.018W (21%)      | 72.3% decrease             |
| Logic   | 0.014W (16%)      | 30.0% decrease             |
| I/O     | 0.042W (51%)      | 16.7% increase             |

**Note:** The percentages given are percentages of dynamic power, not total power.

The overall decrease in power was not expected, however it's likely due to the change in resource utilizaiton, and possibly more effecient pathing between components. 

The logic power consumption decreased by 30%, this could correlate to is a decrease in LUT's utilized, and an increase in multiplexers used. In this case, about 70 less LUT's were used, and a little over 100 more multiplexers were used. As LUT's are more complex than multiplexers, and were likely in more active paths within the single-cycle design, it makes sense that a decrease in LUT utilization leads to lower logic power consumption.

The signal power used decreased by the most significant amount. This is almost certainly due to a decrease in the length the signals need to travel, decreasing the overall capacitance of the system.

# **Next Steps (December 29th):**

At this point, the processor has effectively been pipelined, and is functional however there are still some improvements that can be made. Some of these improvements will be based around pure processor performance, and others will be based on processor usibility. In addtion, I will want to make changes that allow the processor to be properly implemented on the target FPGA, being the Zybo Z7-10 development board.

As of now, I'm planning on implementing more sophisticated dynamic branch prediction, which would increase the CPI of the processor. This is a metric that hasn't been measured before, and is likely very dependant on the compiler used to generate the assembly code. As such, will have to rely on the theoretical benifits of this addition, rather than any concreete metric.

The other changes I want to make as of now are related to memory managment, as well as program loading. As of now, there are two memories in the system, an instruction and data memory. I would like to change these so that they act as caches for a larger main memory. This main memory would ideally come from the 1GB memory on the Zybo board.

Finally, to make the processor more usable, I would like to make it possible to serially load programs into the main memory using a UART interface.

The first addition will be branch prediction, and the second will likely be the implementation of the full memory system, and finally, serial program loading.

# **Branch Prediction (December 29th \- Present):**

## **Overview (December 29th - 31st):**

The next addition that I have planned for my processor is branch prediction. I feel that this is a natural next step after pipelining, as it directly relates to the functionality of the pipeline itself. Branch misprediction effectively has a two clock cycle performance penalty, as two pipeline stages are filled with bubbles. Therefore reducing the rate of branch mispredictions can drastically improve the overall functional performance of a processor, even though clock speed may not be directly affected.

The initial branch prediction strategy that was implemented was static branch prediction, which always assumes that branches are not taken. Although this is the most simple form of branch prediction to implement, it is extremely inefficient. For example, in any kind of loop, it will always perform poorly as a for loop may iterate hundreds or even thousands of times, and each time it iterates a branch is taken. This would effectively mean that the loop contains two NOP instructions at the end of the loop iteration, as a misprediction will occur each iteration.

My plan is to implement a (2,2) branch predictor in order to improve branch prediction accuracy. A (2,2) branch predictor is a correlating branch predictor, meaning it takes into account both the previous behaviour of a local branch (a specific branch within a program), as well as the previous behaviour of all recent branches in the program. It does this by effectively having a two layer state machine. The "outer" or "global" layer keeps track of the all recent branches in the program. It does this in a register called the Global History Register, or **GHR**. As this is a (2,2) correlating branch predictor, this means there are four possible states of this outer state machine, and are based on the behaviour of the two most recent branches.
- taken, taken
- untaken, untaken
- taken, untaken
- untaken, taken

For each of these states, a target branch has its own local branch predictor, which in this case, will be a 2-bit branch predictor. These 2-bit branch predictors also have 4 states:
- strongly taken
- weakly taken
- weakly not taken
- strongly not taken

When a branch is taken, the predictor moves closer to 'strongly taken.' When not taken, it moves towards 'strongly not taken. When the branch predictor is in a "taken" state, it will predict that the branch is taken. When the branch predictor is in a "not taken" state, it will predict that the branch is not taken.

In summary so far, the GHR encodes the outcomes of the two most recent branches to select one of four local branch predictors, each corresponding to a specific global state.

Note that only used local predictors are updated based on a given branch. Branch predictor states are stored in a buffer, with each target branch having (in this case) 4 entries, one for each branch predictor. Based on slides in my computer architecture class, it seems that having 1024 entries per global state provides a significant decrease in mispredictions for most programs, so that is what will be implemented. This means that there are 1024 branches that can have their own local predictor, and the local predictors will be indexed using the 10 LSB's of their address. 

Finally, when a branch is predicted as taken, there must be a way to tell where to branch to immediately. This is done by storing the target address of a given branch in a Branch Target Buffer, or **BTB**. This buffer will also be indexed with the 10 LSB's of the target branch. As both the branch predictors and the target addresses are indexed by the same bits, space can be saved by storing all information in a shared buffer.

As there are 1024 entries per global state, and 4 global states, there will be 4096 total branch prediction entries, each being two bits. As each entry is indexed using 10 bits, and the target address also needs to be stored, this give a total amount of space taken up as: (1024 * (10 + 32)) + (1024*4*2) = 51200 bits, or 50KiB. This should be acceptable considering the 270KB of available BRAM for the target FPGA, as this leave about 264KB left over for the planned cache system, as well as anything else that may need it.



## **Microarchitecture Changes (Dec 31st \- Present):**
In order to accomodate more advanced branch prediction, the microarchitecture needs to be changed. As of now, the branch decoder only outputs PCSrcE, which updates the PC if a branch is taken. With dynamic branch prediction, will want to update the PC as soon as a B-type instruction is detected in the decode stage, based on the branch predictors current output. This is done using the BTB, which was discussed in the previous section.

To simplify this section, I will list everything that I believe needs to be done in order to implement the branch prediction system described in the previous section. I will then try to explain my plan for how to implement each entry in the list.
1. Need to change PCNextF mux to allow for actual branch result, or predicted branch result, or PCPlus4F, or PCPlus4E
2. Need to create a GHR that updates immediately after the result of a branch has been confirmed (in execution stage)
3. Need to create local branch predictors that only update if they are associated with the current GHR state, and only after the branch has been confirmed (in execution stage)
4. Need local branch predictors, whose "result" can be fetched based on branch index (in decode stage)
5. BTB starts with no valid or tag bits, and a naive overwrite policy (may change in future)
6. Need to allow BTB to be updated when branch target address is incorrect (in execution stage)
7. Need to update hazard control unit to be able to flush the decode, and execute pipeline registers on a misprediction, or when BTB does not have proper target address (in execution stage)
8. Need all branch predictors, and BTB to be able to be reset to a default value (will be weakly not take for local predictors, and untaken, untaken for GHR)

### **1 PCNextF extension**
PCNextF is the signal that tells the PC the location of the next instruction to fetch, and the multiplexer that determines this signal is currently controlled by the signal PCSrcE. This needs to be changed in order to allow for all possible branch addresses to be used. The multiplexer must decide between the **Target address calculated in the execution stage**, **PCPlus4**, and the **Predicted target address**. This means that this control signal can no longer be seen as originating from one particular stage, but rather a universal control signal. 

The new control signal will simply be called PCSrc, and will be two bits to accomodate a 4 to 1 multiplexer. It will be 4 to 1, as there are 4 possiblities that the PC may need to take on:
- PCPlus4F
- PCTarget (From Execution stage)
- PCTarget (From BTB)
- PCPlus4E

Each of these possiblities will be discussed later in this section.

This new PCSrc signal will need to take into account both the prediction made by the branch predictor, as well as the actual resolved branch value. Because of this, two internal signals will be created:

- PCSrcRes: The result produced by the branch decoder, holding the resolved result of a given branch that is currently in the execution stage.
- PCSrcPredD: The result produced by the branch predictor in the **Decode** stage.
- PCSrcPredE: the previous value of PCSrcPredD computed in the **Decode** stage. This is the signal that will be compared against PCSrcRes in order to determine the validity of the prediction.

The possible branching cases are listed below, along with the changes that must be made to PCSrc, and any flushes that may need to occur with each case.
- Not a branching instruction: PCSrc -> PCPlus4F
  - PCPred predicts not taken, PCRes will concur
- Branch predicted as not taken: PCSrc -> PCPlus4F
  - PCPred will predict not taken, once in execution stage, PCRes agrees
- Branch predicted as taken: PCSrc -> PCTarget (From BTB), FlushD
  - PCPred predicts taken, once in execution stage, PCRes agrees
- Branch predicted not taken, but mispredicted: PCSrc -> PCTarget (Execution stage), FlushD, FlushE
  - PCPred predicts not taken, once in execution stage, PCRes disagrees
- Branch predicted taken, but mispredicted: PCSrc -> PCPlus4E, FlushD, FlushE
  - PCPred preicts taken, once in execution stage, PCRes disagrees

The last case brings up an important issue, the fact that if a branch is predicted as taken, but mispredicted the old PCPlus4 value must be fetched. This means that the value of PCPlus4 must be passed along the pipeline until the execution stage, so that branches mispredicted as taken can be rolled back effectively. This will be dealt with in a seperate section.

Finally, the logic of the branch prediction unit can be described, along with the changes that must be made to the hazard unit to accomadate the need for more flushes. 


## **Two-Level Branch Predictor Design ():**

## Verilog Coding ():**

# **Challenges**

## **#1 Reworking Branching Logic (September 27th):**
**Changes made on October 2nd:** See [Changelog Sections #1](#Changelog)

This was initially a challenge as I intended to have the control unit within the **decode** stage module, however after the change listed in the mentioned changelog entry, it became a non-issue. I will leave the initial entry here in order to provide context for the inital challenge.

**Initial Entry:**

This was quite a challenge, as my initial design of the branching decoder relied on having both funct3, BranchOp, and the flags available at the same time. However, as the pipelined design calculates the flags in the Execution stage, if the branch decoder remained the same, it would use the flags from the execution stage, but the instruction from the decode stage. 

Ultimately I decided to route the funct3 and BranchOp signals to the **execute** stages pipeline register, and determine PCSrc there. Then I needed to decide how to represent this on the schematic. I could either route the signals in the **exectution** stage back to the control unit, or display the branch decoder as it's own module within the **execute** stage. I decided on the later, as this reduces the sprawl of the schematic. Even though it leads to a subsection of the control unit not being within the control unit, I believe the clarity it provides is worth the tradeoff.

## **#2 Unexpected Hazards (October 4th):**
During testing of the top-level module, I encountered an issue where some signals were not being forwarded correctly. This stemmed from not accounting for the additional instructions I had implemented beyond those supported by the textbook. As a result, I needed to introduce further hazard handling to ensure proper functionality.

The problematic instructions were primarily the U-type instructions (lui and auipc), and potentially the jal and jalr instructions. The issue arose because the hazard unit was designed to assume that the value to be written back to a register would always come from ALUResultM in the memory stage. While this assumption holds true for R-type and I-type instructions, it does not apply to the U-type and jump instructions.

lui writes ImmExt to the destination register, and auiPC writes PCTarget to the destination register. as for jal and jalr, they weren't included in the origional designs hazard handelling, likely because it used static branch handelling, meaning whenever a jump was taken, the stages that would have been forwarded to get flushed anyways. However at some point I plan to add more involved branch prediction, meaning that my processor must handle this as well.

To solve this problem I decided to add a multiplexer to the memory stage that selects the value that will be written back to a register. This is the signal that will be sent to the hazard unit rather than just ALUResultM. Solving the issue this way minimizes the changes needed to solve the problem, and only requires the addition of a single multiplexer. Beyond that, this solution allows for the ResultSrcM signal to be used as the select signal for said multiplexer. Note that the result read from memory will not be sent to this multiplexer, as loaded instruction result in a stall, with the result then being forwarded from the **writeback** stage.

All changes that I actually make to the hazard control unit will be found in the following sections: [Memory Stage](#memory-stage-october-1st). Since this section provides a comprehensive explanation of the issue, I will only provide a brief summary of the modifications in the changelog, with a reference to this section for full details.

## **#3 Register File Read Before Write Hazard (October 4th):**
My register file design introduced a hazard where the result from the writeback stage wasn't available until the following cycle. This caused an issue if the write register matched either of the read registers, as the updated value wouldn't be passed to the execute stage in time. The problem arose because the register file is a synchronous module, where writes occur only on the rising edge of the clock. As a result, after the writeback stage produces a value, one clock cycle must pass before it's written to the register file.

To solve this, I implemented a write-first register file. If either read register matches the write register, the write data is forwarded directly to the read output, ensuring the correct value is available during execution.

This solution was implemented using an always block that checks both read registers. If either matches the write register and writing is enabled, the write data is forwarded; otherwise, the normal read process occurs.

# **Changelog**

## **#1 Change Location of Register File, Control Unit, Branch Decoder, Instruction Memory, and Datam Memory (October 2nd):**
Initially I included all of the modules listed above within pipeline stage modules. As I began working on the top level module, I realized how unintuitive it was to have modules used by the whole system within one stages module, especially in the case of the register file. As the register file was within the decode stage, I decided to also include the writeback stage within the decode stage module. This further complicated and confused the design.

The control unit and branch decoder being with the decode and Execute stage respectively doesn't overly complicate their module, as their inputs and outputs are self contained with the module they are within. However, after beginning work on the top level module, I believe that including them as their own modules within the top-level module is the best route of action, as it makes it clear that they are modules that affect the whole pipeline, and not just combinational logic thats used in determining outputs of a given pipeline stage. Not only that, but it allows for the branch decoder to again be included within the control unit, consolidating the main control unit.

As for the instruction and data memory, including them directly within pipeline stage modules is not a very accurate representation of their location within the hierarchy. As such, I believe that moving the instruction memory out of the fetch stage, and the data memory out of the memory stage will simplify the overall design.

This also allows me to add another level of abstraction to again simplify the design, having the standard datapath and control unit within a processor module, and the data memory and instruction memory within the top-level modue (alongside the processor module).

## **#2 Including Pipeline Registers within Stage Modules (October 2nd):**
Initially I was planning to include the pipeline registers within the top-level module. However as I was making the changes noted in the previous section, I realized that I could again greatly simplify the top-level design by including each stages input registers within the pipeline stage module itself. As some pipeline stages only contain one or two modules, this also ensures that the use of modules for each pipeline stage actually does simplify the design. 

I also realized that doing this would allow me to combine signals as inputs to the pipeline register, and decouple the output of the pipeline register within the pipeline stage module. Doing this within a pipeline module greatly reduces the signal sprawl that would have been present within the top-level module had no change been made.

## **#3 Synchronous Reset for Registers (October 3rd):**
While assembling the datapath module, I realized that the flush signals were initially designed as asynchronous resets, but they should actually function as synchronous resets. This prompted a change in the flop module, where I shifted from asynchronous to synchronous resets.

The decision to move to synchronous resets was driven by simplicity and the nature of the system. There is no critical need for asynchronous resets in this design, as the clock signal is always active. As a result, the system should reliably reset when required, and synchronous resets won't introduce any timing issues or complications. Given that the clock is consistently oscillating, a synchronous reset will effectively reset the system without causing disruptions to the overall functionality.

## **#4 Updated Hazard Handelling (October 4th):**
The initial hazard handelling implemented in the processor at the point of writing was not suffecient to deal with all RAW hazards that arise in the **memory** stage. This is due to an assumption about the value that was to be written back to a register not holding true for a subset of the implemented instructions. This lead to incorrect values being forwarded from the **memory** stage back to the **execution** stage. A more comprehensive review of this issue can be foun in [Challenges section #2](#2-unexpected-hazards-october-4th).