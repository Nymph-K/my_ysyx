#include <am.h>
#include <nemu.h>
#include <string.h>

#define AUDIO_FREQ_ADDR      (AUDIO_ADDR + 0x00)
#define AUDIO_CHANNELS_ADDR  (AUDIO_ADDR + 0x04)
#define AUDIO_SAMPLES_ADDR   (AUDIO_ADDR + 0x08)
#define AUDIO_SBUF_SIZE_ADDR (AUDIO_ADDR + 0x0c)
#define AUDIO_INIT_ADDR      (AUDIO_ADDR + 0x10)
#define AUDIO_COUNT_ADDR     (AUDIO_ADDR + 0x14)

static uint32_t ring_queue_len(uint32_t head, uint32_t tail)
{
  return (tail > head) ? (tail - head) : (inl(AUDIO_SBUF_SIZE_ADDR) + tail - head);
}

static uint32_t ring_queue_add(uint32_t ptr, uint32_t num)
{
  return (ptr + num >= inl(AUDIO_SBUF_SIZE_ADDR)) ? (ptr + num - inl(AUDIO_SBUF_SIZE_ADDR)) : (ptr + num);
}

void __am_audio_init() {
  outl(AUDIO_COUNT_ADDR, 0);
}

void __am_audio_config(AM_AUDIO_CONFIG_T *cfg) {
  cfg->present = true;
  cfg->bufsize = inl(AUDIO_SBUF_SIZE_ADDR);
}

void __am_audio_ctrl(AM_AUDIO_CTRL_T *ctrl) {
  outl(AUDIO_FREQ_ADDR, ctrl->freq);
  outl(AUDIO_CHANNELS_ADDR, ctrl->channels);
  outl(AUDIO_SAMPLES_ADDR, ctrl->samples);
}

void __am_audio_status(AM_AUDIO_STATUS_T *stat) {
  uint32_t tail = inw(AUDIO_COUNT_ADDR);
  uint32_t head = inw(AUDIO_COUNT_ADDR + 2);
  stat->count = ring_queue_len(head, tail);
}

void __am_audio_play(AM_AUDIO_PLAY_T *ctl) {
  uint32_t tail = inw(AUDIO_COUNT_ADDR);
  uint32_t head = inw(AUDIO_COUNT_ADDR + 2);
  uint32_t count = ring_queue_len(head, tail);
  uint32_t audio_len = ctl->buf.end - ctl->buf.start;
  uint32_t buf_size = inl(AUDIO_SBUF_SIZE_ADDR);
  uint8_t *data_ptr = ((uint8_t *)ctl->buf.start);
  while (count + audio_len >= buf_size)//wait for play
  {
    head = inw(AUDIO_COUNT_ADDR + 2);
    count = ring_queue_len(head, tail);
  }
  // if (count + audio_len >= buf_size)//over write head
  // {
  //   outw(AUDIO_COUNT_ADDR + 2, ring_queue_add(tail, audio_len + 1));
  // }
  if(tail + audio_len >= buf_size)
  {
    for (uint32_t ptr = (AUDIO_SBUF_ADDR + tail); ptr < (AUDIO_SBUF_ADDR + buf_size); ptr++)
    {
      outb(ptr, *data_ptr++);
    }
    
    uint32_t len1 = buf_size - tail;
    for (uint32_t ptr = (AUDIO_SBUF_ADDR); ptr < (AUDIO_SBUF_ADDR + audio_len - len1); ptr++)
    {
      outb(ptr, *data_ptr++);
    }
  }
  else
  {
    for (uint32_t ptr = (AUDIO_SBUF_ADDR + tail); ptr < (AUDIO_SBUF_ADDR + audio_len + tail); ptr++)
    {
      outb(ptr, *data_ptr++);
    }
  }
  outw(AUDIO_COUNT_ADDR, ring_queue_add(tail, audio_len));
}
