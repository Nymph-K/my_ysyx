#include <memory/cache.h>
#include <stdlib.h>

CacheLine cache[CACHE_SET_SIZE][CACHE_ASSOCIATIVITY] = {0};

static uint64_t cycle_cnt = 0;
static uint64_t r_cnt = 0;
static uint64_t r_hit_cnt = 0;
static uint64_t r_miss_cnt = 0;
static uint64_t w_cnt = 0;
static uint64_t w_hit_cnt = 0;
static uint64_t w_miss_cnt = 0;
static bool stop_cnt = false;

word_t pmem_read(paddr_t addr, int len);
void pmem_write(paddr_t addr, int len, word_t data);
static void cycle_increase(int n) { cycle_cnt += n; }

static inline word_t cache_inline_read(size_t index, size_t way, size_t offset, int len) {
    switch (len) {
        case 1: return *(uint8_t  *)(cache[index][way].cache_data+offset);
        case 2: return *(uint16_t *)(cache[index][way].cache_data+offset);
        case 4: return *(uint32_t *)(cache[index][way].cache_data+offset);
        IFDEF(CONFIG_ISA64, case 8: return *(uint64_t *)(cache[index][way].cache_data+offset));
        default: MUXDEF(CONFIG_RT_CHECK, assert(0), return 0);
    }
}

static inline void cache_inline_write(size_t index, size_t way, size_t offset, int len, word_t data) {
  switch (len) {
    case 1: *(uint8_t  *)(cache[index][way].cache_data+offset) = data; return;
    case 2: *(uint16_t *)(cache[index][way].cache_data+offset) = data; return;
    case 4: *(uint32_t *)(cache[index][way].cache_data+offset) = data; return;
    IFDEF(CONFIG_ISA64, case 8: *(uint64_t *)(cache[index][way].cache_data+offset) = data; return);
    IFDEF(CONFIG_RT_CHECK, default: assert(0));
  }
}

static void cache_read_from_mem(paddr_t paddr, size_t index)
{
    int way_empty = -1;
    int way_choose = -1;
    for (size_t way = 0; way < CACHE_ASSOCIATIVITY; way++)
    {
        if (!cache[index][way].valid)
        {
            way_empty = way;
            break;
        }
    }
    if (way_empty == -1) // full
    {
        way_choose = rand() % CACHE_ASSOCIATIVITY; // random replace
    }
    else
    {
        way_choose = way_empty;
    }
    word_t *p_data = (word_t *)(cache[index][way_choose].cache_data);
    paddr_t addr_read = paddr & (CACHE_TAG_MASK | CACHE_SET_MASK);
    for (size_t i = 0; i < CACHE_BLOCK_SIZE/sizeof(word_t); i++)
    {
        p_data[i] = pmem_read(addr_read, sizeof(word_t));
        addr_read += sizeof(word_t);
    }
    cache[index][way_choose].tag = ADDR_TAG(paddr);
    cache[index][way_choose].valid = true;
}

void init_cache(void)
{
    for (size_t i = 0; i < CACHE_SET_SIZE; i++)
    {
        for (size_t j = 0; j < CACHE_ASSOCIATIVITY; j++)
        {
            cache[i][j].valid = false;
        }
    }
}

word_t cache_read(paddr_t paddr, size_t len, CacheLine *cache_p)
{
    if (!stop_cnt) r_cnt++;
    cycle_increase(10);
    paddr_t tag_addr = ADDR_TAG(paddr);
    size_t index = ADDR_SET(paddr);
    size_t offset = ADDR_OFFSET(paddr);
    for (size_t way = 0; way < CACHE_ASSOCIATIVITY; way++)
    {
        if (cache[index][way].valid && (cache[index][way].tag == tag_addr)) // hit  line
        {
            if (offset + len > CACHE_BLOCK_SIZE) // over 1 line
            {
                uint8_t read_data[sizeof(word_t)] = {0};
                size_t i;
                for (i = 0; i < (CACHE_BLOCK_SIZE - offset); i++) // hit n Byte
                {
                    read_data[i] = cache[index][way].cache_data[offset+i];
                }

                size_t index2 = ADDR_SET(paddr + len);
                for (size_t way2 = 0; way2 < CACHE_ASSOCIATIVITY; way2++)
                {
                    if (cache[index2][way2].valid && (cache[index2][way2].tag == tag_addr)) // line 2 hit
                    {
                        cycle_increase(10);
                        if (!stop_cnt) r_hit_cnt++;
                        for (size_t j = 0; j < (offset + len - CACHE_BLOCK_SIZE); j++, i++)
                        {
                            read_data[i] = cache[index2][way2].cache_data[j];
                        }
                        switch (len) {
                            case 1: return *(uint8_t *)read_data;
                            case 2: return *(uint16_t *)read_data;
                            case 4: return *(uint32_t *)read_data;
                            IFDEF(CONFIG_ISA64, case 8: return *(uint64_t *)read_data);
                            IFDEF(CONFIG_RT_CHECK, default: assert(0));
                        }
                    }
                }
                // miss 2 line
                if (!stop_cnt) r_miss_cnt++;
                cycle_increase(100);
                return pmem_read(paddr, len);
            }
            else
            {
                if (!stop_cnt) r_hit_cnt++;
                return cache_inline_read(index, way, offset, len);
            }
        }
    }

    /**************** miss ***************/
    cycle_increase(100);
    if (!stop_cnt) r_miss_cnt++;
    cache_read_from_mem(paddr, index);
    if (offset + len > CACHE_BLOCK_SIZE) // over 1 line
    {
        cycle_increase(100);
        size_t index2 = ADDR_SET(paddr + len);
        cache_read_from_mem(paddr + len, index2);
    }
    
    return pmem_read(paddr, len);
}

void cache_write(paddr_t paddr, size_t len, word_t data, CacheLine *cache_p)
{
    if (!stop_cnt) w_cnt++;
    cycle_increase(10);
    paddr_t tag_addr = ADDR_TAG(paddr);
    size_t index = ADDR_SET(paddr);
    size_t offset = ADDR_OFFSET(paddr);
    for (size_t way = 0; way < CACHE_ASSOCIATIVITY; way++)
    {
        if (cache[index][way].valid && (cache[index][way].tag == tag_addr)) // hit  line
        {
            if (offset + len > CACHE_BLOCK_SIZE) // over 1 line
            {
                uint8_t *write_data = (uint8_t *)(&data);
                size_t i;
                for (i = 0; i < (CACHE_BLOCK_SIZE - offset); i++) // hit n Byte
                {
                    cache[index][way].cache_data[offset+i] = write_data[i];
                }

                size_t index2 = ADDR_SET(paddr + len);
                for (size_t way2 = 0; way2 < CACHE_ASSOCIATIVITY; way2++)
                {
                    if (cache[index2][way2].valid && (cache[index2][way2].tag == tag_addr)) // line 2 hit
                    {
                        cycle_increase(10);
                        if (!stop_cnt) w_hit_cnt++;
                        for (size_t j = 0; j < (offset + len - CACHE_BLOCK_SIZE); j++, i++)
                        {
                            cache[index2][way2].cache_data[j] = write_data[i];
                        }
                        return pmem_write(paddr, len, data);
                    }
                }
                // miss 2 line
                if (!stop_cnt) w_miss_cnt++;
                cycle_increase(100);
                return pmem_write(paddr, len, data);
            }
            else
            {
                if (!stop_cnt) w_hit_cnt++;
                cache_inline_write(index, way, offset, len, data);
                return pmem_write(paddr, len, data);
            }
        }
    }

    /**************** miss ***************/
    if (!stop_cnt) w_miss_cnt++;
    cycle_increase(100);
    return pmem_write(paddr, len, data);
}

void display_statistic(void) {
  printf("        Total count  \t Hit count (rate) \t Miss count (rate)\n");
  printf("Read:   %8ld\t %8ld(%2.2f %%)\t %8ld(%2.2f %%)\n", r_cnt, r_hit_cnt, (float)r_hit_cnt/r_cnt*100, r_miss_cnt, (float)r_miss_cnt/r_cnt*100);
  printf("Write:  %8ld\t %8ld(%2.2f %%)\t %8ld(%2.2f %%)\n", w_cnt, w_hit_cnt, (float)w_hit_cnt/w_cnt*100, w_miss_cnt, (float)w_miss_cnt/w_cnt*100);
  printf("Total:  %8ld\t %8ld(%2.2f %%)\t %8ld(%2.2f %%)\n", r_cnt + w_cnt, r_hit_cnt + w_hit_cnt, (float)(r_hit_cnt + w_hit_cnt)/(r_cnt + w_cnt)*100, r_miss_cnt + w_miss_cnt, (float)(r_miss_cnt + w_miss_cnt)/(r_cnt + w_cnt)*100);
}

void stopCount(void) {
  stop_cnt = true;
}