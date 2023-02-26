#include <cpu/ringbuf.h>
#include <string.h>

bool enable_trace = false;

#if CONFIG_IRINGBUF_DEPTH||CONFIG_MRINGBUF_DEPTH||CONFIG_FRINGBUF_DEPTH||CONFIG_DRINGBUF_DEPTH||CONFIG_ERINGBUF_DEPTH

#define H_NEXT_NBUF(cur, n) (cur->head+n)%(cur->depth)
#define H_NEXT_BUF(cur) H_NEXT_NBUF(cur, 1)
#define T_NEXT_NBUF(cur, n) (cur->tail+n)%(cur->depth)
#define T_NEXT_BUF(cur) T_NEXT_NBUF(cur, 1)

#if CONFIG_IRINGBUF_DEPTH
ringBuf iringbuf;
static uint8_t ilogbuffer[CONFIG_IRINGBUF_DEPTH*LOG_LEN] = {0};
#endif
#if CONFIG_MRINGBUF_DEPTH
ringBuf mringbuf;
static uint8_t mlogbuffer[CONFIG_MRINGBUF_DEPTH*LOG_LEN] = {0};
#endif
#if CONFIG_FRINGBUF_DEPTH
ringBuf fringbuf;
static callBuf fcallbuffer[CONFIG_FRINGBUF_DEPTH] = {0};
#endif
#if CONFIG_DRINGBUF_DEPTH
ringBuf dringbuf;
static char dlogbuffer[CONFIG_DRINGBUF_DEPTH*LOG_LEN] = {0};
#endif
#if CONFIG_ERINGBUF_DEPTH
ringBuf eringbuf;
static char elogbuffer[CONFIG_ERINGBUF_DEPTH*LOG_LEN] = {0};
#endif

/*环形缓冲区初始化函数*/
/*使用全局变量*/
void ringBufInit(void)
{
    #if CONFIG_IRINGBUF_DEPTH
    iringbuf.head = 0;
    iringbuf.tail = 0;
    iringbuf.full = false;
    iringbuf.depth = CONFIG_IRINGBUF_DEPTH;
    iringbuf.width = LOG_LEN;
    iringbuf.tracebuf = ilogbuffer;
    #endif

    #if CONFIG_MRINGBUF_DEPTH
    mringbuf.head = 0;
    mringbuf.tail = 0;
    mringbuf.full = false;
    mringbuf.depth = CONFIG_MRINGBUF_DEPTH;
    mringbuf.width = LOG_LEN;
    mringbuf.tracebuf = mlogbuffer;
    #endif

    #if CONFIG_FRINGBUF_DEPTH
    fringbuf.head = 0;
    fringbuf.tail = 0;
    fringbuf.full = false;
    fringbuf.depth = CONFIG_FRINGBUF_DEPTH;
    fringbuf.width = FTC_WIDTH;
    fringbuf.tracebuf = (void *)fcallbuffer;
    #endif

    #if CONFIG_DRINGBUF_DEPTH
    dringbuf.head = 0;
    dringbuf.tail = 0;
    dringbuf.full = false;
    dringbuf.depth = CONFIG_DRINGBUF_DEPTH;
    dringbuf.width = LOG_LEN;
    dringbuf.tracebuf = dlogbuffer;
    #endif

    #if CONFIG_ERINGBUF_DEPTH
    eringbuf.head = 0;
    eringbuf.tail = 0;
    eringbuf.full = false;
    eringbuf.depth = CONFIG_ERINGBUF_DEPTH;
    eringbuf.width = LOG_LEN;
    eringbuf.tracebuf = elogbuffer;
    #endif
}

/*从环形缓冲区读数据*/
void *ringBufRead(ringBuf *ringbuf)
{
    size_t ret = ringbuf->head;
	if((ringbuf->head == ringbuf->tail) && !ringbuf->full)//Empty：(head == tail) && (!full)
	{
		printf("ringBuffer is empty!\n");
		return NULL;
	}
    ringbuf->head = H_NEXT_BUF(ringbuf);
    ringbuf->full = false;
    return (void *)((uint8_t *)(ringbuf->tracebuf)+ret*ringbuf->width);//pointer of type ‘void *’ used in arithmetic
}

/*往环形缓冲区写数据*/
void ringBufWrite(ringBuf *ringbuf, void *data)
{
    memcpy((void *)((uint8_t *)(ringbuf->tracebuf)+ringbuf->tail*ringbuf->width), data, ringbuf->width);//pointer of type ‘void *’ used in arithmetic
    ringbuf->tail = T_NEXT_BUF(ringbuf);
    if (ringbuf->full)
    {
        ringbuf->head = H_NEXT_BUF(ringbuf);
    }
    else
    {
        if(ringbuf->head == ringbuf->tail)//Full
        {
            ringbuf->full = true;
        }
    }
}

/*计算环形缓冲区数据长度*/
/*write指针可能在read指针前，也可能在read指针后*/
int ringBufLen(ringBuf *ringbuf)
{
	if(ringbuf->full)
	{
		return ringbuf->depth;
	}
    for (size_t len = 1; len < ringbuf->depth; len++)
    {
        if (H_NEXT_NBUF(ringbuf, len) == ringbuf->tail)
        {
            return (int)len;
        }
    }
    return 0;
}

bool ringBufEmpty(ringBuf *ringbuf)
{
    return (ringbuf->head == ringbuf->tail) && !ringbuf->full;
}

bool ringBufFull(ringBuf *ringbuf)
{
    return ringbuf->full;
}

#endif//CONFIG_IRINGBUF_DEPTH