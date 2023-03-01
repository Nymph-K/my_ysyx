#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static int evtdev = -1;
static int fbdev = -1;
static int screen_w = 0, screen_h = 0;
static int window_w = 0, window_h = 0;
static int fd_events = -1;
static int fd_dispinfo = -1;
static int fd_fb = -1;
// static int fd_sb = -1;
// static int fd_sbctl = -1;
static uint32_t boot_time = 0;


uint32_t NDL_GetTicks() {
  struct timeval tod;
  gettimeofday(&tod, NULL);
  return (tod.tv_sec * 1000 + tod.tv_usec / 1000 - boot_time);
}

int NDL_PollEvent(char *buf, int len) {
  return read(fd_events, buf, len);
}

void getWindowSize(int *win_w, int *win_h)
{
  char whbuf[64];
  size_t i;
  read(fd_dispinfo, whbuf, sizeof(whbuf));
  for (i = 0; i < sizeof(whbuf); i++)// find 0-9
  {
    if('0' <= whbuf[i] && whbuf[i] <= '9') break;
  }
  *win_w = atoi(whbuf+i);
  for (; i < sizeof(whbuf); i++)// exit 0-9
  {
    if(whbuf[i] < '0' || '9' < whbuf[i]) break;
  }
  for (; i < sizeof(whbuf); i++)// find 0-9
  {
    if('0' <= whbuf[i] && whbuf[i] <= '9') break;
  }
  *win_h = atoi(whbuf+i);
}

void NDL_OpenCanvas(int *w, int *h) {
  getWindowSize(&window_w, &window_h);
  if ((*w |*h) == 0)
  {
    *w = window_w;
    *h = window_h;
  }
  *h = *h > window_h ? window_h : *h;
  *w = *w > window_w ? window_w : *w;
  screen_w = *w; screen_h = *h;
  
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
  getWindowSize(&window_w, &window_h);
  int screen_x = (window_w - screen_w) / 2;//center
  int screen_y = (window_h - screen_h) / 2;//center
  static int count = 0;
  printf("x = %d, y = %d, w = %d, h = %d, window_w = %d, window_h = %d, screen_w = %d, screen_h = %d, screen_x = %d, screen_y = %d, count = %d\n", x, y, w, h, window_w, window_h, screen_w, screen_h, screen_x, screen_y, count);
  count++;
  // x += screen_x;
  // y += screen_y;
  // if (w == window_w && (x|y) == 0)
  // {
  //   lseek(fd_fb, 0, SEEK_SET);
  //   write(fd_fb, pixels, w*h*sizeof(uint32_t));
  // }
  // else
  {
    size_t offset = (y * window_w + x) * 4;
    size_t len = w*sizeof(uint32_t);
    for (size_t i = 0; i < h; i++)
    {
      lseek(fd_fb, offset, SEEK_SET);
      write(fd_fb, pixels, len);
      offset += window_w * 4;
      pixels += w;
    }
  }
}


void NDL_OpenAudio(int freq, int channels, int samples) {
  // int buf[3] = {freq, channels, samples};
  // write(fd_sbctl, buf, sizeof(buf));
}

void NDL_CloseAudio() {
  // printf("file: %s line: %d func: %s is not support!\n", __FILE__, __LINE__, __FUNCTION__);
}

int NDL_PlayAudio(void *buf, int len) {
  // if(buf==NULL || len==0) return 0;
  // return write(fd_sb, buf, len);
}

int NDL_QueryAudio() {
  // int count;
  // if(read(fd_sbctl, &count, 4))
  //   return count;
  // else
  //   return 0;
}

int NDL_Init(uint32_t flags) {
  if (getenv("NWM_APP")) {
    evtdev = 3;
  }
  fd_events = open("/dev/events", 0, 0);
  if(fd_events == 0) {return 1;}
  fd_dispinfo = open("/proc/dispinfo", 0, 0);
  if(fd_dispinfo == 0) {return 1;}
  fd_fb = open("/dev/fb", 0, 0);
  if(fd_fb == 0) {return 1;}
  // fd_sb = open("/dev/sb", 0, 0);
  // if(fd_sb == 0) {return 1;}
  // fd_sbctl = open("/dev/sbctl", 0, 0);
  // if(fd_sbctl == 0) {return 1;}

  struct timeval tod;
  gettimeofday(&tod, NULL);
  boot_time = tod.tv_sec * 1000 + tod.tv_usec / 1000;
  return 0;
}

void NDL_Quit() {
  //exit(0);
}
