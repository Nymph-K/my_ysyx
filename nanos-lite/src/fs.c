#include <fs.h>
#include <string.h>

size_t ramdisk_read(void *buf, size_t offset, size_t len);
size_t ramdisk_write(const void *buf, size_t offset, size_t len);
size_t serial_write(const void *buf, size_t offset, size_t len);
size_t events_read(void *buf, size_t offset, size_t len);
size_t dispinfo_read(void *buf, size_t offset, size_t len);
size_t fb_write(const void *buf, size_t offset, size_t len);
size_t get_fbsize(void);
// size_t sbctl_write(const void *buf, size_t offset, size_t len);
// size_t sbctl_read(const void *buf, size_t offset, size_t len);
// size_t sb_write(const void *buf, size_t offset, size_t len);

typedef size_t (*ReadFn) (void *buf, size_t offset, size_t len);
typedef size_t (*WriteFn) (const void *buf, size_t offset, size_t len);

typedef struct {
  char *name;
  size_t size;
  size_t disk_offset;
  ReadFn read;
  WriteFn write;
  size_t open_offset;
} Finfo;

enum {FD_STDIN, 
      FD_STDOUT, 
      FD_STDERR, 
      FD_EVENTS, 
      FD_DISPINFO,
      FD_FB, 
      // FD_SBCTL,
      // FD_SB,
};

size_t invalid_read(void *buf, size_t offset, size_t len) {
  panic("should not reach here");
  return 0;
}

size_t invalid_write(const void *buf, size_t offset, size_t len) {
  panic("should not reach here");
  return 0;
}

size_t stdin_invalid_read(void *buf, size_t offset, size_t len) {
  panic("stdin should not reach here");
  return 0;
}

size_t stdin_invalid_write(const void *buf, size_t offset, size_t len) {
  panic("stdin should not reach here \nbuf=%s \t offset=%d \t len = %d\n", buf, offset, len);
  return 0;
}

size_t stdout_invalid_read(void *buf, size_t offset, size_t len) {
  panic("stdout should not reach here");
  return 0;
}

size_t stderr_invalid_read(void *buf, size_t offset, size_t len) {
  panic("stderr should not reach here");
  return 0;
}

size_t events_invalid_write(const void *buf, size_t offset, size_t len) {
  panic("events should not reach here");
  return 0;
}

size_t dispinfo_invalid_write(const void *buf, size_t offset, size_t len) {
  panic("dispinfo should not reach here");
  return 0;
}

size_t fb_invalid_read(void *buf, size_t offset, size_t len) {
  panic("fb should not reach here");
  return 0;
}

/* This is the information about all files in disk. */
static Finfo file_table[] __attribute__((used)) = {
  [FD_STDIN]  = {"stdin", 0, 0, stdin_invalid_read, stdin_invalid_write, 0},
  [FD_STDOUT] = {"stdout", 0, 0, stdout_invalid_read, serial_write, 0},
  [FD_STDERR] = {"stderr", 0, 0, stderr_invalid_read, serial_write, 0},
  [FD_EVENTS] = {"/dev/events", 0, 0, events_read, events_invalid_write, 0},
  [FD_DISPINFO] = {"/proc/dispinfo", 0, 0, dispinfo_read, dispinfo_invalid_write, 0},
  [FD_FB] = {"/dev/fb", 0, 0, fb_invalid_read, fb_write, 0},
  // [FD_SBCTL] = {"/dev/sbctl", 0, 0, sbctl_read, sbctl_write, 0},
  // [FD_SB] = {"/dev/sb", 0, 0, invalid_read, sb_write, 0},
  #include "files.h"
};

static size_t file_num = sizeof(file_table)/sizeof(file_table[0]);

void init_fs() {
  file_table[FD_FB].size = get_fbsize();
}

int fs_open(const char *pathname, int flags, int mode)
{
  for (size_t i = 0; i < file_num; i++)
  {
    if(strcmp(pathname, file_table[i].name) == 0){
      file_table[i].open_offset = 0;
      return i;
    }
  }
  panic("No such file: %s\n", pathname);
  return 0;
}

size_t fs_read(int fd, void *buf, size_t len)
{
  assert(FD_STDIN <= fd && fd < file_num);
  if (file_table[fd].read != NULL)
  {
    return file_table[fd].read(buf, file_table[fd].open_offset, len);
  }
  else
  {
    size_t remain_len = file_table[fd].size - file_table[fd].open_offset;
    if (len <= remain_len)
    {
      ramdisk_read(buf, file_table[fd].disk_offset + file_table[fd].open_offset, len);
      file_table[fd].open_offset += len;
      return len;
    }
    else
    {
      ramdisk_read(buf, file_table[fd].disk_offset + file_table[fd].open_offset, remain_len);
      file_table[fd].open_offset += remain_len;
      return remain_len;
    }
  }
}

size_t fs_write(int fd, const void *buf, size_t len)
{
  assert(FD_STDIN <= fd && fd < file_num);
  if (file_table[fd].write != NULL)
  {
    return file_table[fd].write(buf, file_table[fd].open_offset, len);
  }
  else
  {
    size_t remain_len = file_table[fd].size - file_table[fd].open_offset;
    if (len <= remain_len)
    {
      ramdisk_write(buf, file_table[fd].disk_offset + file_table[fd].open_offset, len);
      file_table[fd].open_offset += len;
      return len;
    }
    else
    {
      ramdisk_write(buf, file_table[fd].disk_offset + file_table[fd].open_offset, remain_len);
      file_table[fd].open_offset += remain_len;
      return remain_len;
    }
  }
}

size_t fs_lseek(int fd, size_t offset, int whence)
{
  assert(FD_STDIN <= fd && fd < file_num);
  signed long long base;
  switch (whence)
  {
    case SEEK_SET: base = 0; break;

    case SEEK_CUR: base = file_table[fd].open_offset; break;

    case SEEK_END: base = file_table[fd].size; break;
    
    default:
      return file_table[fd].open_offset;
  }
  signed long long result = base + (signed long long)offset;
  if (result < 0)
    file_table[fd].open_offset = 0;
  else if(result > file_table[fd].size)
    file_table[fd].open_offset = file_table[fd].size;
  else
    file_table[fd].open_offset = result;
  return file_table[fd].open_offset;
}

const char *fs_fname(int fd)
{
  assert(FD_STDIN <= fd && fd < file_num);
  return file_table[fd].name;
}

int fs_close(int fd)
{
  return 0;
}