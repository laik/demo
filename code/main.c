#include <stdio.h>
#include <asm/types.h>

#define max(x, y) ((x) > (y) ? (x) : (y))

#define MAX_CONNECT_POOL_SIZE 1000

// #define printLog1(...) (fprintf(fp_log, "%s var %d\n"), __func__, __VA_ARGS__)
#define printLog(...) printf("printlog -> %d%d%d\r\n", __VA_ARGS__)
#define showArgs(...) puts(#__VA_ARGS__)

#define TEXT_A "TEXT_A Hello, world!"
#define msg(x) puts(TEXT_##x)

#define STR(x) sprintf("%s", x)

int main(int *argv, char **args)
{
    __u32 abc = 1;
    printf("%d\r\n", abc);

    printf("max: %d\r\n", max(1, 2));

    printf("max_connect_pool_size: %d\r\n", MAX_CONNECT_POOL_SIZE);

    printLog(1, 2, 3);

    showArgs("a", "b", "C");

    msg(A);

    for (int i = 0; i < argv; i++)
    {
        // printf("index %d - value = %c", i, STR(args[i]));
    }

    return 0;
}
