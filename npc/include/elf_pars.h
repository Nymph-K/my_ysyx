#ifndef _ELF_PARS_H
#define _ELF_PARS_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <elf.h>

int init_elf(int file_num, char const *file_name[]);
int Process_object(FILE *file, int idx_of_elf);
int get_file_header(FILE *file, int idx_of_elf);
int get_64bit_section_headers(FILE *file, int idx_of_elf);
void *get_data(void *var, FILE *file, long offset, size_t size, size_t nmemb);
void *cmalloc(size_t nmemb, size_t size);
int process_section_headers(FILE *file, int idx_of_elf);
void get_string_table(FILE *pFILE, int idx_of_elf);
void process_symbol_table(FILE *pFILE, int idx_of_elf);
void get_symbol_table(FILE *pFILE, int idx_of_elf);
void free_all(int file_num);
void free_useless(int file_num);
void get_64bit_symbol_func_tbl(int idx_of_elf);
char *get_64bit_strtbl(Elf64_Word name, int idx_of_elf);
int is_func_start(Elf64_Addr addr, int *idx);
int get_func_ndx(Elf64_Addr addr, int *idx);
char *get_func_name(Elf64_Addr addr);
char *get_func_name_by_idx(int idx_of_sym, int idx_of_elf);
int is_func_name(char *str, int *idxOfSym, int *idxOfElf);

#endif /* _ELF_PARS_H*/