#ifndef XDP_IP_TACKER_COMMON_H
#define XDP_IP_TACKER_COMMON_H
#include <asm/types.h>

struct pair
{
    /* data */
    __u32 src_ip;
    __u32 dest_ip;
};

struct stats
{
    /* data */
    __u64 tx_cnt;
    __u64 rx_cnt;
    __u64 tx_bytes;
    __u64 rx_bytes;
};

#endif
