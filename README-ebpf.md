# ebpf 常用

预装clang、LLVM、iproute2、libelf-dev

# for ubuntu
apt install clang llvm libelf-dev iproute2
# test clang
clang -v
# test llvm
llc --version
# test iproute2
ip link
bpftool命令行安装说明

下载Linux内核源码，进行本地编译。

# 确认内核版本
uname -r
# 找到对应内核版本的源代码
apt-cache search linux-source
apt install linux-source-5.4.0
apt install libelf-dev

cd /usr/src/linux-source-5.4.0
tar xjf linux-source-5.4.0.tar.bz2
cd linux-source-5.4.0/tools
make -C  bpf/bpftool/
cd bpf/bpftool/
./bpftool prog/net

mv bpftool /usr/bin/


常见问题Q&A
1. 'asm/type.h' file not found
错误现象

在执行下面命令进行代码编译时，可能会遇到某些头文件找不到的错误：

clang -I ./headers/ -O2 -target bpf -c tc-xdp-drop-tcp.c -o tc-xdp-drop-tcp.o

In file included from tc-xdp-drop-tcp.c:2:
In file included from /usr/include/linux/bpf.h:11:
/usr/include/linux/types.h:5:10: fatal error: 'asm/types.h' file not found
#include <asm/types.h>
        ^~~~~~~~~~~~~
1 error generated.
原因分析

在源代码文件中引用了某些系统目录（一般为/usr/include/）下的头文件，而这些头文件没有出现在目标路径下，导致编译失败。

如上述问题中的asm相关文件，asm全称Architecture Specific Macros，直译过来“与机器架构相关的宏文件”，顾名思义它是跟机器架构密切相关的，不同的架构x86、x64、arm实现是不一样的，而操作系统并没有提供/usr/include/asm/这样通用的目录，只提供了具体架构相关的目录，如/usr/include/x86_64-linux-gnu/asm/，因此无法找到引用。

解决方案

添加软链/usr/include/asm/，指向操作系统自带的asm目录：

cd /usr/include

# x86平台
ln -s ./x86_64-linux-gnu/asm asm

# arm64
ln -s ./aarch64-linux-gnu/asm/ asm



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
ip link set dev eth0 xdpgeneric obj xdp-drop-world.o sec xdp

ip link set dev eth0 xdpgeneric off



# map操作
```
## 创建counter map
bpftool map create /sys/fs/bpf/mycount type array key 4 value 4 entries 5 name counter

#查看mapid 一般在底部
bpftool map show

8: array  name counter  flags 0x0
        key 4B  value 4B  max_entries 5  memlock 4096B

#更新id 8的map
bpftool map update id 8 key 1 0 0 0 value 1 0 0 0

#查看id8 map
bpftool map dump id 8


# 加载mapfile 参考具体创建
bpftool batch file /tmp/hashmap.txt 
```


# 查看其他事件点
```
## xdp附加
bpftool net show 

## perf 
bpftool perf show

## cgroup 
bpftool cgroup tree

```

# bpf_track_print
cat  /sys/kernel/debug/tracing/trace_pipe