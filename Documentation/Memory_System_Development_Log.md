# Introduction (Feb. 11th - Feb. 13th, 2025): 

## Purpose:
The primary goal of developing a memory system is to gain experience with memory hierarchies while also improving the processors efficiency. Implementing a structured memory system provides practical benefits, allowing the processor to access both instructions and data simultaneously while maintaining the flexibility and capacity of a larger unified memory.

## Overview:
This log will cover the development of the memory system intended for use alongside the pipelined processor in this same repository. This memory system will consist of an L1 instruction cache, L1 data cache, and a shared L2 cache. I then intend to have this cache communicate with the 1GB DDR3 memory on the Zybo board using IP blocks. This system will likely also need a memory management unit to ensure data transfer between cache levels works properly.

The initial cache sizes will be as follows:
- L1 Instruction Cache: 16KiB
- L1 Data Cache: 16KiB
- L2 Shared Cache: 256KiB

This will take up approximately 262KB of the available 270KB of block RAM. 

This project will be developed in the following order:
1. L1 Instruction Cache
2. L1 Data Cache
3. L2 Shared Cache
4. Memory Management Unit (if needed)
5. DDR3 Communication via IP Blocks

This approach grows in complexity as it's developed, starting with the simplest L1 cache, and finishing with full memory system integration. This should allow me to get more comfortable with the memory concepts, and the design as a whole as I work. It's also the most natural way to develop the system.

## Caching Concepts:
Caches store a subset of the total data in the system and are designed to improve memory performance by providing faster access to frequently used data. By reducing the number of accesses to slower main memory, caches significantly enhance processor efficiency.

### Cache Organization:
- Cache Blocks: Memory is divided into fixed-size blocks that are stored in the cache.
    - Each block hold B bytes, and these blocks are addressed using b bits, where 2^b = B
- Sets and Associativity: Caches consist of sets, each containining a number of blocks. 
    - The number of sets is given by S, which is indexed by s bits, where 2^s = S.
    - E (associativity) determines how many blocks each set can hold. 
        - If the associativity is 1, it will contain 1 block. If the associativity is 2, it will contain 2 blocks.
    - Different levels of associativity:
        - Direct mapped: E = 1, meaning that a memory block maps to a single location in the cache
        - N-way set associative: E = N, meaning that a memory block can be mapped to N locations within the cache.
        - Fully associative: E = S, meaning a block can be placed anywhere in the cache.

### Cache Lookup and Management:
- Tag and valid bits: Each cache block has tag bits and a valid bit.
    - Valid bit: Determines if the block contains valid data.
    - Tag bits: The upper bits of the address. Used to determine if the data stored in the block actually corresponds to the requested address.
- Replacement policies: Determines which cache block to evict when a new block needs to be loaded. Some examples include:
    - LRU (Least Recently Used): the block that hasn't been accessed for the longest amount of time is evicted.
    - FIFO (First In First Out): The oldest block in the set is evicted.
    - Random: A random block is evicted.
- Write policies: How the cache handles writes to memory.
    - On cache hit:
        - Write-through: Write the block to memory immediately.
        - Write-back: Write the block to the next level in the memory hierarchy only when the block is evicted.
    - On cache miss:
        - Write-allocate: Load the block into the cache, and update the block in the cache.
        - No-write-allocate: Write directly to memory without bringing the block into the cache.
    - Typically combine:
        - Write-through with write-allocate: Ensures memory remains updated but increases memory traffic.
        - write-back with no-write-allocate: Reduces memory writes but requires memory updates when blocks are evicted.
- Prefetching: When there is a cache miss, the cache will fetch multiple contiguous blocks in memory rather than just the requested block.
    - Improves performance by leveraging spatial locality.
    - Prefetching is being considered for the L1 instruction cache in this design.

### Performance Considerations:
- Cache hits and misses: A cache hit is when the cache contains the requested memory block. A cache miss is when the cache does not contain the requested memory block. 
    - Misses require fetching memory from the next level of the memory hierarchy.
- Miss penalty: The additional delay caused by a cache miss
- High associativity vs low associativity: increasing associativity has both benefits and tradeoffs which must be considered when deciding the level of associativity of a cache.
    - The main benefit of a higher associativity is a lower miss rate. Having more blocks in a set means that if multiple memory addresses resolve to the same set, it will be less likely to require an eviction. This can reduce the chance of memory thrashing (same addresses being fetched and evicted frequently).
    - This comes at the cost of greater complexity in terms of tag checking and replacement policies. This also means they will take up a larger area, and consume more power.

## Limitations of FPGA Hardware:
The FPGA system has two ways of storing data. The first is LUTRAM, which can be completely custom configured using HDL, but is limited to 6000 LUTRAM blocks, each one capable of storing 64-bits (Total storage capacity of about 48KB). The second is BRAM, which has a number of limitations. The BRAM blocks each store 36Kb of data, and have busses capable of sending/receiving 72-bits of data per access. BRAM only supports synchronous reads and writes, meaning that data is not available until the cycle after an address is provided. There are 60 36Kb BRAMs, meaning they can store 270KB of data in total. 

As the LUTRAM is faster (no need for a cycle delay), and can be fully customized, it will be used for both L1 caches, allowing for each L1 cache to be 16KiB, retaining 16KiB for any other data storage needs of the system. This will ensure that on L1 cache hits, there will be no stalling. The L2 cache will be made using BRAM, giving it much higher storage capacity, at the cost of a 1-cycle delay. As the L2 cache also won't need to deal with variable width memory accesses, the limitations of the BRAM won't be as much of an issue as it may be with the L1 caches. This design choice aligns with the function intended for each cache level, utilizing the strengths of the resources available, while minimizing their weaknesses.

# L1 Instruction Cache design (February 13th, 2025 \- Present):

## Initial Design Decisions (February 13th, 2025):
This cache is the simplest one to be implemented, as it will not need to deal with any writes. The starting specifications for this cache will be 4-way, with a 64B block size, meaning to store 16KiB, it must have 64 sets. This comes from the equation C = SEB, where S is the number of sets, E is the associativity, and B is the block size.

It is 4-ways, as this gives a good balance between a reduction in hit rate, while still not requiring extremely complex logic in order to handle. The other options were 2-way, and 8-way, both of which have the same benfits but in differing proportions. A 2-way cache would be less complex, but would have more conflit misses, whereas an 8-way cache would be more complex, but have less conflict misses. Starting with 4-way and seeing if the area, or hit rate is larger may prompt a switch to either 2-way or 8-way associativity. Direct caches were not considered because they are far less flexible, in that if the multiple addresses resolve to the same set frequently, then there will be a high number of conflict misses. Beyond that, they don't allow for the implementation of a replacement policy. Lack of need for a replacement policy is actually one of the strengths of a direct mapped cache, as it reduces complexity, however I want to gain experience in implementing these policies, which in this case makes it a weakness.

The block size of 64B was chosen, as it's a middle ground of block size. ASmaller block sizes would reduce the benefits of spatial locality, as fewer consecutive instructions are loaded together, leading to more frequent cache misses.Larger block sizes increase memory transfer overhead and may reduce efficiency for programs with frequent branching or poor spatial locality. Again, it will be tweaked to find the best hit rate possible.

Note that although I tried to justify my decisions in block size and associativty, more knowledge of what the processor will be doing is really needed to decide what would be best. If there's very frequent branching, and low spatial locality in the code, then higher associativity, and lower block size would be more beneficial, as there would be a lower chance for cache conflicts. If there's a very little branching, then a lower associativity with a higher block size would be more beneficial, as this would reduce power consumption and bus transactions, taking advantage of the linear operation of the code. Going with the middle ground for both associativity and block size gives the processor flexibility in the types of programs it will be able to effectively run.

When the cache is implemented in Verilog, it will be parameterized for these values so that they can easily be changed depending on the effeciency of the chosen block size and associativity. If a specific function is determined for the processor, then this will also allow for easy changes to accomodate the change in work flow.

The replacement policy for this cache will be LRU. This is a relatively complex replacement policy, but it is better suited for programs with frequent branching, as it optimizes memory accesses by retaining frequently used blocks. FIFO does not account for actual access patterns, meaning frequently used instructions may be evicted simply based on load order, whereas LRU retains the most recently used blocks, improving performance for looping and branching code. This is because the first block loaded in may be accessed more than the second block loaded in. In FIFO this block will be evicted, even if it is more likely to be needed again in the near future.

To summarize, the cache is to have the following initial parameters:
- S = 64
- E = 4
- B = 64
- Replacement Policy = LRU

Prefetching may be implemented utilizing the existing branch prediction system in the processor once the full memory system is setup, but not in the initial implementation.

## Logic Design / Verilog Coding (February 14th, 2025 \- Present):
The module will need to be able to do the following:
- Index into a set, and further index a block within that set, and further index the appropriate word within that block.
    - As each block contains 64 bytes, it will contain 16 words.
    - Only needs to be word addressable, as instructions will always be word aligned.
        - Means only need to address words, not bytes.
- Determine when a set has no valid block for the current memory access.
    - This will be when the valid bit is 0, OR if no block within the set has a matching tag.
    - As LRU will need a way to determine which block within a set is LRU.
        - Could achieve this using logbase2(E) LRU bits that update on each cache access, and show what when a given block within a set was last accessed.
- If there is a miss, it will need to request the new data from the higher level in the memory hierarchy.
    - Ideally do this in parallel with checking tag bits to reduce delay if there is a miss.
    - Initially will be blocking.
- If there is a miss, send a signal to the processor indicating that a pipeline stall is neccesary.
- Be able to combinationally output the requested data.
    - Doing this in a combinational manner will mean a 0-cycle delay for instruction accesses (Needed for effecient pipeline operation).
- Will update cache blocks on clock cycle following miss, while passing desired data to the processor
    - Acts as write-through, so won't need to wait an extra clock cycle after a block is replaced.

I began implementation of my cache system in Verilog, which allowed me to gain a better understanding of the challenges that will come along with developing a cache of the nature described. As such, I will try to explain the issues that came while implementing the cache.

The main issue I initially faced was the complexity of the cache itself. I initially tried to implement the cache in one module by itself, but the complexity of the cache control logic and the sets was too much to handle in one module. So I decided to start by creating a module for the cache sets. This module handles tag and valid bit comparison, reads, and evictions/writes. I plan on also creating a module for controlling the incoming and outgoing data from the cache, communicating with both the L2 cache, and the processor. These will then be combined in a top-level L1 instruction cache module. Going about the design in this way will increase modularity, and simplify the design process of each module.

### Cache Set Module (February 16th - February 20th, 2025):
This is the natural starting point for the cache, as everything is built based on how the sets are organized. This module has the following parameters:
- B: Block size (in bytes)
- NumTagBits: Number of bits in tag
- E: Associativity of cache

This module has the following inputs:
- clk: The clock
- reset: The reset signal
- ActiveSet: Indicates if the set is currently being accessed (active high)
- RepReady: Indicates if the replacement block has been fetched (active high)
- Block: The Block index bits of the currently desired data (Note still just returns a word, not just indexed byte)
- Tag: The tag of the currently desired data
- ReplacementBlock: The block intended to replace old data

This module has the following outputs:
- Data: The currently desired block within the set
- CacheMiss: Indicates that there was a cache miss (active high)

This module has the following internal signals:
- BlockTags: Stores the tags of the currently stored blocks within the set
- ValidBits: Indicates if a given block is valid (active high)
- MatchedBlock: Indicates if a given block matches the current tag, and is valid
- LRUBits: Indicates the position of how recently a block was used
    - Value of E indicates it is the LRU block, value of 0 indicates it was just used
- LastLRUStatus: The LRUBits associated with a block that was just accessed
- NextFill: Indicates how many blocks have been filled with valid data
- SetData: All data currently stored within the set
- i: A signal used for looping constructs

This module has multiple always statements, each one handelling different portions of the set logic.

**Reset Logic:** This always block handles the reset of the signal. On either a positive clock or reset edge, all data within the set is reset to a default value. These include:
- ValidBits
- NextFill
- MatchedBlock
- LastLRUStatus
- LRUBits
- BlockTags
- SetData

**Tag and valid comparison logic:** This combinational block checks whether an instruction is in the cache by comparing the tag and valid bits. If a match is found, the corresponding MatchedBlock bit is set, LastLRUStatus is updated with the blocks old LRU value, and its LRUBits is reset to 0 (indicating it was just accessed). If no match is found, a cache miss is flagged.

**LRUBits update logic:** This logic runs on the positive clock edge and updates the LRU values when the set is active and a cache hit occurs.

**Replacement logic:** Evaluated on the positive clock edge, this block replaces cache blocks on a miss. If a cache miss occurs, the set is active, and the replacement data is ready, it:
- Replaces the Least Recently Used (LRU) block if the set is full.
- Fills the next available block if any invalid entries exist, then updates the valid bit.

This logic needed to be changed in order to accomodate LUTRAM restrictions, but the functionality remains the same.

**Output logic:** This combinational block determines the cache output. It will set the output to the appropriate word within the block that got a cache hit.

**Testing:** 
I created a testbench in SystemVerilog in order to test the modules functionality. Tasks were used to perform repetitive assertions. I ensured that:
- The set resets correctly.
- On a miss, the CacheMiss signal is asserted, and Data outputs all X values.
- The set correctly fills each block when empty.
- The correct word within a block is accessed based on block indexing.
- LRUBits update properly after accesses.
- Only the Least Recently Used (LRU) block is replaced when the set is full.
- A multi-cycle delay in receiving valid replacement data does not cause issues.

### Cache Controller Module (March 2nd, 2025):
With the instruction cache set modules behaviour defined and verified, the cache controller can now be made. As the instruction cache should be accessed on every cycle, it doesn't need to determine if a memory access is occuring. Even if there is a load stall from the processor, it will still be accessing the same PC address the following cycle. That said it will need to be able to do the following:

- Determine the set associated with the current address.
- Output the appropriate read data from the set of interest.
- Output if the currently accessed set has had a cache miss.

It can be seen that this will essentially act as a decoder. As such the Verilog coding was two simple assignment statements. This module has the following input signals:
- Set: The current set being accessed.
- MissArray: An array containing the output of all sets CacheMiss output signals

This module has the following output signals:
- ActiveArray: Sets the bit associated with the set being accessed high.
- CacheMiss: The bit from MissArray associated with the set currently being accessed.

**Testing:** This was tested using a simple testbench, checking every possible input set, set the correct bit in the ActiveArray, and that the correct CacheMiss value is passed to the DUT output.

### L1 Instruction Cache Module (March 2nd, 2025 \- Present):
This top level cache module is a staging ground for the two previously designed modules. It generates S cache sets, divides the address into its different components, creates signals for communication between the different modules, and assigns the proper address.

# Changelog:

## #1 Changed initial sizes of L1 and L2 caches (February 12th, 2025):
The initial plan of using BRAM for the L1 caches didn't end up being ideal, as the BRAM is synchronous only using it would require reworking of the pipeline, or the introduction of stalls. Using LUTRAM instead allows for combinational reads, and more control over how memory is accessed by the processor itself. Because of this, the L1 caches must be 16KiB, rather than 32KiB, as there's not enough LUTRAM to accomadate 64 total KiB of storage. Although this isn't ideal, this does mean that L2 will have more BRAM to work with, meaning it can be made 256KiB, rather than 192KiB, which may offset the smaller L1 cache sizes.

# Challenges:

## #1 Determining instruction cache parameters and policies:
Since my processor doesn't yet have a defined use case, selecting the instruction cache parameters and policies was challenging. While this wasn't a critical issue, since the design is fully parameterizable for different block sizes, set sizes, and associativity—I still wanted to choose an initial configuration that would provide a solid foundation for learning cache architecture and parameterized design.

I opted for a 4-way set-associative cache as a starting point, since it can be easily generalized to N-way associativity by adjusting parameters. Additionally, implementing a replacement policy was necessary, and I chose Least Recently Used (LRU) because it is typically more efficient in most cases and provided an interesting challenge for implementation.

## #2 Maintaining reasonable level of complexity in Verilog modules:
I initially tried to encapsulate the entire instruction cache system within one module. This was a big mistake, as the complexity of the cache system does not lend itself to being encapsulated within one module very well. Doing this would have lead to messy Verilog, that would've been harder to understand and debug. As such, I decided to split the cache system into two main modules, that would be instantiated by a top-level module. One would be the cache set, handeling tag and valid bit comparison, reads, and evictions/writes, the other would be the cache controller, handeling communication with other parts of the system, and controlling the cache set behaviour.

## #3 Making the cache set Verilog code parameterizable:
Parameterizing the cache set module added complexity to the coding process, primarily due to the need for dynamic indexing and control structures. Instead of using case statements, which are typically more intuitive, I had to rely on for loops and if statements that adapt based on parameter values.

Additionally, parameterization introduced some challenges in signal indexing, though this was less of an issue compared to the necessary shift in coding style. 

## #4 Making the LRU replacement policy within Verilog:
Designing the LRU replacement policy was challenging due to the need to ensure that only the necessary entries were updated while correctly maintaining the hierarchy of block usage.

To track the LRU order, I implemented an array of log2(E)-bit LRUBits for each block. A value of all 1's indicates the Least Recently Used (LRU) block, which is replaced on a cache miss.

While this structure provided a solid foundation, updating LRUBits correctly when a block was accessed was tricky. The key challenge was determining how to adjust the hierarchy without disrupting the ordering when a block in the middle was read.

To solve this, I introduced an intermediate signal that stored the blocks previous LRUBits value. This signal allowed me to:
1. Identify which blocks were previously more recently used than the accessed block.
2. Increment only those blocks, moving them closer to the LRU position while keeping their relative order intact.

This logic was implemented in a separate clocked process to ensure proper synchronization and prevent unintended latches. This approach ultimately provided a clean, efficient method for dynamically maintaining the LRU order in hardware.

## #5 Effecient LUTRAM/BRAM Synthesis Inference for L1 Cache Set:
Although my L1 cache set worked logically, it did not initially synthesize to LUTRAM properly, instead taking up an enormous amount of LUT's for logic, as well as a huge amount of registers. As such the design needed to be changed to be consistent with LUTRAM inference. This required changing the replacement policy process in order to only write to SetData on one line, using an intermediate signal for indexing. This also required changing the read behaviour, storing the block to be read from in another intermediate signal, which was then used to index SetData.

The challenge in this wasn't the changes themselves, but rather finding what the issue stopping LUTRAM inference was, as the synthesis tool provided no direction as to what the issue could be. This lead to me consulting the documentation for coding examples, as well as making a seperate module and making changes to it, and seeing what could possibly stop LUTRAM from being inferred. This was a process that took quite a lot of trial and error, but eventually allowed me to find a way to ensure LUTRAM was inferred. 

However even when LUTRAM was inferred, the synthesis tool did not place it effeciently at all, using approximately 10x as many LUTs as I calcualted would be neccesary for a given set. As of writing this entry this is still an issue, and I will be looking for ways around this. The main issue in this is that the FPGA expect high depth, low width RAM, but my set expects high width low depth RAM. As such I will likely need to look into different indexing methods to fix this issue. Considering 2D arrays, and a number of other coding strategies stop the inference of LUTRAM, this will be a difficult problem to solve. If there is a large amount of time sunk into fixing this problem with no solution in sight, I may even shift the focus of my technical project elsewhere.

As of now I will be looking into changing the width of the words to 32-bits, and using a flattened 1D array in order to decrease the width, and increase the depth of the storage signal. Alongside this, I will look into a multi-cycle replacement strategy, as this would allow for the RAM to be written to in smaller chunks.
