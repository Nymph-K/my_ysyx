#ifndef _ELF_PARS_H
#define _ELF_PARS_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <elf.h>

#define BYTE_GET(field)  byte_get_little_endian (field,sizeof(field))

#define SHT_PARISC_ANNOT    0x70000003
#define SHT_PARISC_SYMEXTN    SHT_LOPROC + 8
#define SHT_PARISC_STUBS      SHT_LOPROC + 9
#define SHT_PARISC_DLKM        0x70000004

#define PT_PARISC_WEAKORDER    0x70000002
#define PT_HP_CORE_UTSNAME    (PT_LOOS + 0x15)

#define SHT_IA_64_PRIORITY_INIT (SHT_LOPROC + 0x9000000)
#define SHT_IA_64_VMS_TRACE             0x60000000
#define SHT_IA_64_VMS_TIE_SIGNATURES    0x60000001
#define SHT_IA_64_VMS_DEBUG             0x60000002
#define SHT_IA_64_VMS_DEBUG_STR         0x60000003
#define SHT_IA_64_VMS_LINKAGES          0x60000004
#define SHT_IA_64_VMS_SYMBOL_VECTOR     0x60000005
#define SHT_IA_64_VMS_FIXUP             0x60000006
#define SHT_IA_64_LOPSREG    (SHT_LOPROC + 0x8000000)



#define EM_L1OM        180    /* Intel L1OM */
#define EM_K1OM        181    /* Intel K1OM */
#define EM_TI_C6000    140    /* Texas Instruments TMS320C6000 DSP family */
#define EM_MSP430    105    /* TI msp430 micro controller */


#define SHT_ARM_DEBUGOVERLAY   0x70000004    /* Section holds overlay debug info.  */
#define SHT_ARM_OVERLAYSECTION 0x70000005    /* Section holds GDB and overlay integration info.  */

#define SHT_X86_64_UNWIND    0x70000001    /* unwind information */


#define SHT_AARCH64_ATTRIBUTES    0x70000003  /* Section holds attributes.  */

#define SHT_C6000_UNWIND    0x70000001
#define SHT_C6000_PREEMPTMAP    0x70000002
#define SHT_C6000_ATTRIBUTES    0x70000003
#define SHT_TI_ICODE        0x7F000000
#define SHT_TI_XREF        0x7F000001
#define SHT_TI_HANDLER        0x7F000002
#define SHT_TI_INITINFO        0x7F000003
#define SHT_TI_PHATTRS        0x7F000004

#define SHT_MSP430_ATTRIBUTES    0x70000003    /* Section holds ABI attributes.  */
#define SHT_MSP430_SEC_FLAGS    0x7f000005    /* Holds TI compiler's section flags.  */
#define SHT_MSP430_SYM_ALIASES    0x7f000006    /* Holds TI compiler's symbol aliases.  */

#define PT_AARCH64_ARCHEXT    (PT_LOPROC + 0)


/* ELF Header (32-bit implementations) */

typedef struct {
    unsigned char    e_ident[16];        /* ELF "magic number" */
    unsigned char    e_type[2];        /* Identifies object file type */
    unsigned char    e_machine[2];        /* Specifies required architecture */
    unsigned char    e_version[4];        /* Identifies object file version */
    unsigned char    e_entry[4];        /* Entry point virtual address */
    unsigned char    e_phoff[4];        /* Program header table file offset */
    unsigned char    e_shoff[4];        /* Section header table file offset */
    unsigned char    e_flags[4];        /* Processor-specific flags */
    unsigned char    e_ehsize[2];        /* ELF header size in bytes */
    unsigned char    e_phentsize[2];        /* Program header table entry size */
    unsigned char    e_phnum[2];        /* Program header table entry count */
    unsigned char    e_shentsize[2];        /* Section header table entry size */
    unsigned char    e_shnum[2];        /* Section header table entry count */
    unsigned char    e_shstrndx[2];        /* Section header string table index */
} Elf32_External_Ehdr;

typedef struct {
    unsigned char    e_ident[16];        /* ELF "magic number" */
    unsigned char    e_type[2];        /* Identifies object file type */
    unsigned char    e_machine[2];        /* Specifies required architecture */
    unsigned char    e_version[4];        /* Identifies object file version */
    unsigned char    e_entry[8];        /* Entry point virtual address */
    unsigned char    e_phoff[8];        /* Program header table file offset */
    unsigned char    e_shoff[8];        /* Section header table file offset */
    unsigned char    e_flags[4];        /* Processor-specific flags */
    unsigned char    e_ehsize[2];        /* ELF header size in bytes */
    unsigned char    e_phentsize[2];        /* Program header table entry size */
    unsigned char    e_phnum[2];        /* Program header table entry count */
    unsigned char    e_shentsize[2];        /* Section header table entry size */
    unsigned char    e_shnum[2];        /* Section header table entry count */
    unsigned char    e_shstrndx[2];        /* Section header string table index */
} Elf64_External_Ehdr;

/* Section header */

typedef struct {
    unsigned char    sh_name[4];        /* Section name, index in string tbl */
    unsigned char    sh_type[4];        /* Type of section */
    unsigned char    sh_flags[4];        /* Miscellaneous section attributes */
    unsigned char    sh_addr[4];        /* Section virtual addr at execution */
    unsigned char    sh_offset[4];        /* Section file offset */
    unsigned char    sh_size[4];        /* Size of section in bytes */
    unsigned char    sh_link[4];        /* Index of another section */
    unsigned char    sh_info[4];        /* Additional section information */
    unsigned char    sh_addralign[4];    /* Section alignment */
    unsigned char    sh_entsize[4];        /* Entry size if section holds table */
} Elf32_External_Shdr;

typedef struct {
    unsigned char    sh_name[4];        /* Section name, index in string tbl */
    unsigned char    sh_type[4];        /* Type of section */
    unsigned char    sh_flags[8];        /* Miscellaneous section attributes */
    unsigned char    sh_addr[8];        /* Section virtual addr at execution */
    unsigned char    sh_offset[8];        /* Section file offset */
    unsigned char    sh_size[8];        /* Size of section in bytes */
    unsigned char    sh_link[4];        /* Index of another section */
    unsigned char    sh_info[4];        /* Additional section information */
    unsigned char    sh_addralign[8];    /* Section alignment */
    unsigned char    sh_entsize[8];        /* Entry size if section holds table */
} Elf64_External_Shdr;

/* Program header */

typedef struct {
    unsigned char    p_type[4];        /* Identifies program segment type */
    unsigned char    p_offset[4];        /* Segment file offset */
    unsigned char    p_vaddr[4];        /* Segment virtual address */
    unsigned char    p_paddr[4];        /* Segment physical address */
    unsigned char    p_filesz[4];        /* Segment size in file */
    unsigned char    p_memsz[4];        /* Segment size in memory */
    unsigned char    p_flags[4];        /* Segment flags */
    unsigned char    p_align[4];        /* Segment alignment, file & memory */
} Elf32_External_Phdr;

typedef struct {
    unsigned char    p_type[4];        /* Identifies program segment type */
    unsigned char    p_flags[4];        /* Segment flags */
    unsigned char    p_offset[8];        /* Segment file offset */
    unsigned char    p_vaddr[8];        /* Segment virtual address */
    unsigned char    p_paddr[8];        /* Segment physical address */
    unsigned char    p_filesz[8];        /* Segment size in file */
    unsigned char    p_memsz[8];        /* Segment size in memory */
    unsigned char    p_align[8];        /* Segment alignment, file & memory */
} Elf64_External_Phdr;





/* dynamic section structure */

typedef struct {
    unsigned char    d_tag[4];        /* entry tag value */
    union {
        unsigned char    d_val[4];
        unsigned char    d_ptr[4];
    } d_un;
} Elf32_External_Dyn;

typedef struct {
    unsigned char    d_tag[8];        /* entry tag value */
    union {
        unsigned char    d_val[8];
        unsigned char    d_ptr[8];
    } d_un;
} Elf64_External_Dyn;



/* Relocation Entries */
typedef struct {
    unsigned char r_offset[4];    /* Location at which to apply the action */
    unsigned char    r_info[4];    /* index and type of relocation */
} Elf32_External_Rel;

typedef struct {
    unsigned char r_offset[4];    /* Location at which to apply the action */
    unsigned char    r_info[4];    /* index and type of relocation */
    unsigned char    r_addend[4];    /* Constant addend used to compute value */
} Elf32_External_Rela;

typedef struct {
    unsigned char r_offset[8];    /* Location at which to apply the action */
    unsigned char    r_info[8];    /* index and type of relocation */
} Elf64_External_Rel;

typedef struct {
    unsigned char r_offset[8];    /* Location at which to apply the action */
    unsigned char    r_info[8];    /* index and type of relocation */
    unsigned char    r_addend[8];    /* Constant addend used to compute value */
} Elf64_External_Rela;





/* Symbol table entry */

typedef struct {
    unsigned char    st_name[4];        /* Symbol name, index in string tbl */
    unsigned char    st_value[4];        /* Value of the symbol */
    unsigned char    st_size[4];        /* Associated symbol size */
    unsigned char    st_info[1];        /* Type and binding attributes */
    unsigned char    st_other[1];        /* No defined meaning, 0 */
    unsigned char    st_shndx[2];        /* Associated section index */
} Elf32_External_Sym;

typedef struct {
    unsigned char    st_name[4];        /* Symbol name, index in string tbl */
    unsigned char    st_info[1];        /* Type and binding attributes */
    unsigned char    st_other[1];        /* No defined meaning, 0 */
    unsigned char    st_shndx[2];        /* Associated section index */
    unsigned char    st_value[8];        /* Value of the symbol */
    unsigned char    st_size[8];        /* Associated symbol size */
} Elf64_External_Sym;


int init_elf(char const *file_name);

void* get_data(void * var, FILE * file, long offset, size_t size, size_t nmemb,
                const char * reason);
void *cmalloc (size_t nmemb, size_t size);
//int get_32bit_section_headers (FILE * file, unsigned int num);
int get_64bit_section_headers(FILE *file, unsigned int num);
int  get_file_header(FILE *file);

int  process_file_header();
const char*  get_elf_class (unsigned int elf_class);
const char * get_data_encoding (unsigned int encoding);
const char * get_osabi_name (unsigned int osabi);
const char *get_file_type (unsigned e_type);
const char *get_machine_name (unsigned e_machine);

int   process_section_headers (FILE * file);
const char *get_section_type_name (unsigned int sh_type);
const char *get_mips_section_type_name (unsigned int sh_type);
const char *get_parisc_section_type_name (unsigned int sh_type);
const char *get_ia64_section_type_name (unsigned int sh_type);
const char *get_x86_64_section_type_name (unsigned int sh_type);
const char *get_aarch64_section_type_name (unsigned int sh_type);
const char *get_arm_section_type_name (unsigned int sh_type);
const char *get_tic6x_section_type_name (unsigned int sh_type);
const char *get_msp430x_section_type_name (unsigned int sh_type);

int  process_program_headers (FILE * file);
const char *get_segment_type (unsigned int p_type);
const char *get_aarch64_segment_type (unsigned long type);
const char *get_arm_segment_type (unsigned long type);
const char *get_mips_segment_type (unsigned long type);
const char *get_parisc_segment_type (unsigned long type);
const char *get_ia64_segment_type (unsigned long type);
const char *get_tic6x_segment_type (unsigned long type);
int get_program_headers (FILE * file);
//int get_32bit_program_headers (FILE * file, Elf32_Phdr * pheaders);
int get_64bit_program_headers (FILE * file, Elf64_Phdr * pheaders);
int process_dynamic_section (FILE * file);
//int get_32bit_dynamic_section (FILE * file);
int get_64bit_dynamic_section(FILE * file);
void print_dynamic_flags (Elf64_Word flags);
const char *get_dynamic_type (unsigned long type);
int process_relocs (FILE * file);
//void get_32bit_rel(FILE *pFILE, unsigned int offset);
void get_64bit_rel(FILE *pFILE, unsigned int offset);
int  Process_object(FILE *file);
void process_symbol_table(FILE *pFILE);
void get_64bit_symbol_dyn(FILE *pFILE);
void get_64bit_symbol_tbl(FILE *pFILE);
void get_64bit_symbol_func(void);
// void get_64bit_strdyn(FILE *pFILE, Elf64_Word name);
// void get_64bit_strtbl(FILE *pFILE, Elf64_Word name);
char *get_64bit_strdyn(Elf64_Word name);
char *get_64bit_strtbl(Elf64_Word name);
void process_string_table(FILE *pFILE);
int is_func_start(Elf64_Addr addr);
int get_func_ndx(Elf64_Addr addr);
char *get_func_name(Elf64_Addr addr);
char *get_func_name_ndx(int i);
void free_all(void);
void free_useless(void);

#endif /* _ELF_PARS_H*/