#include <elf_pars.h>

#define DEUBG_PRINTF 1
#if DEUBG_PRINTF
#define debug_printf(format, ...) printf(format, ##__VA_ARGS__)
#else
#define debug_printf(format, ...)
#endif // DEUBG_PRINTF

static int num_of_elf = 0;
static int is_64bit_elf;
static Elf64_Ehdr *elf_header;
static Elf64_Shdr **section_headers = NULL;

static Elf64_Sym **sym_tbl = NULL;
static Elf64_Off *sym_tbl_offset = NULL;
static Elf64_Xword *sym_tbl_size = NULL;
static unsigned int *sym_tbl_nent = NULL;
static Elf64_Sym **sym_tbl_func = NULL;
static unsigned int *sym_func_num = NULL;

static char **str_tbl = NULL;
static Elf64_Off *str_tbl_offset = NULL;
static Elf64_Xword *str_tbl_size = NULL;


int init_elf(int file_num, char const *file_name[])
{
    elf_header = malloc(sizeof(Elf64_Ehdr) * file_num);
    section_headers = malloc(sizeof(Elf64_Shdr *) * file_num);
    sym_tbl_offset = malloc(sizeof(Elf64_Off) * file_num);
    sym_tbl_size = malloc(sizeof(Elf64_Xword) * file_num);
    str_tbl_offset = malloc(sizeof(Elf64_Off) * file_num);
    str_tbl_size = malloc(sizeof(Elf64_Xword) * file_num);
    str_tbl = malloc(sizeof(char *) * file_num);

    sym_tbl = malloc(sizeof(Elf64_Sym *) * file_num);
    sym_tbl_nent = malloc(sizeof(unsigned int) * file_num);
    sym_tbl_func = malloc(sizeof(Elf64_Sym *) * file_num);
    sym_func_num = malloc(sizeof(unsigned int) * file_num);
    for (size_t i = 0; i < file_num; i++)
    {
        if (file_name[i] == NULL)
        {
            debug_printf("ERROR! Invalid path!\n");
            continue;
        }
        FILE *read_elf = fopen(file_name[i], "rb");
        if (read_elf == NULL)
        {
            debug_printf("ERROR! open file failed!\n");
            continue;
        }
        if(Process_object(read_elf, num_of_elf)) {
            num_of_elf++;
        }
        else
        {
            free_all(file_num);
            return -1;
        }
        fclose(read_elf);
    }
    free_useless(file_num);
    return 0;
}

int Process_object(FILE *file, int idx_of_elf)
{

    if (!get_file_header(file, idx_of_elf))
    {
        debug_printf("Get file header failed!\n");
        return 0;
    }

    if (!get_64bit_section_headers(file, idx_of_elf))
    {
        debug_printf("Get section header failed!\n");
        return 0;
    }

    if (!process_section_headers(file, idx_of_elf))
    {
        return 0;
    }

    get_string_table(file, idx_of_elf);
    get_symbol_table(file, idx_of_elf);
    process_symbol_table(file, idx_of_elf);

    return 1;
}

int get_file_header(FILE *file, int idx_of_elf)
{

    /* Read in the identity array.  */
    if (fread(elf_header[idx_of_elf].e_ident, EI_NIDENT, 1, file) != 1)
        return 0;

    /* For now we only support 32 bit and 64 bit ELF files.  */
    is_64bit_elf = (elf_header[idx_of_elf].e_ident[EI_CLASS] == ELFCLASS64);

    /* Read in the rest of the header.  */
    if (is_64bit_elf)
    {
        if(fread(elf_header[idx_of_elf].e_ident + EI_NIDENT, sizeof(Elf64_Ehdr) - EI_NIDENT, 1, file) == 1)
            return 1;
        else 
            return 0;
    }
    return 0;
}

int get_64bit_section_headers(FILE *file, int idx_of_elf)
{
    section_headers[idx_of_elf] = malloc(elf_header[idx_of_elf].e_shentsize * elf_header[idx_of_elf].e_shnum);
    section_headers[idx_of_elf] = get_data(section_headers[idx_of_elf], file, elf_header[idx_of_elf].e_shoff,
                                            elf_header[idx_of_elf].e_shentsize, elf_header[idx_of_elf].e_shnum);
    if (!section_headers[idx_of_elf])
    {
        debug_printf("Out of memory\n");
        return 0;
    }
    return 1;
}

void *get_data(void *var, FILE *file, long offset, size_t size, size_t nmemb)
{
    if (size == 0 || nmemb == 0)
        return NULL;
    if (fseek(file, offset, SEEK_SET))
        return NULL;

    void *mvar = var;
    if (mvar == NULL)
    {
        if (nmemb < (~(size_t)0 - 1) / size)
            mvar = malloc(size * nmemb + 1);

        if (mvar == NULL)
        {
            return NULL;
        }
        ((char *)mvar)[size * nmemb] = '\0';
    }
    if (fread(mvar, size, nmemb, file) != nmemb)
    {
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

int process_section_headers(FILE *file, int idx_of_elf)
{

    Elf64_Shdr *section = NULL;

    unsigned int shstrtab_shoff = 0;

    /* Read in the string table, so that we have names to display.  */
    if (elf_header[idx_of_elf].e_shstrndx != SHN_UNDEF && elf_header[idx_of_elf].e_shstrndx < elf_header[idx_of_elf].e_shnum)
    {
        section = section_headers[idx_of_elf] + elf_header[idx_of_elf].e_shstrndx;//section .shstrtab

        shstrtab_shoff = section->sh_offset;
    }

    section = section_headers[idx_of_elf];//section[0]

    unsigned int sh_name_off;
    if (is_64bit_elf)
    {
        for (int i = 0; i < elf_header[idx_of_elf].e_shnum; i++, section++)
        {
            sh_name_off = shstrtab_shoff + section->sh_name;

            fseek(file, sh_name_off, SEEK_SET);
            char string_name[20];
            if(fread(string_name, 20, 1, file) != 1) 
                return 0;

            if (strcmp(string_name, ".symtab") == 0)
            {
                sym_tbl_offset[idx_of_elf] = section->sh_offset;
                sym_tbl_size[idx_of_elf] = section->sh_size;
            }
            else if (strcmp(string_name, ".strtab") == 0)
            {
                str_tbl_offset[idx_of_elf] = section->sh_offset;
                str_tbl_size[idx_of_elf] = section->sh_size;
            }
        }
        return 1;
    }
    return 0;
}

void get_string_table(FILE *pFILE, int idx_of_elf)
{
    if (str_tbl_size[idx_of_elf] != 0)
    {
        str_tbl[idx_of_elf] = (char *)malloc(str_tbl_size[idx_of_elf]);
        fseek(pFILE, str_tbl_offset[idx_of_elf], SEEK_SET);
        if(fread(str_tbl[idx_of_elf], str_tbl_size[idx_of_elf], 1, pFILE) != 1) 
            debug_printf("str_tbl[%d] error: %d\n", idx_of_elf, __LINE__);
    }
}

void process_symbol_table(FILE *pFILE, int idx_of_elf)
{
    Elf64_Sym *sym;
    Elf64_Section i;
    Elf64_Section *idx = malloc(sizeof(Elf64_Section) * sym_tbl_nent[idx_of_elf]);
    Elf64_Section *idx_0 = idx;

    if(sym_tbl_size[idx_of_elf] != 0)
    {
        for (i = 0, sym = sym_tbl[idx_of_elf], sym_func_num[idx_of_elf] = 0; i < sym_tbl_nent[idx_of_elf]; sym++, i++)
        {
            if ((sym->st_info & 0x0F) == STT_FUNC && (sym->st_shndx != SHN_UNDEF))
            {
                sym_func_num[idx_of_elf]++;
                *idx++ = i;
            }
        }
    }
    idx = idx_0;
    if(sym_func_num[idx_of_elf] != 0)
    {
        sym_tbl_func[idx_of_elf] = (Elf64_Sym *)malloc(sym_func_num[idx_of_elf] * sizeof(Elf64_Sym));

        for (i = 0; i < sym_func_num[idx_of_elf]; i++)
        {
            sym_tbl_func[idx_of_elf][i] = sym_tbl[idx_of_elf][idx[i]];
        }
    }
    free(idx_0);
}

void get_symbol_table(FILE *pFILE, int idx_of_elf)
{
    if(sym_tbl_size[idx_of_elf] != 0)
    {
        sym_tbl[idx_of_elf] = (Elf64_Sym *)malloc(sym_tbl_size[idx_of_elf]);
        fseek(pFILE, sym_tbl_offset[idx_of_elf], SEEK_SET);
        if(fread(sym_tbl[idx_of_elf], sym_tbl_size[idx_of_elf], 1, pFILE) != 1) 
            return;

        if (!sym_tbl[idx_of_elf])
            return;

        sym_tbl_nent[idx_of_elf] = sym_tbl_size[idx_of_elf] / sizeof(Elf64_Sym);
    }
}

void free_all(int file_num)
{
    free(elf_header);
    free(sym_tbl_offset);
    free(sym_tbl_size);
    free(str_tbl_offset);
    free(str_tbl_size);
    free(sym_func_num);
    free(sym_tbl_nent);
    for (int idx_of_elf = 0; idx_of_elf < file_num; idx_of_elf++)
    {
        free(section_headers[idx_of_elf]);
        free(str_tbl[idx_of_elf]);
        free(sym_tbl[idx_of_elf]);
        free(sym_tbl_func[idx_of_elf]);
    }
    free(section_headers);
    free(str_tbl);
    free(sym_tbl);
    free(sym_tbl_func);
}

void free_useless(int file_num)
{
    free(elf_header);
    free(sym_tbl_offset);
    free(sym_tbl_size);
    free(str_tbl_offset);
    free(str_tbl_size);
    //free(sym_func_num);
    free(sym_tbl_nent);
    for (int idx_of_elf = 0; idx_of_elf < file_num; idx_of_elf++)
    {
        free(section_headers[idx_of_elf]);
        //free(str_tbl[idx_of_elf]);
        free(sym_tbl[idx_of_elf]);
        //free(sym_tbl_func[idx_of_elf]);
    }
    free(section_headers);
    //free(str_tbl);
    free(sym_tbl);
    //free(sym_tbl_func);
}

void get_64bit_symbol_func_tbl(int idx_of_elf)
{
    if(sym_tbl_size[idx_of_elf] != 0)
    {
        sym_tbl_func[idx_of_elf] = (Elf64_Sym *)cmalloc(sym_func_num[idx_of_elf], sizeof(Elf64_Sym));

        Elf64_Sym *sym = sym_tbl[idx_of_elf];
        Elf64_Sym *sym_f = sym_tbl_func[idx_of_elf];
        unsigned int i;
        for (i = 0; i < sym_tbl_nent[idx_of_elf]; sym++, i++)
        {
            if ((sym->st_info & 0x0F) == STT_FUNC && (sym->st_shndx != SHN_UNDEF))
            {
                *sym_f++ = *sym;
            }
        }
    }
}

char *get_64bit_strtbl(Elf64_Word name, int idx_of_elf)
{
    if (str_tbl[idx_of_elf] != NULL)
    {
        debug_printf("%s\n", str_tbl[idx_of_elf] + name);
        return str_tbl[idx_of_elf] + name;
    }
    return NULL;
}

int is_func_start(Elf64_Addr addr, int *idx)
{
    Elf64_Sym *sym;
    int i;
    for (size_t idx_of_elf = 0; idx_of_elf < num_of_elf; idx_of_elf++)
    {
        for (i = 0, sym = sym_tbl_func[idx_of_elf]; i < sym_func_num[idx_of_elf]; sym++, i++)
        {
            if (sym->st_value == addr)
            {
                *idx = idx_of_elf;
                return i;
            }
        }
    }
    
    return -1;
}

int get_func_ndx(Elf64_Addr addr, int *idx)
{
    Elf64_Sym *sym;
    int i;
    for (size_t idx_of_elf = 0; idx_of_elf < num_of_elf; idx_of_elf++)
    {
        for (i = 0, sym = sym_tbl_func[idx_of_elf]; i < sym_func_num[idx_of_elf]; sym++, i++)
        {
            if (sym->st_value <= addr && addr <= (sym->st_value + sym->st_size))
            {
                *idx = idx_of_elf;
                return i;
            }
        }
    }
    return -1;
}

char *get_func_name(Elf64_Addr addr)
{
    Elf64_Sym *sym;
    unsigned int i;
    for (size_t idx_of_elf = 0; idx_of_elf < num_of_elf; idx_of_elf++)
    {
        for (i = 0, sym = sym_tbl_func[idx_of_elf]; i < sym_func_num[idx_of_elf]; sym++, i++)
        {
            if (sym->st_value == addr)
            {
                return str_tbl[idx_of_elf]+sym->st_name;
            }
        }
    }
    return NULL;
}

char *get_func_name_by_idx(int idx_of_sym, int idx_of_elf)
{
    if (idx_of_sym < 0 || idx_of_sym >= sym_func_num[idx_of_elf])
    {
        return NULL;
    }
    return str_tbl[idx_of_elf]+sym_tbl_func[idx_of_elf][idx_of_sym].st_name;
}

int is_func_name(char *str, int *idxOfSym, int *idxOfElf)
{
    Elf64_Sym *sym;
    for (size_t idx_of_elf = 0; idx_of_elf < num_of_elf; idx_of_elf++)
    {
        sym = sym_tbl_func[idx_of_elf];
        for (int idx_of_sym = 0; idx_of_sym < sym_func_num[idx_of_elf]; sym++, idx_of_sym++)
        {
            if (strcmp(str, str_tbl[idx_of_elf]+sym->st_name) == 0)
            {
                if(idxOfSym) *idxOfSym = idx_of_sym;
                if(idxOfElf) *idxOfElf = idx_of_elf;
                return 1;
            }
        }
    }
    return 0;
}