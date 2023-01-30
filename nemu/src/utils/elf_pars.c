#include <elf_pars.h>

#define DEUBG_PRINTF 0
#if DEUBG_PRINTF
#define debug_printf(format, ...) printf(format, ##__VA_ARGS__)
#else
#define debug_printf(format, ...)
#endif // DEUBG_PRINTF

static int is_64bit_elf;
Elf64_Ehdr elf_header;
Elf64_Dyn *dynamic_section = NULL;
Elf64_Shdr *section_headers = NULL;
Elf64_Phdr *program_headers = NULL;
Elf64_Sym *sym_dyn = NULL;
Elf64_Sym *sym_tbl = NULL;
Elf64_Sym *sym_func = NULL;
unsigned int sym_func_num;
char *str_dyn = NULL;
char *str_tbl = NULL;

static unsigned int dynamic_addr = 0;
//static unsigned int dynamic_offset;
unsigned int dynamic_strings = 0;
unsigned int dynamic_size = 0;

static unsigned int rel_dyn_offset;
static unsigned int rel_dyn_size;
static unsigned int rel_nent;

static unsigned int sym_dyn_offset = 0;
static unsigned int sym_dyn_size = 0;
unsigned int sym_dyn_nent = 0;
static unsigned int sym_tbl_offset = 0;
static unsigned int sym_tbl_size = 0;
unsigned int sym_tbl_nent = 0;

static unsigned int str_dyn_offset = 0;
static unsigned int str_dyn_size = 0;
static unsigned int str_tbl_offset = 0;
static unsigned int str_tbl_size = 0;

static unsigned int dynamic_nent;

int init_elf(char const *file_name)
{
    if (file_name == NULL)
    {
        debug_printf("No Elf file: %s\n", file_name);
        return -1;
    }
    FILE *read_elf = fopen(file_name, "rb");
    Process_object(read_elf);
    fclose(read_elf);
    free_useless();
    return 0;
}

int byte_get_little_endian(unsigned char *field, int size)
{

    switch (size)
    {
    case 1:
        return *field;
    case 2:
        return ((unsigned int)(field[0])) | (((unsigned int)(field[1])) << 8);
    case 3:
        return ((unsigned long)(field[0])) | (((unsigned long)(field[1])) << 8) | (((unsigned long)(field[2])) << 16);

    case 4:
        return ((unsigned long)(field[0])) | (((unsigned long)(field[1])) << 8) | (((unsigned long)(field[2])) << 16) | (((unsigned long)(field[3])) << 24);

    case 8:
        return ((unsigned long)(field[0])) | (((unsigned long)(field[1])) << 8) | (((unsigned long)(field[2])) << 16) | (((unsigned long)(field[3])) << 24) | (((unsigned long)(field[4])) << 32) | (((unsigned long)(field[5])) << 40) | (((unsigned long)(field[6])) << 48) | (((unsigned long)(field[7])) << 56);

    default: return 0;
    }
}

int Process_object(FILE *file)
{

    if (!get_file_header(file))
    {
        debug_printf("gei file header Failed");
        return 0;
    }

    /********* start     process ***********/
    if (!process_file_header())
    {
        return 0;
    }
    if (!process_section_headers(file))
    {
        return 0;
    }
    // if (!process_program_headers(file))
    // {

    //     process_dynamic_section(file);
    // }
    // process_relocs(file);
    process_string_table(file);
    process_symbol_table(file);

    return 0;
}

int get_file_header(FILE *file)
{

    /* Read in the identity array.  */
    if (fread(elf_header.e_ident, EI_NIDENT, 1, file) != 1)
        return 0;

    /* For now we only support 32 bit and 64 bit ELF files.  */
    is_64bit_elf = (elf_header.e_ident[EI_CLASS] == ELFCLASS64);

    /* Read in the rest of the header.  */
    if (is_64bit_elf)
    {

        Elf64_External_Ehdr ehdr64;
        if (fread(ehdr64.e_type, sizeof(ehdr64) - EI_NIDENT, 1, file) != 1)
            return 0;

        elf_header.e_type = BYTE_GET(ehdr64.e_type);
        elf_header.e_machine = BYTE_GET(ehdr64.e_machine);
        elf_header.e_version = BYTE_GET(ehdr64.e_version);
        elf_header.e_entry = BYTE_GET(ehdr64.e_entry);
        elf_header.e_phoff = BYTE_GET(ehdr64.e_phoff);
        elf_header.e_shoff = BYTE_GET(ehdr64.e_shoff);
        elf_header.e_flags = BYTE_GET(ehdr64.e_flags);
        elf_header.e_ehsize = BYTE_GET(ehdr64.e_ehsize);
        elf_header.e_phentsize = BYTE_GET(ehdr64.e_phentsize);
        elf_header.e_phnum = BYTE_GET(ehdr64.e_phnum);
        elf_header.e_shentsize = BYTE_GET(ehdr64.e_shentsize);
        elf_header.e_shnum = BYTE_GET(ehdr64.e_shnum);
        elf_header.e_shstrndx = BYTE_GET(ehdr64.e_shstrndx);

        // if (elf_header.e_shoff)
        // {
        //     if (is_64bit_elf)
        //         get_64bit_section_headers(file, elf_header.e_shnum);
        //     else
        //     {
        //         // 32位 ...
        //     }
        // }
    }
    return 1;
}

// int get_32bit_section_headers(FILE *file, unsigned int num) {

//     Elf32_External_Shdr * shdrs;
//     Elf32_Shdr* internal;

//     shdrs = (Elf32_External_Shdr *) get_data (NULL, file, elf_header.e_shoff,
//                                               elf_header.e_shentsize, num,
//                                               ("section headers"));
//     if (!shdrs)
//         return 0;

//     section_headers = (Elf32_Shdr *) cmalloc (num,sizeof (Elf32_Shdr));

//     if (section_headers == NULL)
//     {
//         debug_printf("Out of memory\n");
//         return 0;
//     }

//     internal = section_headers;

//     for (int i = 0;i < num;i++, internal++)
//     {
//         internal->sh_name      = BYTE_GET (shdrs[i].sh_name);
//         internal->sh_type      = BYTE_GET (shdrs[i].sh_type);
//         internal->sh_flags     = BYTE_GET (shdrs[i].sh_flags);
//         internal->sh_addr      = BYTE_GET (shdrs[i].sh_addr);
//         internal->sh_offset    = BYTE_GET (shdrs[i].sh_offset);
//         internal->sh_size      = BYTE_GET (shdrs[i].sh_size);
//         internal->sh_link      = BYTE_GET (shdrs[i].sh_link);
//         internal->sh_info      = BYTE_GET (shdrs[i].sh_info);
//         internal->sh_addralign = BYTE_GET (shdrs[i].sh_addralign);
//         internal->sh_entsize   = BYTE_GET (shdrs[i].sh_entsize);
//     }

//     free (shdrs);

//     return 1;
// }

int get_64bit_section_headers(FILE *file, unsigned int num)
{

    Elf64_External_Shdr *shdrs;
    Elf64_Shdr *internal;

    shdrs = (Elf64_External_Shdr *)get_data(NULL, file, elf_header.e_shoff,
                                            elf_header.e_shentsize, num,
                                            ("section headers"));
    if (!shdrs)
        return 0;

    section_headers = (Elf64_Shdr *)cmalloc(num, sizeof(Elf64_Shdr));

    if (section_headers == NULL)
    {
        debug_printf("Out of memory\n");
        return 0;
    }

    internal = section_headers;

    for (int i = 0; i < num; i++, internal++)
    {
        internal->sh_name = BYTE_GET(shdrs[i].sh_name);
        internal->sh_type = BYTE_GET(shdrs[i].sh_type);
        internal->sh_flags = BYTE_GET(shdrs[i].sh_flags);
        internal->sh_addr = BYTE_GET(shdrs[i].sh_addr);
        internal->sh_offset = BYTE_GET(shdrs[i].sh_offset);
        internal->sh_size = BYTE_GET(shdrs[i].sh_size);
        internal->sh_link = BYTE_GET(shdrs[i].sh_link);
        internal->sh_info = BYTE_GET(shdrs[i].sh_info);
        internal->sh_addralign = BYTE_GET(shdrs[i].sh_addralign);
        internal->sh_entsize = BYTE_GET(shdrs[i].sh_entsize);
    }

    free(shdrs);

    return 1;
}

void *get_data(void *var, FILE *file, long offset, size_t size, size_t nmemb, const char *reason)
{
    void *mvar;

    if (size == 0 || nmemb == 0)
        return NULL;

    if (fseek(file, offset, SEEK_SET))
    {
        // error (_("Unable to seek to 0x%lx for %s\n"),
        //   (unsigned long) archive_file_offset + offset, reason);
        return NULL;
    }

    mvar = var;
    if (mvar == NULL)
    {
        /* Check for overflow.  */
        if (nmemb < (~(size_t)0 - 1) / size)
            /* + 1 so that we can '\0' terminate invalid string table sections.  */
            mvar = malloc(size * nmemb + 1);

        if (mvar == NULL)
        {
            // error (_("Out of memory allocating 0x%lx bytes for %s\n"),
            //(unsigned long)(size * nmemb), reason);
            return NULL;
        }

        ((char *)mvar)[size * nmemb] = '\0';
    }

    if (fread(mvar, size, nmemb, file) != nmemb)
    {
        // error (_("Unable to read in 0x%lx bytes of %s\n"),
        //  (unsigned long)(size * nmemb), reason);
        if (mvar != var)
            free(mvar);
        return NULL;
    }

    return mvar;
}

void *cmalloc(size_t nmemb, size_t size)
{
    /* Check for overflow.  */
    if (nmemb >= ~(size_t)0 / size)
        return NULL;
    else
        return malloc(nmemb * size);
}

int process_file_header(void)
{

    if (elf_header.e_ident[EI_MAG0] != ELFMAG0 || elf_header.e_ident[EI_MAG1] != ELFMAG1 || elf_header.e_ident[EI_MAG2] != ELFMAG2 || elf_header.e_ident[EI_MAG3] != ELFMAG3)
    {
        debug_printf("Not an ELF file - it has the wrong magic bytes at the start\n");
        return 0;
    }

    debug_printf("ELF Header:\n");
    debug_printf("  Magic:     ");
    for (int i = 0; i < EI_NIDENT; ++i)
        debug_printf("%2.2x ", elf_header.e_ident[i]);
    debug_printf("\n");
    debug_printf("  Class:                             %s\n",
                 get_elf_class(elf_header.e_ident[EI_CLASS]));

    debug_printf("  Data:                              %s\n",
                 get_data_encoding(elf_header.e_ident[EI_DATA]));
    debug_printf("  Version:                           %d %s\n",
                 elf_header.e_ident[EI_VERSION],
                 (elf_header.e_ident[EI_VERSION] == EV_CURRENT
                      ? "(current)"
                      : (elf_header.e_ident[EI_VERSION] != EV_NONE
                             ? ("<unknown: %lx>")
                             : "")));
    debug_printf("  OS/ABI:                            %s\n",
                 get_osabi_name(elf_header.e_ident[EI_OSABI]));

    debug_printf("  ABI Version:                       %d\n",
                 elf_header.e_ident[EI_ABIVERSION]);

    debug_printf("  Type:                              %s\n",
                 get_file_type(elf_header.e_type));

    debug_printf("  Machine:                           %s\n",
                 get_machine_name(elf_header.e_machine));

    debug_printf("  Version:                           0x%lx\n",
                 (unsigned long)elf_header.e_version);

    debug_printf("  Entry point address:               0x%lx", elf_header.e_entry);

    debug_printf("\n  Start of program headers:          %ld", elf_header.e_phoff);

    debug_printf(" (bytes into file)\n  Start of section headers:          %ld", elf_header.e_shoff);
    debug_printf(" (bytes into file)\n");

    debug_printf("  Flags:                             0x%lx\n", (unsigned long)elf_header.e_flags);

    debug_printf("  Size of this header:               %ld (bytes)\n", (long)elf_header.e_ehsize);

    debug_printf("  Size of program headers:           %ld (bytes)\n", (long)elf_header.e_phentsize);

    debug_printf("  Number of program headers:         %ld\n", (long)elf_header.e_phnum);

    if (section_headers != NULL && elf_header.e_phnum == PN_XNUM && section_headers[0].sh_info != 0)
        debug_printf(" (%ld)", (long)section_headers[0].sh_info);

    debug_printf("  Size of section headers:           %ld (bytes)\n",
                 (long)elf_header.e_shentsize);

    debug_printf("  Number of section headers:         %ld\n",
                 (long)elf_header.e_shnum);

    if (section_headers != NULL && elf_header.e_shnum == SHN_UNDEF)
        debug_printf(" (%ld)", (long)section_headers[0].sh_size);

    debug_printf("  Section header string table index: %ld\n",
                 (long)elf_header.e_shstrndx);

    if (section_headers != NULL && elf_header.e_shstrndx == (SHN_XINDEX & 0xffff))
        debug_printf(" (%u)", section_headers[0].sh_link);
    else if (elf_header.e_shstrndx != SHN_UNDEF && elf_header.e_shstrndx >= elf_header.e_shnum)
        debug_printf(" <corrupt: out of range>");

    return 1;
}

const char *get_elf_class(unsigned int elf_class)
{
    static char buff[32];

    switch (elf_class)
    {
    case ELFCLASSNONE:
        return ("none");
    case ELFCLASS32:
        return ("ELF32");
    case ELFCLASS64:
        return ("ELF64");
    default:
        snprintf(buff, sizeof(buff), ("<unknown: %x>"), elf_class);
        return buff;
    }
}

const char *get_data_encoding(unsigned int encoding)
{
    static char buff[32];

    switch (encoding)
    {
    case ELFDATANONE:
        return ("none");
    case ELFDATA2LSB:
        return ("2's complement, little endian");
    case ELFDATA2MSB:
        return ("2's complement, big endian");
    default:
        snprintf(buff, sizeof(buff), ("<unknown: %x>"), encoding);
        return buff;
    }
}

const char *get_osabi_name(unsigned int osabi)
{
    static char buff[40];
    switch (osabi)
    {
    case ELFOSABI_NONE:
        return ("UNIX System V ABI");
    case ELFOSABI_HPUX:
        return ("HP-UX");
    case ELFOSABI_NETBSD:
        return ("NetBSD");
    case ELFOSABI_GNU:
        return ("Object uses GNU ELF extensions");
    case ELFOSABI_SOLARIS:
        return ("Sun Solaris");
    case ELFOSABI_AIX:
        return ("IBM AIX");
    case ELFOSABI_IRIX:
        return ("SGI Irix");
    case ELFOSABI_FREEBSD:
        return ("FreeBSD");
    case ELFOSABI_TRU64:
        return ("Compaq TRU64 UNIX");
    case ELFOSABI_MODESTO:
        return ("Novell Modesto");
    case ELFOSABI_OPENBSD:
        return ("OpenBSD");
    case ELFOSABI_ARM_AEABI:
        return ("ARM EABI");
    case ELFOSABI_ARM:
        return ("ARM");
    case ELFOSABI_STANDALONE:
        return ("Standalone (embedded) application");
    default:
        break;
    }

    snprintf(buff, sizeof(buff), ("<unknown: %x>"), osabi);
    return buff;
}

const char *get_file_type(unsigned e_type)
{

    static char buff[32];

    switch (e_type)
    {
    case ET_NONE:
        return ("NONE (None)");
    case ET_REL:
        return ("REL (Relocatable file)");
    case ET_EXEC:
        return ("EXEC (Executable file)");
    case ET_DYN:
        return ("DYN (Shared object file)");
    case ET_CORE:
        return ("CORE (Core file)");

    default:
        if ((e_type >= ET_LOPROC) && (e_type <= ET_HIPROC))
            snprintf(buff, sizeof(buff), ("Processor Specific: (%x)"), e_type);
        else if ((e_type >= ET_LOOS) && (e_type <= ET_HIOS))
            snprintf(buff, sizeof(buff), ("OS Specific: (%x)"), e_type);
        else
            snprintf(buff, sizeof(buff), ("<unknown>: %x"), e_type);
        return buff;
    }
}

const char *get_machine_name(unsigned e_machine)
{

    static char buff[64];

    switch (e_machine)
    {
    case EM_NONE:
        return ("None");
    case EM_AARCH64:
        return ("AArch64");
    case EM_M32:
        return ("WE32100");
    case EM_SPARC:
        return ("Sparc");
    case EM_386:
        return ("Intel 80386");
    case EM_68K:
        return ("MC68000");
    case EM_88K:
        return ("MC88000");
    case EM_860:
        return ("Intel 80860");
    case EM_MIPS:
        return ("MIPS R3000");
    case EM_S370:
        return ("IBM System/370");
    case EM_MIPS_RS3_LE:
        return ("MIPS R4000 big-endian");
    case EM_PARISC:
        return ("HPPA");
    case EM_SPARC32PLUS:
        return ("Sparc v8+");
    case EM_960:
        return ("Intel 90860");
    case EM_PPC:
        return ("PowerPC");
    case EM_PPC64:
        return ("PowerPC64");
    case EM_FR20:
        return ("Fujitsu FR20");
    case EM_RH32:
        return ("TRW RH32");
    case EM_ARM:
        return ("ARM");
    case EM_SH:
        return ("Renesas / SuperH SH");
    case EM_SPARCV9:
        return ("Sparc v9");
    case EM_TRICORE:
        return ("Siemens Tricore");
    case EM_ARC:
        return ("ARC");
    case EM_H8_300:
        return ("Renesas H8/300");
    case EM_H8_300H:
        return ("Renesas H8/300H");
    case EM_H8S:
        return ("Renesas H8S");
    case EM_H8_500:
        return ("Renesas H8/500");
    case EM_IA_64:
        return ("Intel IA-64");
    case EM_MIPS_X:
        return ("Stanford MIPS-X");
    case EM_COLDFIRE:
        return ("Motorola Coldfire");
    case EM_ALPHA:
        return ("Alpha");
    case EM_D10V:
        return ("d10v");
    case EM_D30V:
        return ("d30v");
    case EM_M32R:
        return ("Renesas M32R (formerly Mitsubishi M32r)");
    case EM_V800:
        return ("Renesas V850 (using RH850 ABI)");
    case EM_V850:
        return ("Renesas V850");
    case EM_MN10300:
        return ("mn10300");
    case EM_MN10200:
        return ("mn10200");
    case EM_FR30:
        return ("Fujitsu FR30");
    case EM_PJ:
        return ("picoJava");
    case EM_MMA:
        return ("Fujitsu Multimedia Accelerator");
    case EM_PCP:
        return ("Siemens PCP");
    case EM_NCPU:
        return ("Sony nCPU embedded RISC processor");
    case EM_NDR1:
        return ("Denso NDR1 microprocesspr");
    case EM_STARCORE:
        return ("Motorola Star*Core processor");
    case EM_ME16:
        return ("Toyota ME16 processor");
    case EM_ST100:
        return ("STMicroelectronics ST100 processor");
    case EM_TINYJ:
        return ("Advanced Logic Corp. TinyJ embedded processor");
    case EM_PDSP:
        return ("Sony DSP processor");
    case EM_FX66:
        return ("Siemens FX66 microcontroller");
    case EM_ST9PLUS:
        return ("STMicroelectronics ST9+ 8/16 bit microcontroller");
    case EM_ST7:
        return ("STMicroelectronics ST7 8-bit microcontroller");
    case EM_68HC16:
        return ("Motorola MC68HC16 Microcontroller");
    case EM_68HC12:
        return ("Motorola MC68HC12 Microcontroller");
    case EM_68HC11:
        return ("Motorola MC68HC11 Microcontroller");
    case EM_68HC08:
        return ("Motorola MC68HC08 Microcontroller");
    case EM_68HC05:
        return ("Motorola MC68HC05 Microcontroller");
    case EM_SVX:
        return ("Silicon Graphics SVx");
    case EM_ST19:
        return ("STMicroelectronics ST19 8-bit microcontroller");
    case EM_VAX:
        return ("Digital VAX");
    case EM_AVR:
        return ("Atmel AVR 8-bit microcontroller");
    case EM_CRIS:
        return ("Axis Communications 32-bit embedded processor");
    case EM_JAVELIN:
        return ("Infineon Technologies 32-bit embedded cpu");
    case EM_FIREPATH:
        return ("Element 14 64-bit DSP processor");
    case EM_ZSP:
        return ("LSI Logic's 16-bit DSP processor");
    case EM_MMIX:
        return ("Donald Knuth's educational 64-bit processor");
    case EM_HUANY:
        return ("Harvard Universitys's machine-independent object format");
    case EM_PRISM:
        return ("Vitesse Prism");
    case EM_X86_64:
        return ("Advanced Micro Devices X86-64");
    case EM_S390:
        return ("IBM S/390");
    case EM_OPENRISC:
    case EM_ARC_A5:
        return ("ARC International ARCompact processor");
    case EM_XTENSA:
        return ("Tensilica Xtensa Processor");
    case EM_MICROBLAZE:
    case EM_TILEPRO:
        return ("Tilera TILEPro multicore architecture family");
    case EM_TILEGX:
        return ("Tilera TILE-Gx multicore architecture family");
    default:
        snprintf(buff, sizeof(buff), ("<unknown>: 0x%x"), e_machine);
    }

    return buff;
}

int process_section_headers(FILE *file)
{

    Elf64_Shdr *section;
    section = NULL;

    unsigned int flag_shoff = 0;

    if (elf_header.e_shnum == 0)
    {
        if (elf_header.e_shoff != 0)
            debug_printf("possibly corrupt ELF file header - it has a non-zero section header offset, but no section headers\n");
        else
            debug_printf("\nThere are no sections in this file.\n");
        return 1;
    }

    debug_printf("  There are %d section headers, starting at offset 0x%lx:\n",
                 elf_header.e_shnum, (unsigned long)elf_header.e_shoff);

    if (is_64bit_elf)
    {
        if (!get_64bit_section_headers(file, elf_header.e_shnum))
            return 0;
    }

    /* Read in the string table, so that we have names to display.  */
    if (elf_header.e_shstrndx != SHN_UNDEF && elf_header.e_shstrndx < elf_header.e_shnum)
    {
        section = section_headers + elf_header.e_shstrndx;

        flag_shoff = section->sh_offset;
    }

    if (elf_header.e_shnum > 1)
        debug_printf("\nSection Headers:\n");
    else
        debug_printf("\nSection Header:\n");
    section = section_headers;

    unsigned int countC;
    if (is_64bit_elf)
    {
        debug_printf("  [Nr] Name                Type                        Addr     Off   Size   ES Flg Lk Inf Al\n");
        for (int i = 0;
             i < elf_header.e_shnum;
             i++, section++)
        {
            debug_printf("  [%2u] ", i);

            countC = flag_shoff + section->sh_name;

            fseek(file, countC, SEEK_SET);
            char string_name[20];
            if(fread(string_name, 20, 1, file) != 1) return -1;

            debug_printf("%-18s ", string_name);

            debug_printf(" %-15.15s ",
                         get_section_type_name(section->sh_type));

            debug_printf("%16lx", (unsigned long)section->sh_addr);
            debug_printf(" %07lx %06lx %4lx",
                         (unsigned long)section->sh_offset,
                         (unsigned long)section->sh_size,
                         (unsigned long)section->sh_entsize);

            if (section->sh_flags)
                debug_printf(" %2.2lx ", section->sh_flags);
            else
                debug_printf("%4c", 32);

            debug_printf("%2u ", section->sh_link);
            debug_printf("%3u %3lu", section->sh_info,
                         (unsigned long)section->sh_addralign);

            if (strcmp(string_name, ".dynamic") == 0)
            {
                debug_printf("%s off = %07lx   size = %06lx", string_name, section->sh_offset, section->sh_size);
                dynamic_addr = section->sh_offset;
                dynamic_size = section->sh_size;
            }

            else if (strcmp(string_name, ".rel.dyn") == 0)
            {
                debug_printf("%s off = %07lx   size = %06lx", string_name, section->sh_offset, section->sh_size);
                rel_dyn_offset = section->sh_offset;
                rel_dyn_size = section->sh_size;
            }

            else if (strcmp(string_name, ".dynsym") == 0)
            {
                debug_printf("%s off = %07lx   size = %06lx", string_name, section->sh_offset, section->sh_size);
                sym_dyn_offset = section->sh_offset;
                sym_dyn_size = section->sh_size;
            }

            else if (strcmp(string_name, ".symtab") == 0)
            {
                debug_printf("%s off = %07lx   size = %06lx", string_name, section->sh_offset, section->sh_size);
                sym_tbl_offset = section->sh_offset;
                sym_tbl_size = section->sh_size;
            }

            else if (strcmp(string_name, ".dynstr") == 0)
            {
                debug_printf("%s off = %07lx   size = %06lx", string_name, section->sh_offset, section->sh_size);
                str_dyn_offset = section->sh_offset;
                str_dyn_size = section->sh_size;
            }

            else if (strcmp(string_name, ".strtab") == 0)
            {
                debug_printf("%s off = %07lx   size = %06lx", string_name, section->sh_offset, section->sh_size);
                str_tbl_offset = section->sh_offset;
                str_tbl_size = section->sh_size;
            }

            debug_printf("\n");
        }
    }
    return 1;
}

const char *get_section_type_name(unsigned int sh_type)
{
    static char buff[32];
    switch (sh_type)
    {
    case SHT_NULL:
        return "NULL";
    case SHT_PROGBITS:
        return "PROGBITS";
    case SHT_SYMTAB:
        return "SYMTAB";
    case SHT_STRTAB:
        return "STRTAB";
    case SHT_RELA:
        return "RELA";
    case SHT_HASH:
        return "HASH";
    case SHT_DYNAMIC:
        return "DYNAMIC";
    case SHT_NOTE:
        return "NOTE";
    case SHT_NOBITS:
        return "NOBITS";
    case SHT_REL:
        return "REL";
    case SHT_SHLIB:
        return "SHLIB";
    case SHT_DYNSYM:
        return "DYNSYM";
    case SHT_INIT_ARRAY:
        return "INIT_ARRAY";
    case SHT_FINI_ARRAY:
        return "FINI_ARRAY";
    case SHT_PREINIT_ARRAY:
        return "PREINIT_ARRAY";
    case SHT_GNU_HASH:
        return "GNU_HASH";
    case SHT_GROUP:
        return "GROUP";
    case SHT_SYMTAB_SHNDX:
        return "SYMTAB SECTION INDICIES";
    case SHT_GNU_verdef:
        return "VERDEF";
    case SHT_GNU_verneed:
        return "VERNEED";
    case SHT_GNU_versym:
        return "VERSYM";
    case 0x6ffffff0:
        return "VERSYM";
    case 0x6ffffffc:
        return "VERDEF";
    case 0x7ffffffd:
        return "AUXILIARY";
    case 0x7fffffff:
        return "FILTER";
    case SHT_GNU_LIBLIST:
        return "GNU_LIBLIST";

    default:
        if ((sh_type >= SHT_LOPROC) && (sh_type <= SHT_HIPROC))
        {
            const char *result;

            switch (elf_header.e_machine)
            {

            case EM_MIPS:
            case EM_MIPS_RS3_LE:
                result = get_mips_section_type_name(sh_type);
                break;
            case EM_PARISC:
                result = get_parisc_section_type_name(sh_type);
                break;
            case EM_IA_64:
                result = get_ia64_section_type_name(sh_type);
                break;
            case EM_X86_64:
            case EM_L1OM:
            case EM_K1OM:
                result = get_x86_64_section_type_name(sh_type);
                break;
            case EM_AARCH64:
                result = get_aarch64_section_type_name(sh_type);
                break;
            case EM_ARM:
                result = get_arm_section_type_name(sh_type);
                break;
            case EM_TI_C6000:
                result = get_tic6x_section_type_name(sh_type);
                break;
            case EM_MSP430:
                result = get_msp430x_section_type_name(sh_type);
                break;
            default:
                result = NULL;
                break;
            }
            if (result != NULL)
                return result;
            sprintf(buff, "LOPROC+%x", sh_type - SHT_LOPROC);
        }
        else if ((sh_type >= SHT_LOOS) && (sh_type <= SHT_HIOS))
        {
            const char *result;

            switch (elf_header.e_machine)
            {
            case EM_IA_64:
                result = get_ia64_section_type_name(sh_type);
                break;
            default:
                result = NULL;
                break;
            }

            if (result != NULL)
                return result;

            sprintf(buff, "LOOS+%x", sh_type - SHT_LOOS);
        }
        else if ((sh_type >= SHT_LOUSER) && (sh_type <= SHT_HIUSER))
            sprintf(buff, "LOUSER+%x", sh_type - SHT_LOUSER);
        else
            /* This message is probably going to be displayed in a 15
               character wide field, so put the hex value first.  */
            snprintf(buff, sizeof(buff), ("%08x: <unknown>"), sh_type);

        return buff;
    }
}

const char *get_mips_section_type_name(unsigned int sh_type)
{

    switch (sh_type)
    {
    case SHT_MIPS_LIBLIST:
        return "MIPS_LIBLIST";
    case SHT_MIPS_MSYM:
        return "MIPS_MSYM";
    case SHT_MIPS_CONFLICT:
        return "MIPS_CONFLICT";
    case SHT_MIPS_GPTAB:
        return "MIPS_GPTAB";
    case SHT_MIPS_UCODE:
        return "MIPS_UCODE";
    case SHT_MIPS_DEBUG:
        return "MIPS_DEBUG";
    case SHT_MIPS_REGINFO:
        return "MIPS_REGINFO";
    case SHT_MIPS_PACKAGE:
        return "MIPS_PACKAGE";
    case SHT_MIPS_PACKSYM:
        return "MIPS_PACKSYM";
    case SHT_MIPS_RELD:
        return "MIPS_RELD";
    case SHT_MIPS_IFACE:
        return "MIPS_IFACE";
    case SHT_MIPS_CONTENT:
        return "MIPS_CONTENT";
    case SHT_MIPS_OPTIONS:
        return "MIPS_OPTIONS";
    case SHT_MIPS_SHDR:
        return "MIPS_SHDR";
    case SHT_MIPS_FDESC:
        return "MIPS_FDESC";
    case SHT_MIPS_EXTSYM:
        return "MIPS_EXTSYM";
    case SHT_MIPS_DENSE:
        return "MIPS_DENSE";
    case SHT_MIPS_PDESC:
        return "MIPS_PDESC";
    case SHT_MIPS_LOCSYM:
        return "MIPS_LOCSYM";
    case SHT_MIPS_AUXSYM:
        return "MIPS_AUXSYM";
    case SHT_MIPS_OPTSYM:
        return "MIPS_OPTSYM";
    case SHT_MIPS_LOCSTR:
        return "MIPS_LOCSTR";
    case SHT_MIPS_LINE:
        return "MIPS_LINE";
    case SHT_MIPS_RFDESC:
        return "MIPS_RFDESC";
    case SHT_MIPS_DELTASYM:
        return "MIPS_DELTASYM";
    case SHT_MIPS_DELTAINST:
        return "MIPS_DELTAINST";
    case SHT_MIPS_DELTACLASS:
        return "MIPS_DELTACLASS";
    case SHT_MIPS_DWARF:
        return "MIPS_DWARF";
    case SHT_MIPS_DELTADECL:
        return "MIPS_DELTADECL";
    case SHT_MIPS_SYMBOL_LIB:
        return "MIPS_SYMBOL_LIB";
    case SHT_MIPS_EVENTS:
        return "MIPS_EVENTS";
    case SHT_MIPS_TRANSLATE:
        return "MIPS_TRANSLATE";
    case SHT_MIPS_PIXIE:
        return "MIPS_PIXIE";
    case SHT_MIPS_XLATE:
        return "MIPS_XLATE";
    case SHT_MIPS_XLATE_DEBUG:
        return "MIPS_XLATE_DEBUG";
    case SHT_MIPS_WHIRL:
        return "MIPS_WHIRL";
    case SHT_MIPS_EH_REGION:
        return "MIPS_EH_REGION";
    case SHT_MIPS_XLATE_OLD:
        return "MIPS_XLATE_OLD";
    case SHT_MIPS_PDR_EXCEPTION:
        return "MIPS_PDR_EXCEPTION";
    default:
        break;
    }
    return NULL;
}

const char *get_parisc_section_type_name(unsigned int sh_type)
{

    switch (sh_type)
    {
    case SHT_PARISC_EXT:
        return "PARISC_EXT";
    case SHT_PARISC_UNWIND:
        return "PARISC_UNWIND";
    case SHT_PARISC_DOC:
        return "PARISC_DOC";
    case SHT_PARISC_ANNOT:
        return "PARISC_ANNOT";
    case SHT_PARISC_SYMEXTN:
        return "PARISC_SYMEXTN";
    case SHT_PARISC_STUBS:
        return "PARISC_STUBS";
    case SHT_PARISC_DLKM:
        return "PARISC_DLKM";
    default:
        break;
    }
    return NULL;
}

const char *get_ia64_section_type_name(unsigned int sh_type)
{

    /* If the top 8 bits are 0x78 the next 8 are the os/abi ID.  */
    if ((sh_type & 0xFF000000) == SHT_IA_64_LOPSREG)
        return get_osabi_name((sh_type & 0x00FF0000) >> 16);

    switch (sh_type)
    {
    case SHT_IA_64_EXT:
        return "IA_64_EXT";
    case SHT_IA_64_UNWIND:
        return "IA_64_UNWIND";
    case SHT_IA_64_PRIORITY_INIT:
        return "IA_64_PRIORITY_INIT";
    case SHT_IA_64_VMS_TRACE:
        return "VMS_TRACE";
    case SHT_IA_64_VMS_TIE_SIGNATURES:
        return "VMS_TIE_SIGNATURES";
    case SHT_IA_64_VMS_DEBUG:
        return "VMS_DEBUG";
    case SHT_IA_64_VMS_DEBUG_STR:
        return "VMS_DEBUG_STR";
    case SHT_IA_64_VMS_LINKAGES:
        return "VMS_LINKAGES";
    case SHT_IA_64_VMS_SYMBOL_VECTOR:
        return "VMS_SYMBOL_VECTOR";
    case SHT_IA_64_VMS_FIXUP:
        return "VMS_FIXUP";
    default:
        break;
    }
    return NULL;
}

const char *get_x86_64_section_type_name(unsigned int sh_type)
{

    switch (sh_type)
    {
    case SHT_X86_64_UNWIND:
        return "X86_64_UNWIND";
    default:
        break;
    }
    return NULL;
}

const char *get_aarch64_section_type_name(unsigned int sh_type)
{

    switch (sh_type)
    {
    case SHT_AARCH64_ATTRIBUTES:
        return "AARCH64_ATTRIBUTES";
    default:
        break;
    }
    return NULL;
}

const char *get_arm_section_type_name(unsigned int sh_type)
{

    switch (sh_type)
    {
    case SHT_ARM_EXIDX:
        return "ARM_EXIDX";
    case SHT_ARM_PREEMPTMAP:
        return "ARM_PREEMPTMAP";
    case SHT_ARM_ATTRIBUTES:
        return "ARM_ATTRIBUTES";
    case SHT_ARM_DEBUGOVERLAY:
        return "ARM_DEBUGOVERLAY";
    case SHT_ARM_OVERLAYSECTION:
        return "ARM_OVERLAYSECTION";
    default:
        break;
    }
    return NULL;
}

const char *get_tic6x_section_type_name(unsigned int sh_type)
{

    switch (sh_type)
    {
    case SHT_C6000_UNWIND:
        return "C6000_UNWIND";
    case SHT_C6000_PREEMPTMAP:
        return "C6000_PREEMPTMAP";
    case SHT_C6000_ATTRIBUTES:
        return "C6000_ATTRIBUTES";
    case SHT_TI_ICODE:
        return "TI_ICODE";
    case SHT_TI_XREF:
        return "TI_XREF";
    case SHT_TI_HANDLER:
        return "TI_HANDLER";
    case SHT_TI_INITINFO:
        return "TI_INITINFO";
    case SHT_TI_PHATTRS:
        return "TI_PHATTRS";
    default:
        break;
    }
    return NULL;
}

const char *get_msp430x_section_type_name(unsigned int sh_type)
{

    switch (sh_type)
    {
    case SHT_MSP430_SEC_FLAGS:
        return "MSP430_SEC_FLAGS";
    case SHT_MSP430_SYM_ALIASES:
        return "MSP430_SYM_ALIASES";
    case SHT_MSP430_ATTRIBUTES:
        return "MSP430_ATTRIBUTES";
    default:
        return NULL;
    }
}

const char *get_segment_type(unsigned int p_type)
{

    static char buff[32];

    switch (p_type)
    {
    case PT_NULL:
        return "NULL";
    case PT_LOAD:
        return "LOAD";
    case PT_DYNAMIC:
        return "DYNAMIC";
    case PT_INTERP:
        return "INTERP";
    case PT_NOTE:
        return "NOTE";
    case PT_SHLIB:
        return "SHLIB";
    case PT_PHDR:
        return "PHDR";
    case PT_TLS:
        return "TLS";
    case PT_GNU_EH_FRAME:
        return "GNU_EH_FRAME";
    case PT_GNU_STACK:
        return "GNU_STACK";
    case PT_GNU_RELRO:
        return "GNU_RELRO";

    default:
        if ((p_type >= PT_LOPROC) && (p_type <= PT_HIPROC))
        {
            const char *result;

            switch (elf_header.e_machine)
            {
            case EM_AARCH64:
                result = get_aarch64_segment_type(p_type);
                break;
            case EM_ARM:
                result = get_arm_segment_type(p_type);
                break;
            case EM_MIPS:
            case EM_MIPS_RS3_LE:
                result = get_mips_segment_type(p_type);
                break;
            case EM_PARISC:
                result = get_parisc_segment_type(p_type);
                break;
            case EM_IA_64:
                result = get_ia64_segment_type(p_type);
                break;
            case EM_TI_C6000:
                result = get_tic6x_segment_type(p_type);
                break;
            default:
                result = NULL;
                break;
            }

            if (result != NULL)
                return result;

            sprintf(buff, "LOPROC+%x", p_type - PT_LOPROC);
        }
        else if ((p_type >= PT_LOOS) && (p_type <= PT_HIOS))
        {
            const char *result;

            switch (elf_header.e_machine)
            {
            case EM_PARISC:
                result = get_parisc_segment_type(p_type);
                break;
            case EM_IA_64:
                result = get_ia64_segment_type(p_type);
                break;
            default:
                result = NULL;
                break;
            }

            if (result != NULL)
                return result;

            sprintf(buff, "LOOS+%x", p_type - PT_LOOS);
        }
        else
            snprintf(buff, sizeof(buff), ("<unknown>: %x"), p_type);

        return buff;
    }
}

int process_program_headers(FILE *file)
{

    Elf64_Phdr *segment;
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

        if (is_64bit_elf)
            debug_printf("  Type           Offset   VirtAddr           PhysAddr           FileSiz  MemSiz   Flg Align\n");
        else
            debug_printf("  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align\n");
    }

    if (!get_program_headers(file))
        return 0;

    unsigned int i;
    for (i = 0, segment = program_headers;
         i < elf_header.e_phnum;
         i++, segment++)
    {
        debug_printf("  %-14.14s ", get_segment_type(segment->p_type));

        if (is_64bit_elf)
        {
            debug_printf("0x%6.6x ", (unsigned int)segment->p_offset);
            debug_printf("0x%8.8x ", (unsigned int)segment->p_vaddr);
            debug_printf("0x%8.8x ", (unsigned int)segment->p_paddr);
            debug_printf("0x%5.5x ", (unsigned int)segment->p_filesz);
            debug_printf("0x%5.5x ", (unsigned int)segment->p_memsz);
            debug_printf("%c%c%c ",
                         (segment->p_flags & PF_R ? 'R' : ' '),
                         (segment->p_flags & PF_W ? 'W' : ' '),
                         (segment->p_flags & PF_X ? 'E' : ' '));
            debug_printf("%#x", (unsigned int)segment->p_align);
        }
        debug_printf("\n");
    }
    return 0;
}

const char *get_aarch64_segment_type(unsigned long type)
{

    switch (type)
    {
    case PT_AARCH64_ARCHEXT:
        return "AARCH64_ARCHEXT";
    default:
        break;
    }

    return NULL;
}

const char *get_arm_segment_type(unsigned long type)
{

    switch (type)
    {
    case PT_ARM_EXIDX:
        return "EXIDX";
    default:
        break;
    }

    return NULL;
}

const char *get_mips_segment_type(unsigned long type)
{

    switch (type)
    {
    case PT_MIPS_REGINFO:
        return "REGINFO";
    case PT_MIPS_RTPROC:
        return "RTPROC";
    case PT_MIPS_OPTIONS:
        return "OPTIONS";
    default:
        break;
    }

    return NULL;
}

const char *get_parisc_segment_type(unsigned long type)
{
    switch (type)
    {
    case PT_HP_TLS:
        return "HP_TLS";
    case PT_HP_CORE_NONE:
        return "HP_CORE_NONE";
    case PT_HP_CORE_VERSION:
        return "HP_CORE_VERSION";
    case PT_HP_CORE_KERNEL:
        return "HP_CORE_KERNEL";
    case PT_HP_CORE_COMM:
        return "HP_CORE_COMM";
    case PT_HP_CORE_PROC:
        return "HP_CORE_PROC";
    case PT_HP_CORE_LOADABLE:
        return "HP_CORE_LOADABLE";
    case PT_HP_CORE_STACK:
        return "HP_CORE_STACK";
    case PT_HP_CORE_SHM:
        return "HP_CORE_SHM";
    case PT_HP_CORE_MMF:
        return "HP_CORE_MMF";
    case PT_HP_PARALLEL:
        return "HP_PARALLEL";
    case PT_HP_FASTBIND:
        return "HP_FASTBIND";
    case PT_HP_OPT_ANNOT:
        return "HP_OPT_ANNOT";
    case PT_HP_HSL_ANNOT:
        return "HP_HSL_ANNOT";
    case PT_HP_STACK:
        return "HP_STACK";
    case PT_HP_CORE_UTSNAME:
        return "HP_CORE_UTSNAME";
    case PT_PARISC_ARCHEXT:
        return "PARISC_ARCHEXT";
    case PT_PARISC_UNWIND:
        return "PARISC_UNWIND";
    case PT_PARISC_WEAKORDER:
        return "PARISC_WEAKORDER";
    default:
        break;
    }

    return NULL;
}

const char *get_ia64_segment_type(unsigned long type)
{

    switch (type)
    {
    case PT_IA_64_ARCHEXT:
        return "IA_64_ARCHEXT";
    case PT_IA_64_UNWIND:
        return "IA_64_UNWIND";
    case PT_HP_TLS:
        return "HP_TLS";
    case PT_IA_64_HP_OPT_ANOT:
        return "HP_OPT_ANNOT";
    case PT_IA_64_HP_HSL_ANOT:
        return "HP_HSL_ANNOT";
    case PT_IA_64_HP_STACK:
        return "HP_STACK";
    default:
        break;
    }

    return NULL;
}
#define PT_C6000_PHATTR 0x70000000

const char *get_tic6x_segment_type(unsigned long type)
{
    switch (type)
    {
    case PT_C6000_PHATTR:
        return "C6000_PHATTR";
    default:
        break;
    }

    return NULL;
}

int get_program_headers(FILE *file)
{
    Elf64_Phdr *phdrs64;

    /* Check cache of prior read.  */
    if (program_headers != NULL)
        return 1;

    phdrs64 = (Elf64_Phdr *)cmalloc(elf_header.e_phnum,
                                    sizeof(Elf64_Phdr));

    if (phdrs64 == NULL)
    {
        debug_printf("Out of memory\n");
        return 0;
    }

    if (is_64bit_elf ? get_64bit_program_headers(file, phdrs64) : 0)
    {
        program_headers = phdrs64;
        return 1;
    }

    free(phdrs64);
    return 0;
}

// int get_32bit_program_headers(FILE *file, Elf32_Phdr *pheaders) {

//     Elf32_External_Phdr* phdrs;
//     Elf32_External_Phdr* external;
//     Elf32_Phdr* internal;

//     unsigned int i;

//     phdrs = (Elf32_External_Phdr *) get_data (NULL, file, elf_header.e_phoff,
//                                               elf_header.e_phentsize,
//                                               elf_header.e_phnum,
//                                               ("program headers"));

//     if (!phdrs)
//         return 0;

//     for (i = 0, internal = pheaders, external = phdrs;
//          i < elf_header.e_phnum;
//          i++, internal++, external++){

//         internal->p_type   = BYTE_GET (external->p_type);
//         internal->p_offset = BYTE_GET (external->p_offset);
//         internal->p_vaddr  = BYTE_GET (external->p_vaddr);
//         internal->p_paddr  = BYTE_GET (external->p_paddr);
//         internal->p_filesz = BYTE_GET (external->p_filesz);
//         internal->p_memsz  = BYTE_GET (external->p_memsz);
//         internal->p_flags  = BYTE_GET (external->p_flags);
//         internal->p_align  = BYTE_GET (external->p_align);
//     }
//     free (phdrs);

//     return 1;
// }

int get_64bit_program_headers(FILE *file, Elf64_Phdr *pheaders)
{

    Elf64_External_Phdr *phdrs;
    Elf64_External_Phdr *external;
    Elf64_Phdr *internal;

    unsigned int i;

    phdrs = (Elf64_External_Phdr *)get_data(NULL, file, elf_header.e_phoff,
                                            elf_header.e_phentsize,
                                            elf_header.e_phnum,
                                            ("program headers"));

    if (!phdrs)
        return 0;

    for (i = 0, internal = pheaders, external = phdrs;
         i < elf_header.e_phnum;
         i++, internal++, external++)
    {

        internal->p_type = BYTE_GET(external->p_type);
        internal->p_offset = BYTE_GET(external->p_offset);
        internal->p_vaddr = BYTE_GET(external->p_vaddr);
        internal->p_paddr = BYTE_GET(external->p_paddr);
        internal->p_filesz = BYTE_GET(external->p_filesz);
        internal->p_memsz = BYTE_GET(external->p_memsz);
        internal->p_flags = BYTE_GET(external->p_flags);
        internal->p_align = BYTE_GET(external->p_align);
    }
    free(phdrs);

    return 1;
}

int process_dynamic_section(FILE *file)
{

    Elf64_Dyn *entry;

    if (is_64bit_elf)
    {
        if (!get_64bit_dynamic_section(file))
            return 0;
    }
    // else if (! get_32bit_dynamic_section (file))
    //          return 0;

    if (dynamic_addr)
    {
        debug_printf("\nDynamic section at offset 0x%x contains %u entries:\n",
                     dynamic_addr, dynamic_nent);
        debug_printf("  Tag        Type                         Name/Value\n");
    }

    for (entry = dynamic_section;
         entry < dynamic_section + dynamic_nent;
         entry++)
    {

        //const char *dtype;
        putchar(' ');
        debug_printf("0x%2.8lx ", entry->d_tag);
        //dtype = get_dynamic_type(entry->d_tag);
        //debug_printf("(%s)%*s", dtype, (int)(27 - strlen(dtype)), " ");

        switch (entry->d_tag)
        {
        case DT_FLAGS:
            print_dynamic_flags(entry->d_un.d_val);
            break;

        case DT_AUXILIARY:
        case DT_FILTER:
        case DT_CONFIG:
        case DT_DEPAUDIT:
        case DT_AUDIT:
            switch (entry->d_tag)
            {
            case DT_AUXILIARY:
                debug_printf("Auxiliary library");
                break;

            case DT_FILTER:
                debug_printf("Filter library");
                break;

            case DT_CONFIG:
                debug_printf("Configuration file");
                break;

            case DT_DEPAUDIT:
                debug_printf("Dependency audit library");
                break;

            case DT_AUDIT:
                debug_printf("Audit library");
                break;
            }
            break;

        default:
            debug_printf("0x%lx", entry->d_un.d_val);
        }
        debug_printf("\n");
    }
    return 0;
}

// int get_32bit_dynamic_section(FILE *file) {

//     Elf32_External_Dyn * edyn = (Elf32_External_Dyn *) malloc(dynamic_size);
//     Elf32_External_Dyn * ext;
//     Elf32_Dyn * entry;

//     fseek(file,dynamic_addr,SEEK_SET);
//     if(fread(edyn,dynamic_size,1,file) != 1) return -1;

//     if(edyn==NULL)
//         return 0;

//     for (ext = edyn, dynamic_nent = 0;
//          (char *) ext < (char *) edyn + dynamic_size;
//          ext++)
//     {
//         dynamic_nent++;
//         if (BYTE_GET (ext->d_tag) == DT_NULL)
//             break;
//     }

//     dynamic_section = (Elf32_Dyn *) cmalloc (dynamic_nent,
//                                                     sizeof (* entry));

//     if (dynamic_section == NULL)
//     {
//         debug_printf("Out of memory\n");
//         free (edyn);
//         return 0;
//     }

//     for (ext = edyn, entry = dynamic_section;
//          entry < dynamic_section + dynamic_nent;
//          ext++, entry++)
//     {
//         entry->d_tag      = BYTE_GET (ext->d_tag);
//         entry->d_un.d_val = BYTE_GET (ext->d_un.d_val);
//     }

//     free(edyn);

//     return 1;

// }

int get_64bit_dynamic_section(FILE *file)
{

    Elf64_External_Dyn *edyn = (Elf64_External_Dyn *)malloc(dynamic_size);
    Elf64_External_Dyn *ext;
    Elf64_Dyn *entry;

    fseek(file, dynamic_addr, SEEK_SET);
    if(fread(edyn, dynamic_size, 1, file) != 1) return -1;

    if (edyn == NULL)
        return 0;

    for (ext = edyn, dynamic_nent = 0;
         (char *)ext < (char *)edyn + dynamic_size;
         ext++)
    {
        dynamic_nent++;
        if (BYTE_GET(ext->d_tag) == DT_NULL)
            break;
    }

    dynamic_section = (Elf64_Dyn *)cmalloc(dynamic_nent,
                                           sizeof(*entry));

    if (dynamic_section == NULL)
    {
        debug_printf("Out of memory\n");
        free(edyn);
        return 0;
    }

    for (ext = edyn, entry = dynamic_section;
         entry < dynamic_section + dynamic_nent;
         ext++, entry++)
    {
        entry->d_tag = BYTE_GET(ext->d_tag);
        entry->d_un.d_val = BYTE_GET(ext->d_un.d_val);
    }

    free(edyn);

    return 1;
}

void print_dynamic_flags(Elf64_Word flags)
{

    int first = 1;

    while (flags)
    {
        Elf64_Word flag;

        flag = flags & -flags;
        flags &= ~flag;

        if (first)
            first = 0;
        else
            putc(' ', stdout);

        switch (flag)
        {
        case DF_ORIGIN:
            fputs("ORIGIN", stdout);
            break;
        case DF_SYMBOLIC:
            fputs("SYMBOLIC", stdout);
            break;
        case DF_TEXTREL:
            fputs("TEXTREL", stdout);
            break;
        case DF_BIND_NOW:
            fputs("BIND_NOW", stdout);
            break;
        case DF_STATIC_TLS:
            fputs("STATIC_TLS", stdout);
            break;
        default:
            fputs(("unknown"), stdout);
            break;
        }
    }
}

#define DT_FEATURE 0x6ffffdfc
#define DT_USED 0x7ffffffe
const char *get_dynamic_type(unsigned long type)
{
    switch (type)
    {

    case DT_NULL:
        return "NULL";
    case DT_NEEDED:
        return "NEEDED";
    case DT_PLTRELSZ:
        return "PLTRELSZ";
    case DT_PLTGOT:
        return "PLTGOT";
    case DT_HASH:
        return "HASH";
    case DT_STRTAB:
        return "STRTAB";
    case DT_SYMTAB:
        return "SYMTAB";
    case DT_RELA:
        return "RELA";
    case DT_RELASZ:
        return "RELASZ";
    case DT_RELAENT:
        return "RELAENT";
    case DT_STRSZ:
        return "STRSZ";
    case DT_SYMENT:
        return "SYMENT";
    case DT_INIT:
        return "INIT";
    case DT_FINI:
        return "FINI";
    case DT_SONAME:
        return "SONAME";
    case DT_RPATH:
        return "RPATH";
    case DT_SYMBOLIC:
        return "SYMBOLIC";
    case DT_REL:
        return "REL";
    case DT_RELSZ:
        return "RELSZ";
    case DT_RELENT:
        return "RELENT";
    case DT_PLTREL:
        return "PLTREL";
    case DT_DEBUG:
        return "DEBUG";
    case DT_TEXTREL:
        return "TEXTREL";
    case DT_JMPREL:
        return "JMPREL";
    case DT_BIND_NOW:
        return "BIND_NOW";
    case DT_INIT_ARRAY:
        return "INIT_ARRAY";
    case DT_FINI_ARRAY:
        return "FINI_ARRAY";
    case DT_INIT_ARRAYSZ:
        return "INIT_ARRAYSZ";
    case DT_FINI_ARRAYSZ:
        return "FINI_ARRAYSZ";
    case DT_RUNPATH:
        return "RUNPATH";
    case DT_FLAGS:
        return "FLAGS";

    case DT_PREINIT_ARRAY:
        return "PREINIT_ARRAY";
    case DT_PREINIT_ARRAYSZ:
        return "PREINIT_ARRAYSZ";

    case DT_CHECKSUM:
        return "CHECKSUM";
    case DT_PLTPADSZ:
        return "PLTPADSZ";
    case DT_MOVEENT:
        return "MOVEENT";
    case DT_MOVESZ:
        return "MOVESZ";
    case DT_FEATURE:
        return "FEATURE";
    case DT_POSFLAG_1:
        return "POSFLAG_1";
    case DT_SYMINSZ:
        return "SYMINSZ";
    case DT_SYMINENT:
        return "SYMINENT"; /* aka VALRNGHI */

    case DT_ADDRRNGLO:
        return "ADDRRNGLO";
    case DT_CONFIG:
        return "CONFIG";
    case DT_DEPAUDIT:
        return "DEPAUDIT";
    case DT_AUDIT:
        return "AUDIT";
    case DT_PLTPAD:
        return "PLTPAD";
    case DT_MOVETAB:
        return "MOVETAB";
    case DT_SYMINFO:
        return "SYMINFO"; /* aka ADDRRNGHI */

    case DT_VERSYM:
        return "VERSYM";

    case DT_TLSDESC_GOT:
        return "TLSDESC_GOT";
    case DT_TLSDESC_PLT:
        return "TLSDESC_PLT";
    case DT_RELACOUNT:
        return "RELACOUNT";
    case DT_RELCOUNT:
        return "RELCOUNT";
    case DT_FLAGS_1:
        return "FLAGS_1";
    case DT_VERDEF:
        return "VERDEF";
    case DT_VERDEFNUM:
        return "VERDEFNUM";
    case DT_VERNEED:
        return "VERNEED";
    case DT_VERNEEDNUM:
        return "VERNEEDNUM";

    case DT_AUXILIARY:
        return "AUXILIARY";
    case DT_USED:
        return "USED";
    case DT_FILTER:
        return "FILTER";

    case DT_GNU_PRELINKED:
        return "GNU_PRELINKED";
    case DT_GNU_CONFLICT:
        return "GNU_CONFLICT";
    case DT_GNU_CONFLICTSZ:
        return "GNU_CONFLICTSZ";
    case DT_GNU_LIBLIST:
        return "GNU_LIBLIST";
    case DT_GNU_LIBLISTSZ:
        return "GNU_LIBLISTSZ";
    case DT_GNU_HASH:
        return "GNU_HASH";
    }

    return NULL;
}

#define ARRAY_SIZE(a) (sizeof(a) / sizeof((a)[0]))
#define FALSE 0
#define TRUE 1
#define UNKNOWN -1
// static struct
// {
//     const char *name;
//     int reloc;
//     int size;
//     int rela;
// } dynamic_relocations[] =
//     {
//         {"REL", DT_REL, DT_RELSZ, FALSE},
//         {"RELA", DT_RELA, DT_RELASZ, TRUE},
//         {"PLT", DT_JMPREL, DT_PLTRELSZ, UNKNOWN}};

Elf64_Rel *elf64_rel;
Elf32_Rel *elf32_rel;
int process_relocs(FILE *file)
{
    Elf64_Rel *entry_rel;

    if (is_64bit_elf)
    {
        get_64bit_rel(file, rel_dyn_offset);
    }
    // else{
    //     get_32bit_rel(file,rel_dyn_offset);
    // }
    debug_printf("\nRelocation section at offset 0x%2.2x contains %u entries:\n",
                 rel_dyn_offset, rel_nent);
    debug_printf("  Offset          Info           Type           Sym. Value    Sym. Name\n");
    for (entry_rel = elf64_rel;
         entry_rel < elf64_rel + rel_nent;
         entry_rel++)
    {
        debug_printf("%10.8lx ", entry_rel->r_offset);
        debug_printf("%15.8lx\n", entry_rel->r_info);
    }
    return 0;
}

// void get_32bit_rel(FILE *pFILE, unsigned int offset) {

//     Elf32_External_Rel* rel= (Elf32_External_Rel *) malloc(rel_dyn_size);
//     Elf32_External_Rel* ext;
//     Elf32_Rel* relt;

//     fseek(pFILE,offset,SEEK_SET);
//     if(fread(rel,rel_dyn_size,1,pFILE) != 1) return -1;

//     if(rel==NULL)
//         return;

//     for (ext = rel, rel_nent = 0;
//          (char *) ext < (char *) rel + rel_dyn_size;
//          ext++)
//     {
//         rel_nent++;
//         if (BYTE_GET (rel->r_offset) == DT_NULL)
//             break;
//     }

//     elf32_rel = (Elf32_Rel *) cmalloc (dynamic_nent,
//                                        sizeof (* relt));

//     for (ext = rel, relt = elf32_rel;
//          relt < elf32_rel + rel_nent;
//          ext++, relt++)
//     {
//         relt->r_offset     = BYTE_GET (ext->r_offset);
//         relt->r_info       = BYTE_GET (ext->r_info);
//     }

//     free(rel);

//     return;
// }

void get_64bit_rel(FILE *pFILE, unsigned int offset)
{

    Elf64_External_Rel *rel = (Elf64_External_Rel *)malloc(rel_dyn_size);
    Elf64_External_Rel *ext;
    Elf64_Rel *relt;

    fseek(pFILE, offset, SEEK_SET);
    if(fread(rel, rel_dyn_size, 1, pFILE) != 1) return ;

    if (rel == NULL)
        return;

    for (ext = rel, rel_nent = 0;
         (char *)ext < (char *)rel + rel_dyn_size;
         ext++)
    {
        rel_nent++;
        if (BYTE_GET(rel->r_offset) == DT_NULL)
            break;
    }

    elf64_rel = (Elf64_Rel *)cmalloc(dynamic_nent,
                                     sizeof(*relt));

    for (ext = rel, relt = elf64_rel;
         relt < elf64_rel + rel_nent;
         ext++, relt++)
    {
        relt->r_offset = BYTE_GET(ext->r_offset);
        relt->r_info = BYTE_GET(ext->r_info);
    }

    free(rel);

    return;
}

void process_symbol_table(FILE *pFILE)
{

    Elf64_Sym *sym;
    unsigned int i;
    if(sym_dyn_size != 0)
    {
        get_64bit_symbol_dyn(pFILE);

        debug_printf("\nSymbol table '.dynsym' contains %u entries:\n", sym_dyn_nent);
        debug_printf("Num:    Value          Size   Type Bind   Vis      Ndx Name\n");

        for (i = 0, sym = sym_dyn; i < sym_dyn_nent; sym++, i++)
        {
            debug_printf("%2d: ", i);
            debug_printf("%016lx ", sym->st_value);
            debug_printf("%6ld ", sym->st_size);
            debug_printf("%4x ", sym->st_info & 0x0F);
            debug_printf("%4x ", (sym->st_info & 0xF0) >> 4);
            debug_printf("%7x ", sym->st_other);
            debug_printf("%8x  ", sym->st_shndx);
            get_64bit_strdyn(sym->st_name);
        }
    }

    if(sym_tbl_size != 0)
    {
        get_64bit_symbol_tbl(pFILE);
        debug_printf("\nSymbol table '.symtab' contains %u entries:\n", sym_tbl_nent);
        debug_printf("Num:    Value          Size   Type Bind   Vis      Ndx Name\n");

        for (i = 0, sym = sym_tbl, sym_func_num = 0; i < sym_tbl_nent; sym++, i++)
        {
            if ((sym->st_info & 0x0F) == STT_FUNC)
            {
                sym_func_num++;
            }

            debug_printf("%2d: ", i);
            debug_printf("%016lx ", sym->st_value);
            debug_printf("%6ld ", sym->st_size);
            debug_printf("%4x ", sym->st_info & 0x0F);
            debug_printf("%4x ", (sym->st_info & 0xF0) >> 4);
            debug_printf("%7x ", sym->st_other);
            debug_printf("%8x  ", sym->st_shndx);
            get_64bit_strtbl(sym->st_name);
        }
    }

    if(sym_func_num != 0)
    {
        get_64bit_symbol_func();
        debug_printf("\nSymbol table FUNCTION contains %u entries:\n", sym_func_num);
        debug_printf("Num:    Value          Size   Type Bind   Vis      Ndx Name\n");

        for (i = 0, sym = sym_func; i < sym_func_num; sym++, i++)
        {
            debug_printf("%2d: ", i);
            debug_printf("%016lx ", sym->st_value);
            debug_printf("%6ld ", sym->st_size);
            debug_printf("%4x ", sym->st_info & 0x0F);
            debug_printf("%4x ", (sym->st_info & 0xF0) >> 4);
            debug_printf("%7x ", sym->st_other);
            debug_printf("%8x  ", sym->st_shndx);
            get_64bit_strtbl(sym->st_name);
        }
    }
}

void get_64bit_symbol_dyn(FILE *pFILE)
{
    if(sym_dyn_size != 0)
    {
        Elf64_External_Sym *exty = (Elf64_External_Sym *)malloc(sym_dyn_size);
        Elf64_External_Sym *ext;
        Elf64_Sym *symbool;

        fseek(pFILE, sym_dyn_offset, SEEK_SET);
        if(fread(exty, sym_dyn_size, 1, pFILE) != 1) {
            free(exty);
            return ;
        }

        if (!exty) {
            free(exty);
            return ;
        }
        for (ext = exty, sym_dyn_nent = 0;
            (char *)ext < (char *)exty + sym_dyn_size;
            ext++)
        {
            sym_dyn_nent++;
        }

        sym_dyn = (Elf64_Sym *)cmalloc(sym_dyn_nent,
                                    sizeof(*exty));

        for (ext = exty, symbool = sym_dyn;
            symbool < sym_dyn + sym_dyn_nent;
            ext++, symbool++)
        {

            symbool->st_name = BYTE_GET(ext->st_name);
            symbool->st_info = BYTE_GET(ext->st_info);
            symbool->st_other = BYTE_GET(ext->st_other);
            symbool->st_shndx = BYTE_GET(ext->st_shndx);
            symbool->st_size = BYTE_GET(ext->st_size);
            symbool->st_value = BYTE_GET(ext->st_value);

            // printf("%2.2x ",sym_dyn->st_name);
        }

        free(exty);
    }

    return;
}

void get_64bit_symbol_tbl(FILE *pFILE)
{
    if(sym_tbl_size != 0)
    {
        Elf64_External_Sym *exty_tbl = (Elf64_External_Sym *)malloc(sym_tbl_size);
        Elf64_External_Sym *ext_tbl;
        Elf64_Sym *symbool_tbl;

        fseek(pFILE, sym_tbl_offset, SEEK_SET);
        if(fread(exty_tbl, sym_tbl_size, 1, pFILE) != 1) return ;

        if (!exty_tbl)
            return;
        for (ext_tbl = exty_tbl, sym_tbl_nent = 0;
            (char *)ext_tbl < (char *)exty_tbl + sym_tbl_size;
            ext_tbl++)
        {
            sym_tbl_nent++;
        }

        sym_tbl = (Elf64_Sym *)cmalloc(sym_tbl_nent,
                                    sizeof(*exty_tbl));

        for (ext_tbl = exty_tbl, symbool_tbl = sym_tbl;
            symbool_tbl < sym_tbl + sym_tbl_nent;
            ext_tbl++, symbool_tbl++)
        {
            symbool_tbl->st_name = BYTE_GET(ext_tbl->st_name);
            symbool_tbl->st_info = BYTE_GET(ext_tbl->st_info);
            symbool_tbl->st_other = BYTE_GET(ext_tbl->st_other);
            symbool_tbl->st_shndx = BYTE_GET(ext_tbl->st_shndx);
            symbool_tbl->st_size = BYTE_GET(ext_tbl->st_size);
            symbool_tbl->st_value = BYTE_GET(ext_tbl->st_value);

            // printf("%2.2x ",sym_tbl->st_name);
        }

        free(exty_tbl);
    }

    return;
}

void get_64bit_symbol_func(void)
{
    if(sym_tbl_size != 0)
    {
        sym_func = (Elf64_Sym *)cmalloc(sym_func_num, sizeof(Elf64_Sym));

        Elf64_Sym *sym = sym_tbl;
        Elf64_Sym *sym_f = sym_func;
        unsigned int i;
        for (i = 0; i < sym_tbl_nent; sym++, i++)
        {
            if ((sym->st_info & 0x0F) == STT_FUNC)
            {
                *sym_f++ = *sym;
            }
        }
    }
}

// void get_64bit_strdyn(FILE *pFILE, Elf64_Word name) {

//     unsigned char sym_name[1024];
//     fseek(pFILE,(str_dyn_offset+name),SEEK_SET);
//     if(fread(sym_name,1024,1,pFILE) != 1) return ;
//     debug_printf("%s\n",sym_name);
// }

// void get_64bit_strtbl(FILE *pFILE, Elf64_Word name) {

//     unsigned char sym_name[1024];
//     fseek(pFILE,(str_tbl_offset+name),SEEK_SET);
//     if(fread(sym_name,1024,1,pFILE) != 1) return ;
//     debug_printf("%s\n",sym_name);
// }
char *get_64bit_strdyn(Elf64_Word name)
{
    if (str_dyn != NULL)
    {
        debug_printf("%s\n", str_dyn + name);
        return str_dyn + name;
    }
    return NULL;
}

char *get_64bit_strtbl(Elf64_Word name)
{
    if (str_tbl != NULL)
    {
        debug_printf("%s\n", str_tbl + name);
        return str_tbl + name;
    }
    return NULL;
}

void process_string_table(FILE *pFILE)
{
    if (str_dyn_size != 0)
    {
        str_dyn = (char *)malloc(str_dyn_size);
        fseek(pFILE, str_dyn_offset, SEEK_SET);
        if(fread(str_dyn, str_dyn_size, 1, pFILE) != 1) 
            debug_printf("str_dyn error: %d\n", __LINE__);
    }
    if (str_tbl_size != 0)
    {
        str_tbl = (char *)malloc(str_tbl_size);
        fseek(pFILE, str_tbl_offset, SEEK_SET);
        if(fread(str_tbl, str_tbl_size, 1, pFILE) != 1) 
            debug_printf("str_tbl error: %d\n", __LINE__);
    }
}

int is_func_start(Elf64_Addr addr)
{
    Elf64_Sym *sym;
    int i;
    for (i = 0, sym = sym_func; i < sym_func_num; sym++, i++)
    {
        if (sym->st_value == addr)
        {
            return i;
        }
    }
    return -1;
}

int get_func_ndx(Elf64_Addr addr)
{
    Elf64_Sym *sym;
    int i;
    for (i = 0, sym = sym_func; i < sym_func_num; sym++, i++)
    {
        if (sym->st_value <= addr && addr <= (sym->st_value + sym->st_size))
        {
            return i;
        }
    }
    return -1;
}

char *get_func_name(Elf64_Addr addr)
{
    Elf64_Sym *sym;
    unsigned int i;
    for (i = 0, sym = sym_func; i < sym_func_num; sym++, i++)
    {
        if (sym->st_value == addr)
        {
            return str_tbl+sym->st_name;
        }
    }
    return NULL;
}

char *get_func_name_ndx(int i)
{
    if (i < 0 || i >= sym_func_num)
    {
        return NULL;
    }
    return str_tbl+sym_func[i].st_name;
}

void free_all(void)
{
    free(section_headers);
    free(program_headers);
    free(sym_dyn);
    free(sym_tbl);
    free(sym_func);
    free(str_dyn);
    free(str_tbl);
    free(dynamic_section);
}

void free_useless(void)
{
    free(section_headers);
    free(program_headers);
    free(sym_dyn);
    free(sym_tbl);
    // free(sym_func);
    free(str_dyn);
    // free(str_tbl);
    free(dynamic_section);
}