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
  reg_count,// [31:16] head, [15:0] tail
  nr_reg
};

static uint32_t ring_queue_len(uint32_t head, uint32_t tail)
{
  uint32_t len = tail > head ? tail - head : CONFIG_SB_SIZE + tail - head;
  return len;
}

static uint32_t ring_queue_add(uint32_t ptr, uint32_t num)
{
  uint32_t new_ptr = ptr + num >= CONFIG_SB_SIZE ? ptr + num - CONFIG_SB_SIZE : ptr + num;
  return new_ptr;
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
  SDL_InitSubSystem(SDL_INIT_AUDIO);
  SDL_OpenAudio(&desired, NULL);
  SDL_PauseAudio(0);
  sdl_sudio_is_inited = true;
}

void callBack_fillAudioData(void *userdata, uint8_t *stream, int len)
{
    SDL_memset(stream, 0, len);

    uint32_t tail = audio_base[reg_count] & 0xffff;
    uint32_t head = audio_base[reg_count] >> 16;
    uint32_t count = ring_queue_len(head, tail);

    int real_len = (len > count ? count : len);

    if(head + real_len >= CONFIG_SB_SIZE)
    {
      uint32_t len1 = CONFIG_SB_SIZE - head;
      SDL_memcpy(stream, sbuf + head, len1);
      SDL_memcpy(stream + len1, sbuf, real_len - len1);
    }
    else
    {
      SDL_memcpy(stream, sbuf + head, real_len);
    }
    head = ring_queue_add(head, real_len);
    audio_base[reg_count] = (head << 16) | (audio_base[reg_count] & ~0xffff0000);
}

void destroy_sdl_audio(){
  SDL_PauseAudio(1);
  SDL_CloseAudio();
}

static void audio_io_handler(uint32_t offset, int len, bool is_write) {
  if(is_write) init_sdl_audio();
}


void init_audio() {
  uint32_t space_size = sizeof(uint32_t) * nr_reg;
  audio_base = (uint32_t *)new_space(space_size);
  audio_base[reg_sbuf_size] = CONFIG_SB_SIZE;
  audio_base[reg_count] = 0;
#ifdef CONFIG_HAS_PORT_IO
  add_pio_map ("audio", CONFIG_AUDIO_CTL_PORT, audio_base, space_size, audio_io_handler);
#else
  add_mmio_map("audio", CONFIG_AUDIO_CTL_MMIO, audio_base, space_size, audio_io_handler);
#endif

  sbuf = (uint8_t *)new_space(CONFIG_SB_SIZE);
  add_mmio_map("audio-sbuf", CONFIG_SB_ADDR, sbuf, CONFIG_SB_SIZE, NULL);
  
  init_sdl_audio();
  memset(sbuf, 0, CONFIG_SB_SIZE);
}
