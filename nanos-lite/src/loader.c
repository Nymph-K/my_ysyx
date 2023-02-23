#include <proc.h>
#include <elf.h>
#include <fs.h>

#ifdef __LP64__
# define Elf_Ehdr Elf64_Ehdr
# define Elf_Phdr Elf64_Phdr
#else
# define Elf_Ehdr Elf32_Ehdr
# define Elf_Phdr Elf32_Phdr
#endif

#if defined(__ISA_AM_NATIVE__)
#define EXPECT_TYPE EM_X86_64
#elif defined(__ISA_X86__)
#define EXPECT_TYPE EM_X86_64
#elif defined(__ISA_MIPS32__)
#define EXPECT_TYPE EM_MIPS
#elif defined(__ISA_RISCV32__) || defined(__ISA_RISCV64__)
#define EXPECT_TYPE EM_RISCV
#else
#error Unsupported ISA
#endif

#define DEUBG_PRINTF 0
#if DEUBG_PRINTF
#define debug_printf(format, ...) printf(format, ##__VA_ARGS__)
#else
#define debug_printf(format, ...)
#endif // DEUBG_PRINTF

Elf_Ehdr elf_header;
Elf_Phdr *program_headers = NULL;

size_t ramdisk_read(void *buf, size_t offset, size_t len);

int init_elf(int fd);
int Process_object(int fd);
int get_file_header(int fd);
int process_program_headers(int fd);
int get_program_headers(int fd);
size_t get_filedata(int fd, void *var, long offset, size_t size);

int init_elf(int fd)
{
    if(fd != 0) 
        return Process_object(fd);
    return 0;
}

int Process_object(int fd)
{

    if (!get_file_header(fd))
    {
        debug_printf("get file header Failed!\n");
        return 0;
    }
    if (!process_program_headers(fd))
    {
        return 0;
    }

    return 1;
}

int get_file_header(int fd)
{
    if (get_filedata(fd, elf_header.e_ident, 0, EI_NIDENT) != EI_NIDENT)
        return 0;
 
    assert(*(uint32_t *)elf_header.e_ident == 0x464C457F);
    
    if (get_filedata(fd, (uint8_t *)(&elf_header) + EI_NIDENT, EI_NIDENT, sizeof(Elf_Ehdr) - EI_NIDENT) != (sizeof(Elf_Ehdr) - EI_NIDENT))
        return 0;
    assert(elf_header.e_machine == EM_RISCV);
    return 1;
}

int process_program_headers(int fd)
{
    if (elf_header.e_phnum == 0)
    {
        if (elf_header.e_phoff != 0)
        {
            debug_printf("possibly corrupt ELF header - it has a non-zero program header offset, but no program headers\n");
            return 0;
        }
        else
        {
            debug_printf("\nThere are no program headers in this file.\n");
            return 0;
        }
    }

    return get_program_headers(fd);
}

int get_program_headers(int fd)
{
    if (program_headers != NULL)
    {
        free(program_headers);
    }


    Elf_Phdr *phdrs;

    phdrs = (Elf_Phdr *)malloc(elf_header.e_phnum * sizeof(Elf_Phdr));
    if (phdrs == NULL)
    {
        debug_printf("Out of memory\n");
        return 0;
    }

    if (get_filedata(fd, phdrs, elf_header.e_phoff, (elf_header.e_phentsize * elf_header.e_phnum)) == (elf_header.e_phentsize * elf_header.e_phnum))
    {
        program_headers = phdrs;
        return 1;
    }

    free(phdrs);
    return 0;
}

size_t get_filedata(int fd, void *var, long offset, size_t size)
{
    if (size == 0)
        return 0;

    if (var == NULL)
        return 0;

    fs_lseek(fd, offset, SEEK_SET);

    return fs_read(fd, var, size);
}

static uintptr_t loader(PCB *pcb, const char *filename) {
    int fd = fs_open(filename, 0 ,0);
    if(fd == 0) 
        return 0;
    if(init_elf(fd) == 0)
        return 0;
    Elf_Phdr *phdr = program_headers;
    for (size_t i = 0; i < elf_header.e_phnum; i++, phdr++)
    {
        if(phdr->p_type == PT_LOAD)
            {
                get_filedata(fd, (void *)phdr->p_vaddr, phdr->p_offset, phdr->p_filesz);
                memset((uint8_t *)phdr->p_vaddr + phdr->p_filesz, 0, phdr->p_memsz - phdr->p_filesz);
            }
    }
    free(program_headers);
    fs_close(fd);
    return elf_header.e_entry;
}

void naive_uload(PCB *pcb, const char *filename) {
  uintptr_t entry = loader(pcb, filename);
  assert(entry != 0);
  Log("Jump to entry = %p", entry);
  ((void(*)())entry) ();
}