#include <cpu/ringbuf.h>
#include <string.h>

#if CONFIG_IRINGBUF_LEN|CONFIG_MRINGBUF_LEN

#define H_NEXT_NBUF(cur, n) (cur->head+n)%(cur->size)
#define H_NEXT_BUF(cur) H_NEXT_NBUF(cur, 1)
#define T_NEXT_NBUF(cur, n) (cur->tail+n)%(cur->size)
#define T_NEXT_BUF(cur) T_NEXT_NBUF(cur, 1)

#if CONFIG_IRINGBUF_LEN
struct ringBuf iringbuf;
static char ilogbuffer[CONFIG_IRINGBUF_LEN][128] = {0};
#endif
#if CONFIG_MRINGBUF_LEN
struct ringBuf mringbuf;
static char mlogbuffer[CONFIG_MRINGBUF_LEN][128] = {0};
#endif

/*环形缓冲区初始化函数*/
/*使用全局变量*/
void ringBufInit(void)
{
    #if CONFIG_IRINGBUF_LEN
    iringbuf.head = 0;
    iringbuf.tail = 0;
    iringbuf.full = false;
    iringbuf.size = CONFIG_IRINGBUF_LEN;
    iringbuf.logbuffer = ilogbuffer;
    #endif

    #if CONFIG_MRINGBUF_LEN
    mringbuf.head = 0;
    mringbuf.tail = 0;
    mringbuf.full = false;
    mringbuf.size = CONFIG_MRINGBUF_LEN;
    mringbuf.logbuffer = mlogbuffer;
    #endif
}

/*从环形缓冲区读数据*/
char *ringBufRead(struct ringBuf *ringbuf)
{
    size_t ret = ringbuf->head;
	if((ringbuf->head == ringbuf->tail) && !ringbuf->full)//Empty：(head == tail) && (!full)
	{
		printf("ringBuffer is empty!\n");
		return NULL;
	}
    ringbuf->head = H_NEXT_BUF(ringbuf);
    ringbuf->full = false;
    return ringbuf->logbuffer[ret];
}

/*往环形缓冲区写数据*/
void ringBufWrite(struct ringBuf *ringbuf, char *str)
{
    strcpy(ringbuf->logbuffer[ringbuf->tail], str);
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
int ringBufLen(struct ringBuf *ringbuf)
{
	if(ringbuf->full)
	{
		return ringbuf->size;
	}
    for (size_t len = 1; len < ringbuf->size; len++)
    {
        if (H_NEXT_NBUF(ringbuf, len) == ringbuf->tail)
        {
            return (int)len;
        }
    }
    return 0;
}

bool ringBufEmpty(struct ringBuf *ringbuf)
{
    return (ringbuf->head == ringbuf->tail) && !ringbuf->full;
}

bool ringBufFull(struct ringBuf *ringbuf)
{
    return ringbuf->full;
}

#endif//CONFIG_IRINGBUF_LEN