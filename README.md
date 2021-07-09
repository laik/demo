# demo


# ebpf 常用
```
# 查看生成的elf格式的可执行文件的相关信息
# 能看到上文提到的Section信息
readelf -a xdp-drop-world.o


#还可以通过llvm-objdump这个工具来分析下这个可执行文件的反汇编指令信息：
llvm-objdump -S xdp-drop-world.o


#XDP支持三种操作模式，默认会使用native模式。

Native XDP(XDP_FLAGS_DRV_MODE)：默认的工作模式，XDP BPF程序运行在网络驱动的早期接收路径(RX队列)上。大多数10G或更高级别的NIC都已经支持了native XDP。
Offloaded XDP(XDP_FLAGS_HW_MODE)：offloaded XDP模式中，XDP BPF程序直接在NIC中处理报文，而不会使用主机的CPU。因此，处理报文的成本非常低，性能要远远高于native XDP。该模式通常由智能网卡实现，包含多线程，多核流量处理器(以及一个内核的JIT编译器，将BPF转变为该处理器可以执行的指令)。支持offloaded XDP的驱动通常也支持native XDP(某些BPF辅助函数通常仅支持native 模式)。
Generic XDP(XDP_FLAGS_SKB_MODE)：对于没有实现native或offloaded模式的XDP，内核提供了一种处理XDP的通用方案。由于该模式运行在网络栈中，因此不需要对驱动进行修改。该模式主要用于给开发者测试使用XDP API编写的程序，其性能要远低于native或offloaded模式。在生产环境中，建议使用native或offloaded模式。

可以通过ip link命令查看已经安装的XDP模式，generic/SKB (xdpgeneric), native/driver (xdp), hardware offload (xdpoffload)，如下xdpgeneric即generic模式。


ip link set dev [device name] xdp obj xdp-drop-world.o sec [section name]

例如：虚拟机里 eth0是虚拟virtio_net
ip link set eth0 xdp xdpgeneric xdp-drop-world.o sec xdp

```


