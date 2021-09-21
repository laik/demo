#include <linux/bpf.h>

#define SEC(NAME) __attribute__((section(NAME), used))

SEC("xdp")
int xdp_pass(struct xdp_md *ctx)
{
    return XDP_PASS;
}

char _license[] SEC("license") = "GPL";