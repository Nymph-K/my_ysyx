#include <am.h>
#include <nemu.h>
#include <stdio.h>

#define SYNC_ADDR (VGACTL_ADDR + 4)

void __am_gpu_init() {
  // int i;
  // int h = inw(VGACTL_ADDR);  // TODO: get the correct height
  // int w = inw(VGACTL_ADDR + 2);  // TODO: get the correct width
  // uint32_t *fb = (uint32_t *)(uintptr_t)FB_ADDR;
  // for (i = 0; i < w * h; i ++) fb[i] = i;
  // outl(SYNC_ADDR, 1);
}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
  cfg->present = true;
  cfg->has_accel = false;
  cfg->height = inw(VGACTL_ADDR);
  cfg->width = inw(VGACTL_ADDR + 2);
  cfg->vmemsz = cfg->height * cfg->width * sizeof(uint32_t);
}

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
  uint32_t *fb = (uint32_t *)(uintptr_t)FB_ADDR;
  uint32_t height = inw(VGACTL_ADDR);
  uint32_t width = inw(VGACTL_ADDR + 2);
  uint32_t y = ctl->y;
  uint32_t w_pix = ctl->w;
  uint32_t y_off = y * width;
  uint32_t y_pix_off = 0;
  for (size_t j = 0; j < ctl->h; j++)
  {
    if((y + j) >= height) break;//if(y >= height) {y %= height; y_off = y * width;}
    uint32_t x = ctl->x;
    for (size_t i = 0; i < w_pix; i++)
    {
      if(x >= width) break;//if(x >= width) x %= width;
      fb[y_off + x] = ((uint32_t *)(ctl->pixels))[y_pix_off + i];
      x++;
    }
    y_off += width;
    y_pix_off += w_pix;
  }
  if (ctl->sync) {
    //printf("sync!\n");
    outl(SYNC_ADDR, 1);
  }
}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
  status->ready = true;
}
