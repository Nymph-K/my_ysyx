#include <common.h>

#if defined(MULTIPROGRAM) && !defined(TIME_SHARING)
# define MULTIPROGRAM_YIELD() yield()
#else
# define MULTIPROGRAM_YIELD()
#endif

#define NAME(key) \
  [AM_KEY_##key] = #key,

static const char *keyname[256] __attribute__((used)) = {
  [AM_KEY_NONE] = "NONE",
  AM_KEYS(NAME)
};

size_t serial_write(const void *buf, size_t offset, size_t len) {
  for (size_t i = 0; i < len; i++)
  {
    putch(*(char *)buf++);
  }
  return len;
}

void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd);

size_t events_read(void *buf, size_t offset, size_t len) {
  AM_INPUT_KEYBRD_T kbd;
  __am_input_keybrd(&kbd);
  if(kbd.keycode != AM_KEY_NONE)
  {
    if (kbd.keydown)
    {
      return snprintf(buf, len, "kd %s\n", keyname[kbd.keycode]);
    }
    else
    {
      return snprintf(buf, len, "ku %s\n", keyname[kbd.keycode]);
    }
  }
  return 0;
}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg);
AM_GPU_CONFIG_T cfg;

size_t dispinfo_read(void *buf, size_t offset, size_t len) {
  __am_gpu_config(&cfg);
  Log("read_gpu_info: WIDTH:%d\nHEIGHT:%d\nVMEMSZ:%d\n", cfg.width, cfg.height, cfg.vmemsz);
  return snprintf(buf, len, "WIDTH:%d\nHEIGHT:%d\nVMEMSZ:%d\n", cfg.width, cfg.height, cfg.vmemsz);
}

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl);
AM_GPU_FBDRAW_T ctl;

//     fb_write(const void *buf, size_t offset, size_t len);
//                                x_y = offset      w_h = len
size_t fb_write(const void *buf, size_t x_y, size_t w_h) {
  ctl.x = (x_y >> 16) & 0xFFFF;
  ctl.y = x_y & 0xFFFF;
  ctl.w = (w_h >> 16) & 0xFFFF;
  ctl.h = w_h & 0xFFFF;
  ctl.pixels = (void *)buf;
  ctl.sync = 1;
  __am_gpu_fbdraw(&ctl);
  return ctl.w*ctl.h*4;
}

void init_device() {
  Log("Initializing devices...");
  ioe_init();
  __am_gpu_config(&cfg);
  printf("WIDTH:%d\nHEIGHT:%d\nVMEMSZ:%d\n", cfg.width, cfg.height, cfg.vmemsz);
  Log("Finish initialize");
}
