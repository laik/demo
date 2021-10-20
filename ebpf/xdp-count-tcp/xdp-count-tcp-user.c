#include <linux/bpf.h>
#include <uapi/linux/bpf.h>
#include <stdio.h>

static int ifindex = 2; // target network interface to attach, you can find it via `ip a`
static __u32 xdp_flags = 0;

// unlink the xdp program and exit
// static void int_exit(int sig)
// {
//     printf("stopping\n");
//     set_link_xdp_fd(ifindex, -1, xdp_flags);
//     exit(0);
// }

static char *filename = "xdp-count-tcp-kern.o";

int main(int argc, char **argv)
{
    // load the kernel bpf object file
    if (load_bpf_file(filename))
    {
        printf("error - bpf_log_buf: %s", filename);
        return 1;
    }
    return 0;
}