#include <am.h>
#include <stdio.h>
#include <stdlib.h>

Area heap;

#ifndef MAINARGS
#define MAINARGS ""
#endif
const char mainargs[] = MAINARGS;

void putch(char ch) {
    putchar(ch);
}

void halt(int code) {
    exit(code);
}
