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

# **Pipelining (September 26th \- ):**

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
Forwarding is employed to resolve RAW (Read After Write) hazards wherever possible, except for hazards caused by load instructions. When forwarding is possible, the value of a destination register currently in the **memory** or **writeback** stage is forwarded to the **execution** stage, provided the RegWrite signal is active. If RegWrite is inactive, the destination register is not modified, and no forwarding is needed.

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

## **Verilog Coding (September 29th \- ):**

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
**Changes made on October 2nd:** See [Changelog Sections #1 and #2](#Changelog)
This stage contains the reduction unit for adjusting data width and interfaces with the data memory module. The primary role of this stage is to handle the exchange of data between the processor and data memory, with control signals managing these interactions.

Data read from memory is passed to the **writeback** stage's pipeline register, along with other outputs from this stage. Additionally, some of this data is sent to the hazard unit or used in forwarding register values to the **execution** stage.

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

**Testing**
As this module isn't structural in any way it makes sense to ensure the outputs are as expected. I created a testbench using only SystemVerilog. It likely wasn't necessary, but I designed the testbench to test every combination of registers for both ForwardAE and ForwardBE. For stall and flush testing, I setup the inputs to cover a large number of combinations to ensure that the correct flush and stall signals were always produced.

I started the design by creating tasks to deal with asserting the correct values, and printing informitive error messages. For both forwading and stall/flush testing I used nested for loops. In forward testing these for loops looped through each possible register combination and ensured that the correct hazard signal was produced. This was done for both ForwardAE and ForwardBE. The inner loop went up to 64, with the first 32 iterations changing the register value associated with ForwardAE, and the last 32 iterations changing the register value associated with ForwardBE.

As mentioned above, stall and flush signal inputs were varied in order to ensure many combinations were calcualted correctly. This was done by again making the inner for loop go up to 64. Different ranges of this inner loops variable lead to different inputs being given differnt values, resulting in many possible combinations being covered.


# **Challenges**

## **#1 Reworking Branching Logic (September 27th):**
**Changes made on October 2nd:** See [Changelog Sections #1](#Changelog)

This was initially a challenge as I intended to have the control unit within the **decode** stage module, however after the change listed in the mentioned changelog entry, it became a non-issue. I will leave the initial entry here in order to provide context for the inital challenge.

**Initial Entry:**

This was quite a challenge, as my initial design of the branching decoder relied on having both funct3, BranchOp, and the flags available at the same time. However, as the pipelined design calculates the flags in the Execution stage, if the branch decoder remained the same, it would use the flags from the execution stage, but the instruction from the decode stage. 

Ultimately I decided to route the funct3 and BranchOp signals to the **execute** stages pipeline register, and determine PCSrc there. Then I needed to decide how to represent this on the schematic. I could either route the signals in the **exectution** stage back to the control unit, or display the branch decoder as it's own module within the **execute** stage. I decided on the later, as this reduces the sprawl of the schematic. Even though it leads to a subsection of the control unit not being within the control unit, I believe the clarity it provides is worth the tradeoff.

# **Changelog**

## **#1 Change Location of Register File, Control Unit, Branch Decoder, Instruction Memory, and Datam Memory(October 2nd):**
Initially I included all of the modules listed above within pipeline stage modules. As I began working on the top level module, I realized how unintuitive it was to have modules used by the whole system within one stages module, especially in the case of the register file. As the register file was within the decode stage, I decided to also include the writeback stage within the decode stage module. This further complicated and confused the design.

The control unit and branch decoder being with the decode and Execute stage respectively doesn't overly complicate their module, as their inputs and outputs are self contained with the module they are within. However, after beginning work on the top level module, I believe that including them as their own modules within the top-level module is the best route of action, as it makes it clear that they are modules that affect the whole pipeline, and not just combinational logic thats used in determining outputs of a given pipeline stage. Not only that, but it allows for the branch decoder to again be included within the control unit, consolidating the main control unit.

As for the instruction and data memory, including them directly within pipeline stage modules is not a very accurate representation of their location within the hierarchy. As such, I believe that moving the instruction memory out of the fetch stage, and the data memory out of the memory stage will simplify the overall design.

This also allows me to add another level of abstraction to again simplify the design, having the standard datapath and control unit within a processor module, and the data memory and instruction memory within the top-level modue (alongside the processor module).

## **#2 Including Pipeline Registers within Stage Modules(October 2nd):**
Initially I was planning to include the pipeline registers within the top-level module. However as I was making the changes noted in the previous section, I realized that I could again greatly simplify the top-level design by including each stages input registers within the pipeline stage module itself. As some pipeline stages only contain one or two modules, this also ensures that the use of modules for each pipeline stage actually does simplify the design. 

I also realized that doing this would allow me to combine signals as inputs to the pipeline register, and decouple the output of the pipeline register within the pipeline stage module. Doing this within a pipeline module greatly reduces the signal sprawl that would have been present within the top-level module had no change been made.