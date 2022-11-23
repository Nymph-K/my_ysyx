#ifndef _RINGBUF_H
#define _RINGBUF_H

#include <common.h>

#if CONFIG_IRINGBUF_LEN


struct ringBuf
{
    bool   full;
	size_t head;
	size_t tail;
	size_t size;
	char (*logbuffer)[128];//pointer -> array[0-127]
};

extern struct ringBuf iringbuf;
extern struct ringBuf mringbuf;

void ringBufInit(void);
char *ringBufRead(struct ringBuf *ringbuf);
void ringBufWrite(struct ringBuf *ringbuf, char *str);
int ringBufLen(struct ringBuf *ringbuf);
bool ringBufEmpty(struct ringBuf *ringbuf);
bool ringBufFull(struct ringBuf *ringbuf);

#endif//CONFIG_RINGBUF_LEN

#endif//_RINGBUF_H