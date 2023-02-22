#include <am.h>
#include <nemu.h>
#include <stdio.h>
#include <string.h>

#define AUDIO_FREQ_ADDR (AUDIO_ADDR + 0x00)
#define AUDIO_CHANNELS_ADDR (AUDIO_ADDR + 0x04)
#define AUDIO_SAMPLES_ADDR (AUDIO_ADDR + 0x08)
#define AUDIO_SBUF_SIZE_ADDR (AUDIO_ADDR + 0x0c)
#define AUDIO_INIT_ADDR (AUDIO_ADDR + 0x10)
#define AUDIO_COUNT_ADDR (AUDIO_ADDR + 0x14)

//head = 0 in nemu/src/device/audio.c
//Empty head = 0, tail = 0
//FULL  tail +1 = head

#define COUNT_MAX (buf_size - 1)
static volatile uint32_t tail = 0;

static uint32_t ring_add(uint32_t ptr, uint32_t len)
{
  return ((ptr + len) >= inl(AUDIO_SBUF_SIZE_ADDR)) ? ((ptr + len) - inl(AUDIO_SBUF_SIZE_ADDR)) : (ptr + len);
}

void __am_audio_init()
{
  tail = 0;
  outl(AUDIO_COUNT_ADDR, 0);
}

void __am_audio_config(AM_AUDIO_CONFIG_T *cfg)
{
  cfg->present = true;
  cfg->bufsize = inl(AUDIO_SBUF_SIZE_ADDR);
}

void __am_audio_ctrl(AM_AUDIO_CTRL_T *ctrl)
{
  outl(AUDIO_FREQ_ADDR, ctrl->freq);
  outl(AUDIO_CHANNELS_ADDR, ctrl->channels);
  outl(AUDIO_SAMPLES_ADDR, ctrl->samples);
  outl(AUDIO_INIT_ADDR, 1);
}

void __am_audio_status(AM_AUDIO_STATUS_T *stat)
{
  stat->count = inl(AUDIO_COUNT_ADDR);
}

void __am_audio_play(AM_AUDIO_PLAY_T *ctl)
{
  uint32_t audio_len = (uint8_t *)(ctl->buf.end) - (uint8_t *)(ctl->buf.start);
  uint32_t writed_count = 0;
  uint32_t buf_size = inl(AUDIO_SBUF_SIZE_ADDR);
  uint8_t *data_ptr = ((uint8_t *)ctl->buf.start);

  while (writed_count < audio_len)
  {
    uint32_t count = inl(AUDIO_COUNT_ADDR);
    uint32_t remain_len = COUNT_MAX - count;
    uint32_t write_len = (audio_len - writed_count) > remain_len ? remain_len : (audio_len - writed_count);

    if (tail + write_len >= buf_size)
    {
      for (uint32_t addr = (AUDIO_SBUF_ADDR + tail); addr < (AUDIO_SBUF_ADDR + buf_size); addr++)
      {
        outb(addr, *data_ptr++);
      }

      uint32_t len2 = tail + write_len - buf_size;
      for (uint32_t addr = (AUDIO_SBUF_ADDR); addr < (AUDIO_SBUF_ADDR + len2); addr++)
      {
        outb(addr, *data_ptr++);
      }
    }
    else
    {
      for (uint32_t addr = (AUDIO_SBUF_ADDR + tail); addr < (AUDIO_SBUF_ADDR + write_len + tail); addr++)
      {
        outb(addr, *data_ptr++);
      }
    }
    count += write_len;
    outw(AUDIO_COUNT_ADDR, count);
    tail = ring_add(tail, write_len);
    writed_count += write_len;
  }
}
