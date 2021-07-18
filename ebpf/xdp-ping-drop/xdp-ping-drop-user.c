#include <linux/bpf.h>
#include <linux/if_link.h>
#include "bpf_helper.h"

static char *filename = "xdp-ping-drop-kern.o";

int main(int argc, char **argv)
{
    // char *filename
    if (load_bpf_file(filename))
    {
        printf("error - bpf_log_buf: %s", "");
        return 1;
    }

    return 0;
}