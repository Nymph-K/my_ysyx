#ifndef _ELF_PARS_H
#define _ELF_PARS_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <elf.h>

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