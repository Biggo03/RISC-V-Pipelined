# Overview
The I-cache is a cache module that is essentially used as the instruction memory of the overall system. The modules are paramaterized s.t it's **associativity, number of sets, and block size** are all configurable. That said, it must have at **minimum** two blocks per set. This is because the sets are designed with a an N > 2 way associativity in mind, having a replacement policy to deal with cache conflicts. It uses a LRU (Least Recently Used) replacement policy, meaning that when a block is evicted from a set, it will bbe the one that was accessed the longest time ago.

Replacement is done 2-words (64-bits) per cycle, meaning that block size is directly proportional to the replacement delay. This was done primarily due to the area constraints associated with a higher number of bits replaced per cycle. The set also assumes at least a one-cycle delay between a cache miss, and when the replacement data begins to become available.

The set was designed to be integrated with the pipelined processor, and therefore uses control and hazard signals from the processor within it's own control logic.

The submodules that make up the design will now be covered. The two primary modules are: **InstrCacheSetMulti**, and **InstrCacheController**.

Before going into the modules, please note that:
- S = Number of sets (S = 16 means there are 16 sets)
  - s = log2(S) (the number of bits needed to address the sets)
- E = Associativity (E = 4 means a 4-way associative set)
  - e = log2(E) (The number of bits needed to address a block within a set)
- B = Block size in bytes (B = 64 means each block is 64 bytes)
  - b = log2(B) (The number of bits needed to address data within a block)

# InstrCacheSetMulti
This module contains all logic directly associated with the sets themselves. This includes:
- Storage elements
- Tag comparison
- Replacement logic
- Output logic

The inputs are as follows:
- **clk**: The clock
- **reset**: reset signal
- **ActiveSet**: Indicates that the current set is actively being accessed
- **RepEnable**: Indicates that replacement is enabled
- **Block**: The block bits of the address (last log2(B) bits of the address, where B is the block size in bytes)
- **Tag**: The top tag bits of the address
- **RepWord**: The input word that will replace a value currently stored in the set

The outputs are as follows:
- **Data**: The output data of the set
- **Cache** miss: Signal indicating that there was a cache miss

The module has the following internal signals:
- Address related:
  - **BlockTags**: Tags associated with the current blocsk stored in the cache
  - **ValidBits**: An array of bits with the width equal to E. Indicates if a given block contains valid data
    - Ex: if ValidBits = 0011, then blocks 0 and 1 are valid, and blocks 2 and 3 are not
  - **MatchedBlock**: An array of bits with the width equal to E. Indicates if a given blocks tags match that of the input
- Replacement Policy related:
  - **LRUBits**: An array of E signals with e width. Keeps track of the order in which blocks were accessed
  - **LastLRUStatus**: Contains the position in LRU in which the most recently evicted OR accessed block was.
  - **NextFill**: An array of bits with the width equal to E. Signal indicating the next empty block to be filled when cache is initially being populated
  - **RemovedBlock**: An array of bits with the width equal to E. Indicates the block number that was just evicted from a cache
  - **RepCounter**: A running counter of the number of cycles that have occured in a given replacement
  - **RepActive**: Indicates that a replacement is occuring
  - **RepComplete**: Indicates that a replacement has completed
  - **RepBegin**: Indicates that a replacement has begun
- Storage related:
  - **SetData**: An array storing all the sets data. It's indexing structure will be described in the design section
- Output related:
  - **Outset**: An array of bits with a width equal to E. Indicates the Block containing the requested data **Should change this to OutBlock**
  - **BlockOffset**: A signal containing the block offset of the requested block **Must return to explain this more**

## Design

## Key Tradeoffs

## Testing

# InstrCacheController
This module contains all the control logic for determining:
- The current active set
- If the data requested has a cache hit or miss
- If a replacement should occur

The inputs are as follows:
- **clk**: The clock signal
- **reset**: The reset signal
- **Set**: The set that is to be accessed
- **MissArray**: An array containing all the CacheMiss signals from the instantiated cache sets
- **PCSrcReg**: A registerd processor control signal that contains branching/branch prediction information
- **BranchOpE**: A processor control signal indicating if a branch or jump is currently in the execution stage.

The outputs are as follows:
- **ActiveArray**: An array of bits of width S, indicating which set is currently active.
- **CacheMiss**: A signal indicating if the currently accessed set had a miss
- **CacheRepActive**: A signal determining if block replacement is allowed **Should likely rename to show it is if replacement is allowed**
 
## Design

## Key Tradeoffs

## Testing

# Synthesis Results