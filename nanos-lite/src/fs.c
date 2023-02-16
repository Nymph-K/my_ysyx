#include <fs.h>
#include <string.h>

size_t ramdisk_read(void *buf, size_t offset, size_t len);
size_t ramdisk_write(const void *buf, size_t offset, size_t len);

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

enum {FD_STDIN, FD_STDOUT, FD_STDERR, FD_FB};

size_t invalid_read(void *buf, size_t offset, size_t len) {
  panic("should not reach here");
  return 0;
}

size_t invalid_write(const void *buf, size_t offset, size_t len) {
  panic("should not reach here");
  return 0;
}

/* This is the information about all files in disk. */
static Finfo file_table[] __attribute__((used)) = {
  [FD_STDIN]  = {"stdin", 0, 0, invalid_read, invalid_write, 0},
  [FD_STDOUT] = {"stdout", 0, 0, invalid_read, invalid_write, 0},
  [FD_STDERR] = {"stderr", 0, 0, invalid_read, invalid_write, 0},
#include "files.h"
};
static size_t file_num = sizeof(file_table)/sizeof(file_table[0]);
void init_fs() {
  // TODO: initialize the size of /dev/fb
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
  if (fd == FD_STDIN || fd == FD_STDOUT || fd == FD_STDERR)
  {
    return 0;
  }
  else
  {
    assert(FD_FB <= fd && fd < file_num);
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
  if (fd == FD_STDIN)
  {
    return 0;
  }
  else if (fd == FD_STDOUT || fd == FD_STDERR)
  {
    for (size_t i = 0; i < len; i++)
    {
      putch(*(char *)buf++);
    }
    return len;
  }
  else
  {
    assert(FD_FB <= fd && fd < file_num);
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
  if (fd == FD_STDIN || fd == FD_STDOUT || fd == FD_STDERR)
  {
    return 0;
  }
  else
  {
    assert(FD_FB <= fd && fd < file_num);
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
}

int fs_close(int fd)
{
  return 0;
}