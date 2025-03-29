# RISC-V-Pipelined Technical Documentation
Includes explanation of components, truth tables of components, supported instructions, hazards, pipeline stages, and testing procedures.

## Supported instructions

| Instruction | Type | Opcode | Description |
|-------------|------|--------|-------------|
| `lw`        |'I'   | 0000011|Load word in rd|
| `lh`        |'I'   | 0000011|Load signed halfword in rd|
| `lhu`       |'I'   | 0000011|Load unsigned halfword in rd|
| `lb`        |'I'   | 0000011|Load signed byte in rd|
| `lbu`       |'I'   | 0000011|Load unsigned byte in rd|
| `lui`       |'U'   | 0110111|Load immediate into upper 20-bits of rd|
| `auipc`     |'U'   | 0010111|Add upper immediate to PC|
| `sw`        |'S'   | 0100011|Store word|
| `sh`        |'S'   | 0100011|Store halfword|
| `sb`        |'S'   | 0100011|Store byte|
| `add`       |'R'   | 0110011|Add two registers|
| `sub`       |'R'   | 0110011|Subtract two registers|
| `and`       |'R'   | 0110011|AND two registers|
| `or`        |'R'   | 0110011|OR two registers|
| `xor`       |'R'   | 0110011|XOR two registers|
| `slt`       |'R'   | 0110011|Sets if rs1 < rs2|
| `sltu`      |'R'   | 0110011|Sets if rs1 < rs2 in unsigned representation|
| `sll`       |'R'   | 0110011|Shift left logical|
| `srl`       |'R'   | 0110011|Shift right logical|
| `sra`       |'R'   | 0110011|Arithmetic shift right|
| `beq`       |'B'   | 1100011|Branches if equal|
| `bne`       |'B'   | 1100011|Branches if not equal|
| `bge`       |'B'   | 1100011|Branches if greater or equal to|
| `bgeu`      |'B'   | 1100011|Branches if greater or equal to (unsigned)|
| `blt`       |'B'   | 1100011|Branches if less than|
| `bltu`      |'B'   | 1100011|Branches if less than (unsigned)|
| `jal`       |'J'   | 1101111|Jump and link|
| `jalr`      |'I'   | 1100111|Jump and link register|
| `addi`      |'I'   | 0010011|Add immediate|
| `andi`      |'I'   | 0010011|AND a register and an immediate|
| `ori`       |'I'   | 0010011|OR a register and an immediate|
| `xori`      |'I'   | 0010011|XOR a register and an immediate|
| `slli`      |'I'   | 0010011|Shift left logical by an immediate|
| `srli`      |'I'   | 0010011|Shift right logical by an immediate|
| `srai`      |'I'   | 0010011|Arithmetic shift right by an immediate|

## Memory Interface
As of now, this design assumes a memory that can be accessed in a single-cycle, and uses both a data memory, and an instruction memory. It has two seperate memories, one for instructions and the other for data. Data memory can be written to and read from, and is byte-addressable. The instruction memory is read only and must have it's contents loaded in before synthesis.

## Pipeline Stages
This design consists of five pipeline stages:

### Fetch Stage
The fetch stage consists of the PC register, instruction memory, and an adder to determine PCPlus4. It fetches instructions from memory based on the current PC address, and updates the PC to the address of the next instruction (PCPlus4 or PCTarget).

### Decode Stage
The decode stage includes the control unit, register file, and extension unit. It decodes the fetched instruction, generates the necessary control signals for subsequent stages, and extends immediate values as needed.

### Execute Stage
Consists of the ALU, the branch decoder, and an additon unit. Performs arithemtic operations using the ALU, determines if a branch is to occur, and calculates the PC target address.

### Memory Stage
Consists of the data memory and reduce unit. Stores or loads data from memory, and determines width of fetched data as needed.

### Writeback Stage
Consists of a result multiplexer, as well as the register file. Selects which result to write back to the register file (if any at all), and writes result to the register file.

## Control Unit
This processors control unit currently contains the following control signals. Note that this table includes internal control signals which are not seen on the final schematic.

| Control Signal | Function |
|----------------|----------|
|RegWrite|Determine if RF is to be written to, active high|
|ImmSrc|Determines how the extension unit is to extend an immediate|
|ALUSrc|Determines B operand ALU is to recieve|
|MemWrite|Determines if data memory is to be written to, active high|
|ResultSrc|Determines what value is to be written back to RF|
|BranchOp|Assists in determining if a branch is to occur (further dependant on funct3 and flags)|
|ALUOp|Assists in determining ALU operation (further dependant on funct3 and funct7)|
|ALUControl|Determines the ALU operation|
|WidthOp|Assists in determining WidthSrc|
|WidthSrc|Determines the width of meaningful data in result signal|
|PCBaseSrc|Determines what will be added to an immediate when calculating PCTarget|

## Main Decoder
The main decoder takes in an opcode, and generates the majority of control signals, as well as signals that assist in the decoding done by other more specialized decoding modules.

| Instruction         | Op    | RegWrite | ImmSrc | ALUSrc | MemWrite | ResultSrc | BranchOp | ALUOp | WidthOp | PCBaseSrc |
|---------------------|-------|----------|--------|--------|----------|-----------|----------|-------|---------|-|
|R-type               |0110011|1         |xxx     |0       |0         |000        |00        |10     |0        |x|
|I-type ALU           |0010011|1         |000     |1       |0         |000        |00        |10     |0        |x|
|I-type Load          |0000011|1         |000     |1       |0         |100        |00        |00     |1        |x|
|S-type               |0100011|0         |001     |1       |1         |0xx        |00        |00     |1        |x|
|B-type               |1100011|0         |010     |0       |0         |0xx        |11        |01     |x        |0|
|jal                  |1101111|1         |011     |x       |0         |010        |01        |xx     |0        |0|
|jalr                 |1100111|1         |000     |x       |0         |010        |01        |xx     |0        |1|
|lui                  |0110111|1         |100     |x       |0         |011        |00        |xx     |0        |x|
|auipc                |0010111|1         |100     |x       |0         |001        |00        |xx     |0        |0|

## Width Decoder
This decoder is used to determine the width of data stored or fetched from memory. It takes a control signal from the main decoder, WidthOp, as well as funct3 in order to determine what width of data is to be either stored or loaded to/from data memory. The resulting control signal WidthSrc is sent both directly to the data memory to handle store instructions, as well as to an extension unit (called "reduce") right after data memory. The generated control signal WidthSrc determines the width of data either stored or retrieved from memory.

The truth table for determining the value of WidthSrc, is described as follows:

| Instructions              | WidthOp | funct3 | WidthSrc |
|---------------------------|---------|--------|----------|
|non-store/load instructions|0        |xxx     |000       |
|lw, sw                     |1        |010     |000       |
|lh, sh                     |1        |001     |010       |
|lb, sb                     |1        |000     |001       |
|lhu                        |1        |101     |110       |
|lbu                        |1        |100     |101       |

The following table describes the behaviour of width setting modules

| WidthSrc | width |
|----------|-------|
|000       |32-bits|
|010       |16-bits signed|
|110       |16-bits unsigned|
|001       |8-bits signed|
|101       |8-bits unsigned|

## ALU
The ALU implements add, subtract, and, or, xor, slt, sltu, sll, srl, and sra. All extensions are handeled by an extension unit.

| Instructions | ALUOp | funct3D | opD[5], funct7D[5]| ALUControlD |
|--------------|-------|---------|-------------------|-------------|
|S-Type instructions|00| x       | x                 | 1000        |
|I-type loads  |00     | x       | x                 | 1000        |
|B-type instructions|01| x       | x                 | 1001        |
|add, addi     |   10  | 000     | 00, 01, 10        | 1000        |
|sub           |   10  | 000     | 11                | 1001        |
|slt           |   10  | 010     | x                 | 0101        |
|sltu          |   10  | 011     | x                 | 0110        |
|or, ori       |   10  | 110     | x                 | 0011        |
|xor, xori     |   10  | 100     | x                 | 0100        |
|and, andi     |   10  | 111     | x                 | 0010        |
|sll, slli     |   10  | 001     | x                 | 0111        |
|srl, srli     |   10  | 101     | 00, 10            | 0000        |
|sra, srai     |   10  | 101     | 11, 01            | 0001        |

Note that the ALU control has the ALU perform the following operations:
| ALUControl | Operation |
|------------|-----------|
|0000|shift right logical (srl)|
|0001|shift right arithmetic (sra)|
|0010|and|
|0011|or|
|0100|xor|
|0101|set less than (slt)|
|0110|set less than unsigned (sltu)|
|0111|shift left logical (sll)|
|1000|add|
|1001|subtract|

## Branch Processing Unit
This is a top level module alongside the data-path and control unit, and is responsible for all branching decisions. It consists of the Branch Resolution Unit (BRU), Branch Control Unit (BCU), and the Branch Predictor modules.

It uses the following control signals:
| Control Signal | Function |
|----------------|----------|
|PCSrcPred|Holds predicted result of a branch|
|PCSrcRes|Holds actual result of branch. Used to check against branch predictor result|
|PCSrc|Determines the next value that is to be sent to the PC register|

## Branch Resolution Unit
This decoder will take in the flags generated by the ALU, funct3, and BranchOp. BranchOp is generated by the main decoder, and used to determine branching, much like the signal ALUOp. Branching depends on flag conditions, so the truth table includes a flag operation column to account for various outcomes. This will produce a signal called PCSrcRes. PCSrcRes will be used by the branch predictor in order to determine if a branch prediction was correct or not. Although this is called the Branch Resolution Unit, it will also be be dealing with jumps, which in essence, are an unconditional branch.

Also note that as this only actively uses signals from the execution stage, the signals in the following truth table will be named accordingly.

The truth table for determining PCSrcRes, as well as the flag operation that is performed is described as follows:

| Instructions             | BranchOpE | funct3E | Flag Operation | PCSrcRes |
|--------------------------|-----------|---------|----------------|----------|
|Non-branching Instructions|00         |xxx      |0               |0         |
|Jumps                     |01         |xxx      |1               |1         |
|beq                       |11         |000      |Z               |FD        |
|bne                       |11         |001      |Z'              |FD        |
|bge                       |11         |101      |(N^V)'          |FD        |
|bgeu                      |11         |111      |C               |FD        |
|blt                       |11         |100      |N^V             |FD        |
|bltu                      |11         |110      |C'              |FD        |

Note that within this table. FD = flag dependant, meaning it depends on the result of the flag operation. If the flag operation results in 1 (or true), then PCSrc will also be 1, and vice versa.

## Branch Control Unit
This takes data from the main decoder in order to predict whether a branch is to be taken or not, as well as data from the Branch Resolution Unit in order to verify the prediction. In the case of a mispredicton it will properly set the next PC address, all rollbacks will be dealt with using the hazard control unit. The Active Signal is set in the decode stage if a branch occurs, when active in the execution stage, signals that the PCSrc signal from the execution stage is to take precedence. In all other cases, the PCSrc signal from the decode stage takes precedence. The TargetMatch signal is set high when the address fetched from the BTB mathces that determined in the execution stage. In all other cases, it will be set low.

The value of PCNext based on PCSrc are given by the following table:
| PCNext      | Function                     |PCSrc |
|-------------|------------------------------|------|
|PCPlus4F     |Sequential fetch              |00    |
|PredPCTargetF|Predicted branch address      |01    |
|PCTargetE    |Actual/resolved branch address|11    |
|PCPlus4E     |Rollback sequential fetch     |10    |


This table will describe the result of PCSrc based on InstrF[6:5] (Same as OpF[6:5]), and the branch predictors prediction.
| Instruction Type | InstrF[6:5] | PCSrcPredF |  PCSrc |
|------------------|-------------|------------|--------|
|Non-Branching     |10/00/01     |0           |00      |
|Branch/Jump       |11           |1           |01      |
|Branch            |11           |0           |00      |

This second table describes the behaviour based on the comparison of the prediction, and the actual branch:
| TargetMatchE | BranchOpE[0] | PCSrcPredE | PCSrcResE | PCSrc   |
|--------------|--------------|------------|-----------|---------|
|1             |1             |1           |1          |N/A      |
|0             |1             |1           |1          |11       |
|x             |1             |1           |0          |10       |
|x             |1             |0           |1          |11       |
|x             |1             |0           |0          |N/A      |
|x             |0             |x           |x          |N/A      |

Note that in the above table, N/A in the PCSrc column means that the result will be dependant on the result of table 1. To accomodate this, logic internal to the Branch Control Unit will determine how PCSrc is determined.

## Branch Predictor

The branch predictor is made up of the GHR, the BTB, and a bank of local predictors. As they are indexed at the same time, the BTB and local predictors are lumped into a block called the Branching Buffer. All outputs used by other blocks come from the Branching Buffer. The tables describing the state machines, and combinational logic are below

### **GHR:**

The following table describes the output of each state.

| Current State  | LocalSrc |
|----------------|----------|
|U, U            |00        |
|U, T            |01        |
|T, U            |10        |
|T, T            |11        | 

The following table describes the state transitions based on the current state, and input

| Current State | PCSrcRes | Next State |
|---------------|----------|------------|
| U, U          | 0        | U, U       |
|               | 1        | U, T       |
| U, T          | 0        | T, U       |
|               | 1        | T, T       |
| T, U          | 0        | U, U       |
|               | 1        | U, T       |
| T, T          | 0        | T, U       |
|               | 1        | T, T       |

**Note: This will only update when BranchOpE[0] is 1**

### **Branching Buffer: Conceptual Overview**

The Branching Buffer is responsible for storing branch prediction information, including:
1. **Branch Target Addresses:** Predicted target addresses for branches, stored in the Branch Target Buffer (BTB).
2. **Local Branch Predictor States:** Predicts whether branches are likely to be taken or not, based on past behavior.

The Branching Buffer is indexed using the **10 least significant bits (LSBs)** of the program counter (`PCF[9:0]`). Each indexed entry provides:
- A predicted branch target address (`PredPCTargetF`).
- A predicted branch decision (`PCSrcPred`).

The Branching Buffer is updated in the **Execute stage** when the branch result is resolved. If the predicted target address does not match the resolved target (`TargetMatch = 0`), the buffer entry is updated with the resolved address, and the local branch predictor is reset to the state "weakly untaken".

### **Branching Buffer: Detailed Design**

#### **Inputs and Outputs**
| Signal         | Direction  | Description                                                                 |
|----------------|------------|-----------------------------------------------------------------------------|
| `PCF[9:0]`     | Input      | Indexes the buffer to retrieve prediction data for the current instruction. |
| `TargetMatch`  | Input      | Indicates if the predicted and resolved branch targets match.               |
| `BranchOpE[0]` | Input      | Enables updates to the buffer in the Execute stage.                         |
| `PCTargetE`    | Input      | Resolved branch target address for the current branch (execute stage).      |
| `LocalSrc`     | Input      | Determines which local predictor state machine to access.                   |
| `PCSrcPredF`   | Output     | Predicted branch decision for the current instruction (fetch stage).       |
| `PredPCTargetF`| Output     | Predicted branch target address for the current instruction (fetch stage).  |

#### **Update Logic**
Updates to the Branching Buffer occur in the **Execute stage**, gated by `BranchOpE[0]`. The following rules apply:
1. If `TargetMatch = 0`, the resolved branch target (`PCTargetE`) replaces the current buffer entry.
2. The local branch predictor's state is updated based on the resolved branch outcome (`PCSrcRes`).

#### **Initial State**
- All buffer entries are initialized to **weakly untaken** for local predictors and a default branch target of 0.

## Immediate Extension
The immediate extension unit needs to extend immediates depending on the type of instruction the immediate recieves. The type of extension is controlled by the signal ImmSrc. Note that this extension unit takes advantage of the fact that the most significant bit of all immediates is always held in bit 31 of instr. The following table describes the extension units behaviour.

| ImmSrc | ImmExt | Instruction Type | Description |
|--------|--------|------------------|-------------|
|000|{{20{Instr[31]}}, Instr[31:20]}| I | 12-bit signed immediate extension|
|001|{{20{Instr[31]}}, Instr[31:25], Instr[11:7]}| S | 12-bit signed immediate extension|
|010|{{20{Instr[31]}}, Instr[7], Instr[30:25], Instr[11:8], 1'b0}| B | 13-bit signed immediate extension|
|011|{{12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0}| J | 21-bit signed immediate extension|
|100|{Instr[31:12], 12'b0}| U | Zero-extend bottom 12-bits of upper immediate|

## Hazard Unit
The hazard unit deals with hazards that arise from complications created by pipelining the design. To deal with hazards, two methods are employed: forwarding and stalling. Forwarding forwards a result from a later stage to an earlier stage, and stalling stops operation of the pipeline to give time for a result to be determined.

### Signals Generated by Hazard Unit

|Signal Name| Description |
|-----------|-------------|
|ForwardAE  |Determines if a signal is to be forwarded to the SrcA input of the ALU from the **memory** or **writeback** stage|
|ForwardBE  |Determines if a signal is to be forwarded to the BrcA input of the ALU from the **memory** or **writeback** stage|
|LoadStall  |Determines if a stall due to a load should occur (Internal signal)|
|StallF     |Determines if a freeze should occur on the **fetch** stages pipeline register|
|StallD     |Determines if a freeze should occur on the **decode** stages pipeline register|
|FlushE     |Determines if a flush should occur on the **execute** stages pipeline register|
|FlushD     |Determines if a flush should occur on the **decode** stages pipeline register|

### Signal Value Description Table
The following table outlines what each signal value represents, and it's governing equation:

| Signal Name | Equation                                       | Output | Description |
|-------------|------------------------------------------------|--------|-------------|
|ForwardAE    |((Rs1E == RdM) & RegWriteM) & (Rs1E != 0)       | 10     |Forward result from **memory** stage to **execute** stage|
|ForwardAE    |((Rs1E == RdW) & RegWriteW) & (Rs1E != 0)       | 01     |Forward result from **writeback** stage to **execute** stage|
|ForwardAE    |All other inputs                                | 00     |No forwarding occurs|
|ForwardBE    |((Rs2E == RdM) & RegWriteM) & (Rs2E != 0)       | 10     |Forward result from **memory** stage to **execute** stage|
|ForwardBE    |((Rs2E == RdW) & RegWriteW) & (Rs2E != 0)       | 01     |Forward result from **writeback** stage to **execute** stage|
|ForwardBE    |All other inputs                                | 00     |No forwarding occurs|
|LoadStall    |ResultSrcE[2] & ((Rs1D == RdE) \| (Rs2D == RdE))| 1      |A stall due to a load should occur|
|StallF       |(LoadStall \| InstrMissF) & ~PCSrcReg[1]        | 1      |**Fetch** stages pipeline register will be stalled|
|StallD       |LoadStall \| InstrMissF                         | 1      |**Decode** stages pipeline register will be stalled|
|StallE       |InstrMissF                                      | 1      |**Execute** stages pipeline register will be stalled|
|FlushE       |PCSrc[1] & (CacheActive \| PCSrcReg[1])         | 1      |**Execute** stages pipeline register will be flushed|
|FlushD       |PCSrc[1]                                        | 1      |**Decode** stages pipeline register will be flushed|

## Testing and Validation
The design includes testbenches for individual components, as well as a top-level testbench for overall validation. The following details the testing setup:

- Component Tests: The ALU, Extension, and Reduce components require the generation of test vectors using the Python script test_vector_generation.py, located in the "Test_Files" directory.

- Top-Level Testbench: As of now the top-level module is not complete, and as such there is no top-level testbench. That being said, RISC-V test programs are still currently located with the "Test_Files" directory.

- Independent Testbenches: Aside from the files required for the components mentioned above, all other testbenches can run independently without additional setup.