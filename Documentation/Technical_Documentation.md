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
|BranchOP|Assists in determining if a branch is to occur (further dependant on funct3 and flags)|
|PCSrc|Determines if branch/jump is actually to take place| 
|ALUOp|Assists in determining ALU operation (further dependant on funct3 and funct7)|
|ALUControl|Determines the ALU operation|
|WidthOp|Assists in determining WidthSrc|
|WidthSrc|Determines the width of meaningful data in result signal|
|PCBaseSrc|Determines what will be added to an immediate when calculating PCTarget|

Note that PCSrc is calculated using the **branch decoder**, which is not located directly within the control unit in this design.

## Main Decoder
The main decoder takes in an opcode, and generates the majority of control signals, as well as signals that assist in the decoding done by other more specialized decoding modules.

| Instruction         | Op    | RegWrite | ImmSrc | ALUSrc | MemWrite | ResultSrc | BranchOp | ALUOp | WidthOp | PCBaseSrc |
|---------------------|-------|----------|--------|--------|----------|-----------|----------|-------|---------|-|
|R-type               |0110011|1         |xxx     |0       |0         |000        |00        |10     |0        |x|
|I-type ALU           |0010011|1         |000     |1       |0         |000        |00        |10     |0        |x|
|I-type Load          |0000011|1         |000     |1       |0         |100        |00        |00     |1        |x|
|S-type               |0100011|0         |001     |1       |1         |0xx        |00        |00     |1        |x|
|B-type               |1100011|0         |010     |0       |0         |0xx        |10        |01     |x        |0|
|jal                  |1101111|1         |011     |x       |0         |010        |01        |xx     |0        |0|
|jalr                 |1100111|1         |000     |x       |0         |010        |01        |xx     |0        |1|
|lui                  |0110111|1         |100     |x       |0         |011        |00        |xx     |0        |x|
|auipc                |0010111|1         |100     |x       |0         |001        |00        |xx     |0        |0|

## Branch Decoder
I decided to implement an extra decoder in order to deal with branching logic. This decoder will take in the flags generated by the ALU, funct3, and BranchOp. BranchOp is generated by the main decoder, and used to determine branching, much like the signal ALUOp. Branching depends on flag conditions, so the truth table includes a flag operation column to account for various outcomes. Note that although this is called the Branch decoder, it will also be be dealing with jumps as well, which in essence, are an unconditional branch.

The truth table for determining Branch, as well as the flag operation that is performed is described as follows:

| Instructions             | BranchOp | funct3 | Flag Operation | PCSrc |
|--------------------------|----------|--------|----------------|-------|
|Non-branching Instructions|00        |xxx     |0               |0      |
|Jumps                     |01        |xxx     |1               |1      |
|beq                       |10        |000     |Z               |FD     |
|bne                       |10        |001     |Z'              |FD     |
|bge                       |10        |101     |(N^V)'          |FD     |
|bgeu                      |10        |111     |C               |FD     |
|blt                       |10        |100     |N^V             |FD     |
|bltu                      |10        |110     |C'              |FD     |

Note that within this table. FD = flag dependant, meaning it depends on the result of the flag operation. If the flag operation results in 1 (or true), then PCSrc will also be 1, and vice versa.

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

| Instructions | ALUOp | funct3 | op[5], funct7[5] | ALUControl |
|--------------|-------|--------|-------------------|-------------|
|S-Type instructions|00| x      | x                 | 1000        |
|I-type loads  |00     | x      | x                 | 1000        |
|B-type instructions|01| x      | x                 | 1001        |
|add, addi     |   10  | 000    | 00, 01, 10        | 1000        |
|sub           |   10  | 000    | 11                | 1001        |
|slt           |   10  | 010    | x                 | 0101        |
|sltu          |   10  | 011    | x                 | 0110        |
|or, ori       |   10  | 110    | x                 | 0011        |
|xor, xori     |   10  | 100    | x                 | 0100        |
|and, andi     |   10  | 111    | x                 | 0010        |
|sll, slli     |   10  | 001    | x                 | 0111        |
|srl, srli     |   10  | 101    | 00, 10            | 0000        |
|sra, srai     |   10  | 101    | 11, 01            | 0001        |

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
|LoadStall  |Determines if a stall due to a load should occur|
|StallF     |Determines if a freeze should occur on the **fetch** stages pipeline register|
|StallD     |Determines if a freeze should occur on the **decode** stages pipeline register|
|FlushE     |Determines if a flush should occur on the **execute** stages pipeline register|
|FlushD     |Determines if a flush should occur on the **decode** stages pipeline register|

### Signal Value Description Table
The following table outlines what each signal value represents (For single bit signals, only active value will be described):

| Signal Name | Output | Description |
|-------------|--------|-------------|
|ForwardAE/BE | 10     |Forward result from **memory** stage to **execute** stage|
|ForwardAE/BE | 01     |Forward result from **writeback** stage to **execute** stage|
|ForwardAE/BE | 00     |No forwarding is to occur|
|LoadStall    | 1      |A stall due to a load should occur|
|StallF       | 1      |**Fetch** stages pipeline register will be stalled|
|StallD       | 1      |**Decode** stages pipeline register will be stalled|
|FlushE       | 1      |**Execute** stages pipeline register will be flushed|
|FlushD       | 1      |**Decode** stages pipeline register will be flushed|


### Hazard Unit Governing Equations
Each signal generated by the hazard unit has specific conditions that determine its output. The following sections describe the logic equations governing the behavior of the hazard unit signals.

**ForwardAE**:
((Rs1E == RdM) & RegWriteM) & (Rs1E != 0) -> ForwardAE = 10
((Rs1E == RdW) & RegWriteW) * (Rs1E != 0) -> ForwardAE = 01
All other inputs -> ForwardAE = 00

**ForwardBE**:
((Rs2E == RdM) & RegWriteM) & (Rs2E != 0) -> ForwardBE = 10
((Rs2E == RdW) & RegWriteW) * (Rs2E != 0) -> ForwardBE = 01
All other inputs -> ForwardBE = 00

**LoadStall**
ResultSrcE[2] & ((Rs1D == RdE) | (Rs2D == RdE)) -> LoadStall = 1

**StallF**
LoadStall -> StallF = 1

**StallD**
LoadStall -> StallD = 1

**FlushE**
LoadStall | PCSrcE -> FlushE = 1

**FlushD**
PCSrcE -> FlushD = 1

## Testing and Validation
The design includes testbenches for individual components, as well as a top-level testbench for overall validation. The following details the testing setup:

- Component Tests: The ALU, Extension, and Reduce components require the generation of test vectors using the Python script test_vector_generation.py, located in the "Test_Files" directory.

- Top-Level Testbench: As of now the top-level module is not complete, and as such there is no top-level testbench. That being said, RISC-V test programs are still currently located with the "Test_Files" directory.

- Independent Testbenches: Aside from the files required for the components mentioned above, all other testbenches can run independently without additional setup.