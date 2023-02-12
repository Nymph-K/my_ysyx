#include <proc.h>
#include <elf.h>

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
int init_elf();
int Process_object();
int get_file_header();
int process_program_headers();
int get_program_headers();
void *get_filedata(void *var, long offset, size_t size, size_t nmemb);

int init_elf()
{
    Process_object();
    return 1;
}

int Process_object()
{

    if (!get_file_header())
    {
        debug_printf("get file header Failed!\n");
        return 0;
    }
    if (!process_program_headers())
    {
        return 0;
    }

    return 1;
}

int get_file_header()
{
    if (ramdisk_read(elf_header.e_ident, 0, EI_NIDENT) != EI_NIDENT)
        return 0;
 
    assert(*(uint32_t *)elf_header.e_ident == 0x464C457F);
    
    if (ramdisk_read((uint8_t *)(&elf_header) + EI_NIDENT, EI_NIDENT, sizeof(Elf_Ehdr) - EI_NIDENT) != (sizeof(Elf_Ehdr) - EI_NIDENT))
        return 0;
    assert(elf_header.e_machine == EM_RISCV);
    return 1;
}

int process_program_headers()
{
    if (elf_header.e_phnum == 0)
    {
        if (elf_header.e_phoff != 0)
        {
            debug_printf("possibly corrupt ELF header - it has a non-zero program"
                         " header offset, but no program headers");
        }
        else
        {
            debug_printf("\nThere are no program headers in this file.\n");
            return 0;
        }
    }
    else
    {
        debug_printf("\nProgram Headers:\n");
        debug_printf("  Type           Offset   VirtAddr           PhysAddr           FileSiz  MemSiz   Flg Align\n");
    }

    return get_program_headers();
}

int get_program_headers()
{
    if (program_headers != NULL)
        return 1;

    Elf_Phdr *phdrs;

    phdrs = (Elf_Phdr *)malloc(elf_header.e_phnum * sizeof(Elf_Phdr));
    if (phdrs == NULL)
    {
        debug_printf("Out of memory\n");
        return 0;
    }

    if (get_filedata(phdrs, elf_header.e_phoff, elf_header.e_phentsize, elf_header.e_phnum) != NULL)
    {
        program_headers = phdrs;
        return 1;
    }

    free(phdrs);
    return 0;
}

void *get_filedata(void *var, long offset, size_t size, size_t nmemb)
{
    void *mvar;

    if (size == 0 || nmemb == 0)
        return NULL;

    mvar = var;
    if (mvar == NULL)
    {
        mvar = malloc(size * nmemb + 1);
        if (mvar == NULL)
            return NULL;
        ((char *)mvar)[size * nmemb] = '\0';
    }

    if (ramdisk_read(mvar, offset, size*nmemb) != size*nmemb)
    {
        if (mvar != var)
            free(mvar);
        return NULL;
    }

    return mvar;
}

static uintptr_t loader(PCB *pcb, const char *filename) {
  if(!init_elf())
    return 0;
  Elf_Phdr *phdr = program_headers;
  for (size_t i = 0; i < elf_header.e_phnum; i++, phdr++)
  {
    if(phdr->p_type == PT_LOAD){
      ramdisk_read((void *)phdr->p_vaddr, phdr->p_offset, phdr->p_filesz);
      printf("Offset            VirtAddr           FileSiz      MemSiz      \n");
      printf("%lX  %lX  %lX  %lX  \n", phdr->p_offset, phdr->p_vaddr, phdr->p_filesz, phdr->p_memsz);
      memset((uint8_t *)phdr->p_vaddr + phdr->p_filesz, 0, phdr->p_memsz - phdr->p_filesz);
    }
  }
  free(program_headers);
  return 0x83000000;
}

void naive_uload(PCB *pcb, const char *filename) {
  uintptr_t entry = loader(pcb, filename);
  Log("Jump to entry = %p", entry);
  ((void(*)())entry) ();
}

