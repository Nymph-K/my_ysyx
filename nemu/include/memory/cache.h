#ifndef __MEMORY_CACHE_H
#define __MEMORY_CACHE_H

#include <common.h>

#define CACHE_SIZE              65536   // 64 KB
#define CACHE_BLOCK_SIZE        64      // 64 Byte
#define CACHE_ASSOCIATIVITY     8       // 8-way set associative
#define CACHE_SET_SIZE          128     //(CACHE_SIZE/CACHE_BLOCK_SIZE/CACHE_ASSOCIATIVITY)  line
#define CACHE_REPLACE           random
#define CACHE_NOT_ALLOCATION    1
#define CACHE_WRITE_THROUGH     1

#if CACHE_NOT_ALLOCATION
#define CACHE_ALLOCATION        0
#else
#define CACHE_ALLOCATION        1
#endif

#if CACHE_WRITE_THROUGH
#define CACHE_WRITE_BACK        0
#else
#define CACHE_WRITE_BACK        1
#endif

#define CACHE_TAG_WIDTH         17
#define CACHE_SET_WIDTH         7
#define CACHE_OFFSET_WIDTH      6

#define CACHE_TAG_MASK          0xFFFFFFFFFFFFE000
#define CACHE_SET_MASK          0x0000000000001FC0
#define CACHE_OFFSET_MASK       0x000000000000003F

#define ADDR_OFFSET(addr)       ((addr) & CACHE_OFFSET_MASK)
#define ADDR_SET(addr)          (((addr) & CACHE_SET_MASK) >> CACHE_OFFSET_WIDTH)
#define ADDR_TAG(addr)          ((addr) & CACHE_TAG_MASK)

typedef struct
{
    bool valid;
    paddr_t tag;
    uint8_t cache_data[CACHE_BLOCK_SIZE];
} CacheLine;

void init_cache(void);
word_t cache_read(paddr_t paddr, size_t len, CacheLine *cache);
void cache_write(paddr_t paddr, size_t len, word_t data, CacheLine *cache);
void display_statistic(void);
void stopCount(void);


#endif //__MEMORY_CACHE_H