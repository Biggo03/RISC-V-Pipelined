# Pipeline

## Overview
This document describes the processor’s pipeline organization, including the five execution stages, control flow, and mechanisms for maintaining correct operation.  
The pipeline follows a classic five-stage in-order design, extended with hazard handling, forwarding, and branch prediction support.

## Pipeline Stages

### Instruction Fetch (IF)

The instruction fetch stage retrieves instructions from the instruction cache using the current program counter (PC).  
It provides the PC to the branch processing unit and includes the multiplexer that selects the next PC value.

**Primary responsibilities:**
- Provide the current PC to the instruction cache and branch processing unit.  
- Request the corresponding instruction word from the instruction cache.  
- Update the PC using the selected source (sequential, branch target, jump target, etc.).  
- Respond to stall control from the hazard unit.  

**Inputs:**
- Stall control from the hazard unit.  
- Branch target and prediction information from the branch processing unit.  
- Instruction hit and replacement status from the instruction cache.  

**Outputs:**
- Current PC and fetched instruction to the decode stage.  
- PC value to the branch processing unit.

### Instruction Decode (ID)

The decode stage interprets the fetched instruction and generates the control signals required for subsequent stages.  
It extracts register and immediate fields, produces control outputs, and provides the information used by the hazard unit for dependency checking.

**Primary responsibilities:**
- Decode opcode, funct3, and funct7 fields.  
- Generate control signals for ALU operation, memory access, branching, and writeback.  
- Read register operands from the register file.  
- Sign-extend immediates as required.  
- Provide register and control information to the hazard unit for hazard detection.  

**Outputs:**
- Operand values, control signals, and decoded instruction fields to the execute stage.  
- Register source and destination information to the hazard unit.

### Execute (EX)

The execute stage performs arithmetic, logic, and branch-related operations.  

**Primary responsibilities:**
- Perform ALU operations based on control signals.  
- Calculate memory addresses for load and store instructions.  
- Evaluate branch conditions and determine whether a branch is taken.  
- Calculate branch target addresses for conditional and unconditional branches.  
- Forward results to dependent instructions where applicable.  

**Inputs:**
- Operands and control signals from the decode stage.  
- Forwarded data from later pipeline stages.  

**Outputs:**
- ALU result, branch decision, and target address to subsequent stages.

### Memory Access (MEM)

The memory stage handles data memory operations.  
Currently, the processor directly interfaces with a simple data memory module. A data cache will be introduced later.

**Primary responsibilities:**
- Perform load and store operations.  
- Forward memory results to earlier pipeline stages if needed.  
- Apply data width and signed reduction for data retrieved from memory.  
- Maintain proper pipeline control during memory stalls.  

**Outputs:**
- Data read from memory or results from ALU operations to the writeback stage.

### Writeback (WB)
The final stage writes results back to the register file.  

**Primary responsibilities:**
- Write ALU or memory results to the destination register.  
- Signal completion of instruction execution.  

**Outputs:**
- Updated register file state.  

## Pipeline Control

### Hazard Detection and Resolution
The hazard unit ensures correct execution by detecting pipeline dependencies and controlling flushes and stalls as needed.  

**Mechanisms:**
- **Data forwarding:** Resolves read-after-write (RAW) dependencies by routing results from the MEM or WB stages back to earlier ones.  
- **Load-use stalls:** If a load result is not yet available when needed by the next instruction, a bubble is inserted to delay execution.  
- **Control hazards:** Detected through branch outcomes and resolved via flush control in coordination with the branch processing unit.  

### Branch Prediction Integration
The pipeline integrates a two-level branch prediction scheme composed of local and global predictors, supported by a branch target buffer (BTB).  

**Key behaviors:**
- The fetch stage uses prediction results to speculatively select the next PC.  
- On a misprediction, the hazard unit triggers a flush of younger pipeline stages.  
- Branch recovery and next-PC selection are handled by the branch processing unit.  

### Pipeline Flushing and Stalling
Pipeline control maintains correct instruction flow through selective flushing and stalling:  
- **Flushes** are asserted by the hazard unit on mispredicted branches or when recovering from invalid pipeline states.  
- **Stalls** are also controlled by the hazard unit when dependent data or cache replacement data is not yet available.  

During a stall, affected pipeline registers and control signals are held constant to preserve instruction integrity, ensuring no in-flight operations are overwritten.

## Performance Considerations
The processor uses a five-stage pipeline following the conventional RISC architecture model.  
This depth provides a good balance between simplicity, clarity, and baseline performance for FPGA implementation.  

Future revisions may explore a six-stage pipeline to improve timing and support more complex operations such as hardware multiplication.  
Branch prediction and caching already provide measurable reductions in control and memory stalls, improving average throughput without significantly increasing design complexity.

## Summary
The processor implements a five-stage in-order pipeline with hazard detection, forwarding, and branch prediction.  
This structure supports efficient instruction throughput while maintaining straightforward control flow and predictable timing.  
Future enhancements may include multi-level caching or pipeline depth adjustments for higher-frequency operation.