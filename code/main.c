#include <stdio.h>
#include <asm/types.h>

#define max(x, y) x > y ? x : y

#define MAX_CONNECT_POOL_SIZE 1000

int main()
{
    __u32 abc = 1;
    printf("%d\r\n", abc);

    printf("max: %d\r\n", max(1, 2));

    printf("max_connect_pool_size: %d\r\n", MAX_CONNECT_POOL_SIZE);
    return 0;
}
