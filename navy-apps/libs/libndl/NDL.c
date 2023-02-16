#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static int evtdev = -1;
static int fbdev = -1;
static int screen_w = 0, screen_h = 0;
static int fd_events = -1;
static int fd_dispinfo = -1;
static int fd_fb = -1;

uint32_t NDL_GetTicks() {
  struct timeval tod;
  gettimeofday(&tod, NULL);
  return tod.tv_usec/1000;
}

int NDL_PollEvent(char *buf, int len) {
  return read(fd_events, buf, len);
}

void NDL_OpenCanvas(int *w, int *h) {
  {
    char whbuf[64];
    size_t i;
    int cfg_w, cfg_h;
    read(fd_dispinfo, whbuf, sizeof(whbuf));
    for (i = 0; i < sizeof(whbuf); i++)
    {
      if('0' <= whbuf[i] && whbuf[i] <= '9') break;
    }
    cfg_w = atoi(whbuf+i);
    for (; i < sizeof(whbuf); i++)
    {
      if('0' <= whbuf[i] && whbuf[i] <= '9') break;
    }
    cfg_h = atoi(whbuf+i);
    if(*w == 0 && *h == 0)
    {
      *w = cfg_w;
      *h = cfg_h;
    }
    else if (*w > cfg_w)
    {
      *w = cfg_w;
    }
    else if (*h = cfg_h)
    {
      *h = cfg_h;
    }
  }
  if (getenv("NWM_APP")) {
    int fbctl = 4;
    fbdev = 5;
    screen_w = *w; screen_h = *h;
    char buf[64];
    int len = sprintf(buf, "%d %d", screen_w, screen_h);
    // let NWM resize the window and create the frame buffer
    write(fbctl, buf, len);
    while (1) {
      // 3 = evtdev
      int nread = read(3, buf, sizeof(buf) - 1);
      if (nread <= 0) continue;
      buf[nread] = '\0';
      if (strcmp(buf, "mmap ok") == 0) break;
    }
    close(fbctl);
  }
}

void NDL_DrawRect(uint32_t *pixels, int x, int y, int w, int h) {
  size_t x_y = x << 16 | y;
  size_t w_h = w << 16 | h;
  fseek(fd_fb, x_y, SEEK_SET);
  write(fd_fb, pixels, w_h);
}

void NDL_OpenAudio(int freq, int channels, int samples) {
}

void NDL_CloseAudio() {
}

int NDL_PlayAudio(void *buf, int len) {
  return 0;
}

int NDL_QueryAudio() {
  return 0;
}

int NDL_Init(uint32_t flags) {
  if (getenv("NWM_APP")) {
    evtdev = 3;
  }
  fd_events = open("/dev/events", 0, 0);
  if(fd_events == 0) {Log("fd error!"); return 1;}
  fd_dispinfo = open("/proc/dispinfo", 0, 0);
  if(fd_dispinfo == 0) {Log("fd error!"); return 1;}
  fd_fb = open("/dev/fb", 0, 0);
  if(fd_fb == 0) {Log("fd error!"); return 1;}
  return 0;
}

void NDL_Quit() {
}
