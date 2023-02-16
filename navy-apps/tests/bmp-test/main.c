#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include <NDL.h>
#include <BMP.h>

int main() {
  Log("Initialzing!");
  NDL_Init(0);
  Log("Initialze finished!");
  int w, h;
  void *bmp = BMP_Load("/share/pictures/projectn.bmp", &w, &h);
  Log("BMP Load!");
  assert(bmp);
  NDL_OpenCanvas(&w, &h);
  Log("NDL_OpenCanvas");
  NDL_DrawRect(bmp, 0, 0, w, h);
  Log("NDL_DrawRect");
  free(bmp);
  NDL_Quit();
  printf("Test ends! Spinning...\n");
  while (1);
  return 0;
}
