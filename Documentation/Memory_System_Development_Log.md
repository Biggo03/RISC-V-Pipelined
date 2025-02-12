# Introduction (Feb. 11th, 2025): 

## Purpose:
The primary goal of developing a memory system is to gain experience with memory hierarchies while also improving the processors efficiency. Implementing a structured memory system provides practical benefits, allowing the processor to access both instructions and data simultaneously while maintaining the flexibility and capacity of a larger unified memory.

## Overview:
This log will cover the development of the memory system intended for use alongside the pipelined processor in this same repository. This memory system will consist of an L1 instruction cache, L1 data cache, and a shared L2 cache. I then intend to have this cache communicate with the 1GB DDR3 memory on the Zybo board using IP blocks. This system will likely also need a memory management unit to ensure data transfer between cache levels works properly.

The initial cache sizes will be as follows:
- L1 Instruction Cache: 32KB
- L1 Data Cache: 32KB
- L2 Shared Cache: 192KB

This will take up 256KB of the available 270KB of block RAM. 

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