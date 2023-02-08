#include <klibtest.h>
#include <limits.h>
#include <errno.h>
#include <string.h>

/*
// #define N 1024

// const char file_content[] = "s    =0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\n\
// 7s   =0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\n\
// .3s  =012\n\
// 7.3s =    012\n\
// 3.7s =0123456\n\
// d    =123456\n\
// 7d   = 123456\n\
// .3d  =123456\n\
// 7.3d = 123456\n\
// ========-d========\n\
// -7d   =123456 \n\
// -.3d  =123456\n\
// -7.3d =123456 \n\
// ========+d========\n\
// +8d   = +123456\n\
// +.3d  =+123456\n\
// +7.3d =+123456\n\
// ========0d========\n\
// 07d   =0123456\n\
// 0.3d  =123456\n\
// 08.3d =  123456\n\
// =========-0d=======\n\
// -07d   =123456 \n\
// -0.3d  =123456\n\
// -07.3d =123456 \n\
// =========data=======\n\
// data[0] =0\n\
// data[1] =126322567\n\
// data[2] =2147483647\n\
// data[3] =-2147483648\n\
// data[4] =-2147483647\n\
// data[5] =252645135\n\
// data[6] =126322567\n\
// data[7] =-1\n\
// ";

// static void func_sel(char *str);

// #ifndef __NATIVE_USE_KLIB__
// FILE *f;
// #endif

// void test_sprintf(void)
// {
//     char s[] = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
//     char str[N];
//     int data[] = {0, INT_MAX / 17, INT_MAX, INT_MIN, INT_MIN + 1, UINT_MAX / 17, INT_MAX / 17, UINT_MAX};
//     int a = 123456;
    
//     //精度只对s、f有用：字符串（截取字符串前n位），浮点（截取小数点后n位）
//     //宽度：对经过精度截取处理后的长度进行填充
//     //有左对齐'-'时，填充'0'无用

//     #ifndef __NATIVE_USE_KLIB__
//     f = fopen("./print_str.txt", "w");
//     if (f == NULL)
//     {
//       printf("File open failed!\n");
//       int errNum = errno;
//       printf("open fail errno = %d, reason = %s \n", errNum, strerror(errNum));
//       return ;
//     }
//     #endif
    
//     sprintf(str, "s    =%s\n", s);
//     func_sel(str);
//     sprintf(str, "7s   =%7s\n", s);
//     func_sel(str);
//     sprintf(str, ".3s  =%.3s\n", s);
//     func_sel(str);
//     sprintf(str, "7.3s =%7.3s\n", s);
//     func_sel(str);
//     sprintf(str, "3.7s =%3.7s\n", s);
//     func_sel(str);

//     sprintf(str, "d    =%d\n", a);
//     func_sel(str);
//     sprintf(str, "7d   =%7d\n", a);
//     func_sel(str);
//     sprintf(str, ".3d  =%.3d\n", a);
//     func_sel(str);
//     sprintf(str, "7.3d =%7.3d\n", a);
//     func_sel(str);
    
//     sprintf(str, "========-d========\n");
//     func_sel(str);
//     sprintf(str, "-7d   =%-7d\n", a);
//     func_sel(str);
//     sprintf(str, "-.3d  =%-.3d\n", a);
//     func_sel(str);
//     sprintf(str, "-7.3d =%-7.3d\n", a);
//     func_sel(str);
    
//     sprintf(str, "========+d========\n");
//     func_sel(str);
//     sprintf(str, "+8d   =%+8d\n", a);
//     func_sel(str);
//     sprintf(str, "+.3d  =%+.3d\n", a);
//     func_sel(str);
//     sprintf(str, "+7.3d =%+7.3d\n", a);
//     func_sel(str);

//     sprintf(str, "========0d========\n");
//     func_sel(str);
//     sprintf(str, "07d   =%07d\n", a);
//     func_sel(str);
//     sprintf(str, "0.3d  =%0.3d\n", a);
//     func_sel(str);
//     sprintf(str, "08.3d =%08.3d\n", a);
//     func_sel(str);

//     sprintf(str, "=========-0d=======\n");
//     func_sel(str);
//     sprintf(str, "-07d   =%-07d\n", a);
//     func_sel(str);
//     sprintf(str, "-0.3d  =%-0.3d\n", a);
//     func_sel(str);
//     sprintf(str, "-07.3d =%-07.3d\n", a);
//     func_sel(str);

//     sprintf(str, "=========data=======\n");
//     func_sel(str);
//     for (size_t i = 0; i < 8; i++)
//     {
//       sprintf(str, "data[%d] =%d\n", i, data[i]);
//       func_sel(str);
//     }
    
//     #ifndef __NATIVE_USE_KLIB__
//     fclose(f);
//     #endif
// }


// #ifdef __NATIVE_USE_KLIB__
// static void sread(char *str_f, size_t len, size_t size){
//     static size_t ptr = 0;
//     strncpy(str_f, file_content + ptr, len * size);
//     ptr += len;
// }

// static void cmp(char *str, size_t len) {
//     char str_f[N];
//     sread(str_f, len, 1);
//     str_f[len] = '\0';
//     printf(" str   = %s str_f = %s\n", str, str_f);
//     assert(strcmp(str, str_f) == 0);
// }
// #endif

// static void func_sel(char *str) {
//     size_t len = strlen(str);
// #ifndef __NATIVE_USE_KLIB__
//     fwrite(str, len, 1, f);
// #else
//     cmp(str, len);
// #endif
// }

*/
char buf[128];

void test_sprintf(void) {
	sprintf(buf, "%s", "Hello world!\n");
	assert(strcmp(buf, "Hello world!\n") == 0);

	sprintf(buf, "%d + %d = %d\n", 1, 1, 2);
	assert(strcmp(buf, "1 + 1 = 2\n") == 0);

	sprintf(buf, "%d + %d = %d\n", 2, 10, 12);
	assert(strcmp(buf, "2 + 10 = 12\n") == 0);
}
