#include <am.h>

void __am_audio_init() {
  not_support();
}

void __am_audio_config(AM_AUDIO_CONFIG_T *cfg) {
  not_support();
}

void __am_audio_ctrl(AM_AUDIO_CTRL_T *ctrl) {
  not_support();
}

void __am_audio_status(AM_AUDIO_STATUS_T *stat) {
  not_support();
}

static void audio_write(uint8_t *buf, int len) {
  not_support();
}

void __am_audio_play(AM_AUDIO_PLAY_T *ctl) {
  not_support();
}
