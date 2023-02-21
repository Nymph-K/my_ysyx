#include <am.h>
#include <fcntl.h> 
#include <SDL.h>
#include <NDL.h>

#define RMASK 0x00ff0000
#define GMASK 0x0000ff00
#define BMASK 0x000000ff
#define AMASK 0x00000000

// SDL_Surface *max_surface = NULL;

void __am_gpu_init() {
  SDL_Init(0);
  int w, h;
  getWindowSize(&w, &h);
  NDL_OpenCanvas(&w, &h);
  // max_surface = SDL_CreateRGBSurface(SDL_SWSURFACE, w, h, 32, RMASK, GMASK, BMASK, AMASK);
}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
  if(cfg == NULL) return;
  getWindowSize(&(cfg->width), &(cfg->height));
  cfg->has_accel = false;
  cfg->present = true;
  cfg->vmemsz = cfg->width * cfg->height * sizeof(uint32_t);
}

// void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
//   if ((ctl->w | ctl->h) == 0) return;
  
//   SDL_Surface *src_surface = SDL_CreateRGBSurfaceFrom(ctl->pixels, ctl->w, ctl->h, 32, ctl->w * sizeof(uint32_t), RMASK, GMASK, BMASK, AMASK);
//   if(src_surface == NULL) return;

//   SDL_Rect dstrect;
//   dstrect.x = ctl->x;
//   dstrect.y = ctl->y;

//   SDL_BlitSurface(src_surface, NULL, max_surface, &dstrect);
//   SDL_FreeSurface(src_surface);

//   if (ctl->sync)
//     SDL_UpdateRect(max_surface, ctl->x, ctl->y, ctl->w, ctl->h);
// }

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
  NDL_DrawRect(ctl->pixels, ctl->x, ctl->y, ctl->w, ctl->h);
}
void __am_gpu_status(AM_GPU_STATUS_T *status) {
  status->ready = true;
}
