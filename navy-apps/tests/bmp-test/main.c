#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include <NDL.h>
#include <BMP.h>

int main() {
  printf("Initialzing!\n");
  NDL_Init(0);
  printf("Initialze finished!\n");
  int w, h;
  void *bmp = BMP_Load("/share/pictures/projectn.bmp", &w, &h);
  printf("BMP Load!\n");
  assert(bmp);
  NDL_OpenCanvas(&w, &h);
  printf("NDL_OpenCanvas\n");
  NDL_DrawRect(bmp, 0, 0, w, h);
  printf("NDL_DrawRect\n");
  free(bmp);
  NDL_Quit();
  printf("Test ends! Spinning...\n");
  while (1);
  return 0;
}
