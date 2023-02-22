/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <common.h>
#include <device/map.h>
#include <SDL2/SDL.h>

enum {
  reg_freq,
  reg_channels,
  reg_samples,
  reg_sbuf_size,
  reg_init,
  reg_count,
  nr_reg
};

//tail = 0 in abstract-machine/am/src/platform/nemu/ioe/audio.c
//Empty head = 0, tail = 0
//FULL  tail +1 = head
#define HEAD_MAX (CONFIG_SB_SIZE - 1)
static uint32_t head = 0;

static uint32_t ring_add(uint32_t ptr, uint32_t num)
{
  return ((ptr + num) >= CONFIG_SB_SIZE) ? ((ptr + num) - CONFIG_SB_SIZE) : (ptr + num);
}

static uint8_t *sbuf = NULL;
static uint32_t *audio_base = NULL;
static bool sdl_sudio_is_inited = false;

void callBack_fillAudioData(void *userdata, uint8_t *stream, int len);

static void init_sdl_audio() {
  if (sdl_sudio_is_inited)
  {
    SDL_PauseAudio(1);
    SDL_CloseAudio();
  }
  SDL_AudioSpec desired;
  desired.freq = audio_base[reg_freq];
  desired.channels = audio_base[reg_channels];
  desired.samples = audio_base[reg_samples];
  desired.channels = audio_base[reg_channels];
  desired.format = AUDIO_S16SYS;
  desired.userdata = NULL;
  desired.callback = callBack_fillAudioData;
  audio_base[reg_count] = 0;
  int ret = SDL_InitSubSystem(SDL_INIT_AUDIO);
  if (ret == 0) {
    SDL_OpenAudio(&desired, NULL);
    SDL_PauseAudio(0);
    sdl_sudio_is_inited = true;
  }
}

void callBack_fillAudioData(void *userdata, uint8_t *stream, int len)
{
    uint32_t count = audio_base[reg_count];

    int real_len = (len > count ? count : len);

    if(head + real_len > HEAD_MAX)
    {
      uint32_t len1 = HEAD_MAX - head;
      SDL_memcpy(stream, sbuf + head, len1);
      SDL_memcpy(stream + len1, sbuf, real_len - len1);
    }
    else
    {
      SDL_memcpy(stream, sbuf + head, real_len);
    }
    if (len > real_len)
    {
      SDL_memset(stream + real_len, 0, len - real_len);
    }
    head = ring_add(head, real_len);
    audio_base[reg_count] = count - real_len;
    //printf("head = %d, tail = %d, count = %d\n", head, tail, ring_queue_len(head, tail));
}

void destroy_sdl_audio(){
  SDL_PauseAudio(1);
  SDL_CloseAudio();
}

static void audio_io_handler(uint32_t offset, int len, bool is_write) {
  if(is_write && offset == reg_init) init_sdl_audio();
}

void init_audio() {
  uint32_t space_size = sizeof(uint32_t) * nr_reg;
  audio_base = (uint32_t *)new_space(space_size);
  audio_base[reg_sbuf_size] = CONFIG_SB_SIZE;
  audio_base[reg_count] = 0;
  audio_base[reg_init] = 0;
#ifdef CONFIG_HAS_PORT_IO
  add_pio_map ("audio", CONFIG_AUDIO_CTL_PORT, audio_base, space_size, audio_io_handler);
#else
  add_mmio_map("audio", CONFIG_AUDIO_CTL_MMIO, audio_base, space_size, audio_io_handler);
#endif

  sbuf = (uint8_t *)new_space(CONFIG_SB_SIZE);
  add_mmio_map("audio-sbuf", CONFIG_SB_ADDR, sbuf, CONFIG_SB_SIZE, NULL);
  
  //init_sdl_audio();
  memset(sbuf, 0, CONFIG_SB_SIZE);
}
