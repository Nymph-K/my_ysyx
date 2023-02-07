#ifndef _RINGBUF_H
#define _RINGBUF_H

#include <common.h>

#if CONFIG_IRINGBUF_DEPTH|CONFIG_MRINGBUF_DEPTH|CONFIG_FRINGBUF_DEPTH|CONFIG_DRINGBUF_DEPTH

#define LOG_LEN 128
#define FTC_WIDTH sizeof(callBuf)

typedef struct
{
    bool   full;
	size_t head;
	size_t tail;
	size_t width;
	size_t depth;
	void *tracebuf;
} ringBuf;

typedef struct
{
    char c_r;//call or return
	vaddr_t pc;
	vaddr_t dnpc;
	int pc_fndx;
	int dnpc_fndx;
} callBuf;

extern ringBuf iringbuf;
extern ringBuf mringbuf;
extern ringBuf fringbuf;
extern ringBuf dringbuf;
extern ringBuf eringbuf;

void ringBufInit(void);
void *ringBufRead(ringBuf *ringbuf);
void ringBufWrite(ringBuf *ringbuf, void *data);
int ringBufLen(ringBuf *ringbuf);
bool ringBufEmpty(ringBuf *ringbuf);
bool ringBufFull(ringBuf *ringbuf);

#endif//CONFIG_RINGBUF_LEN

#endif//_RINGBUF_H