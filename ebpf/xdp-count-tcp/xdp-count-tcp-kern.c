#include <linux/bpf.h>
#include "bpf_helpers.h"

struct bpf_map_def SEC("maps") tcp_tracker_map = {
    .type = BPF_MAP_TYPE_HASH,
    .key_size = sizeof(__u32),
    .value_size = sizeof(__u32),
    .max_entries = 2048,
};

SEC("xdp_tcp_track")
int _xdp_tcp_track(struct xdp_md *ctx)
{

    void *data_end = (void *)(long)ctx->data_end;
    void *data = (void *)(long)ctx->data;

    // bpf_printk("recv data_end %d data %d\r\n", (long)data_end, (long)data);
    char msg[] = "xx";
    bpf_trace_printk(msg, sizeof(msg));
    return XDP_PASS;
}

char _license[] SEC("license") = "GPL";