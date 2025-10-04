# Memory System

## Overview
This document describes the memory subsystem of the processor.  
At present, it consists of a single instruction cache that supplies instructions to the fetch stage.  
Additional components such as a data cache and external memory interface will be defined in future development.

## Instruction Cache

### Overview
The instruction cache (I-cache) serves as the interface between the fetch stage and the next memory level.  
It stores recently fetched instruction blocks to reduce access latency and improve pipeline throughput.  
The cache operates independently of the data path and responds to requests from the program counter (PC) each cycle.

### Organization
- **Cache Type:** Configurable set-associative structure.  
- **Block Size:** 64 bytes (default).  
- **Replacement Policy:** Multi-cycle LRU replacement.  
- **Replacement Granularity:** 64 bits per cycle during refill.  

### Operation Summary
- The fetch stage provides the current PC (`pc_f_i`) each cycle.  
- On a **cache hit**, the corresponding instruction is returned immediately through `instr_f_o`.  
- On a **miss**, the cache asserts `ic_repl_permit_o` to request a replacement.  
  When replacement data is available from the next level (`l2_repl_ready_i`), lines are refilled using `rep_word_i`.  
- The cache maintains synchronization with branch decisions and PC source changes through `pc_src_reg_i` and `branch_op_e_i`.
  - These signals are used in determining when `ic_repl_permit_o` goes high

### Control Signals

| Signal | Direction | Description |
|---------|------------|-------------|
| `instr_hit_f_o`    | Output | Indicates whether the instruction corresponding to `pc_f_i` is present in the cache. |
| `ic_repl_permit_o` | Output | High when the cache is ready to begin a replacement operation. |
| `l2_repl_ready_i`  | Input  | Asserted by the next memory level when replacement data is available. |
| `branch_op_e_i`    | Input  | Used to coordinate cache behavior with current branch decisions. |
| `pc_src_reg_i`     | Input  | Determines which PC source (sequential, branch target, etc.) should drive instruction fetch. |

## Data Cache (Planned)
*To be defined in a future revision once data caching requirements are finalized.*

## Cache-to-Memory Interface (Planned)
*To be defined once cache hierarchy and external memory structure are implemented.*

## External Memory (Planned)
*Placeholder for future integration of DDR3 or other off-chip memory subsystems.*

## Summary
The current memory system consists of a fully functional instruction cache responsible for instruction delivery and replacement management.  
Additional components—including the data cache and memory controller—will be added as the processor’s memory hierarchy expands.