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
The FPGA system has two ways of storing data. THe first is LUTRAM, which can be completely custom configured using HDL, but is limited to 6000 LUTRAM blocks, each one capable of storing 64-bits (Total storage capacity of about 48KB). The second is BRAM, which has a number of limitations. The BRAM blocks each store 36Kb of data, and have busses capable of sending/recieving 72-bits of data per access. Beyond that, they only support synchronous reads and writes, meaning that there will always be at least a single clock cycle delay between when an address is recieved, and when the appropriate data is read. There are 60 36Kb BRAMs, meaning they can store 270KB of data in total. 

As the LUTRAM is faster (no need for a cycle delay), and can be fully customized, it will be used for the L1 caches, allowing for each L1 cache to be 16KiB, retaining 16KiB for any other data storage needs of the system. This will ensure that on L1 cache hits, there will be no stalling. The L2 cache will be made using BRAM, giving it much higher storage capacity, at the cost of a 1-cycle delay. As the L2 cache also won't need to deal with variable width memory accesses the limitations of the BRAM won't be as much of an issue as it may be with the L1 caches. This design choice aligns with the function intended for each cache level, utilizing the strengths of the resources available, while minimizing their weaknesses.

# L1 Instruction Cache design (February 13th, 2025 \- Present):

## Initial Design Decisions (February 13th, 2025):
This cache is the simplest one to be implemented, as it will not need to deal with any writes. The starting specifications for this cach will be 4-way, with a 64B block size, meaning to store 16KiB, it must have 64 sets. This comes from the equation C = SEB, where S is the number of sets, E is the associativity, and B is the block size.

It is 4-ways, as this gives a good balance between a reduction in hit rate, while still not requiring extremely complex logic in order to handle. The other options were 2-way, and 8-way, both of which have the same benfits but in differing proportions. Starting with 4-way and seeing if the area, or hit rate is larger may prompt a switch to either 2-way or 8-way associativity. Direct caches were not considered beacuse they are far less flexible, in that if the multiple addresses resolve to the same set frequently, thrashing will occur. Beyond that, they don't allow for the implementation of a replacement policy, which I am interested in implementing in my caches.

The block size of 64B was chosen, as it's a middle ground of block size. Any less, and code with good spatial locality may not be very well accomodated, and any more (128B) would likely take up a lot of bandwidth, while providing more data to the cache than may be needed. Again, it will be tweaked to find the best hit rate possible.

Note that although I tried to justify my decisions in block size and associativty, more knowledge of what the processor will be doing is really needed to decide what would be best. If there's very frequent branching, and low spatial locality in the code, then higher associativity, and lower block size would be more beneficial, as there would be a lower chance for cache conflicts. If there's a very little branching, then a lower associativity with a higher block size would be more beneficial, as this would reduce power consumption and bus transactions, taking advantage of the linear operation of the code. Going with the middle ground for both associativity and block size gives the processor flexibility in the types of programs it will be able to effectively run.

When the cache is implemented in Verilog, it will be parameterized for these values so that they can easily be changed depending on the effeciency of the chosen block size and associativity. If a specific function is determined for the processor, then this will also allow for easy changes to accomodate the change in work flow.

THe replacement policy for this cache will be LRU. This is one of the more complex replacement policies, but it will allow for programs that branch frequently to have more optimized memory accesses. If a block of code branches in and out of the range of a set frequently, and FIFO is used, then a set of instructions is more likely to be prematurely evicted. This is because the first block loaded in may be accessed more than the second block loaded in. In FIFO this block will be evicted, even if it is more likely to be needed again in the near future.

To sumarize, the cache is to have the following initial parameters:
- S = 64
- E = 4
- B = 64
- Replacement Policy = LRU

Will wait until have branch prediction data available before implementing prefetching.




# Changelog:

## #1 Changed initial sizes of L1 and L2 caches (February 12th, 2025):
The initial plan of using BRAM for the L1 caches didn't end up being ideal, as the BRAM is synchronous only using it would require reworking of the pipeline, or the introduction of stalls. Using LUTRAM instead allows for combinational reads, and more control over how memory is accessed by the processor itself. Because of this, the L1 caches must be 16KiB, rather than 32KiB, as there's not enough LUTRAM to accomadate 64 total KiB of storage. Although this isn't ideal, this does mean that L2 will have more BRAM to work with, meaning it can be made 256KiB, rather than 192KiB, which may offset the smaller L1 cache sizes.
