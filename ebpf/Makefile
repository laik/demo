
XDP        = xdp.o
# CLSACT     = clsact.o
# CLSACT2    = clsact2.o


# BTF debug data section '.BTF' rejected: Invalid argument (22)!
BPFCC      = clang
BPFCFLAGS  = -target bpf -Wall -O2 -emit-llvm -g -c
# BPFCFLAGS += -I../libbpf/include
BPFLC      = llc
BPFLCFLAGS = -march=bpf -mcpu=probe -filetype=obj

all: clean $(XDP)

%.o: %.c
	$(BPFCC) $(BPFCFLAGS) -c $< -o - | \
	$(BPFLC) $(BPFLCFLAGS) -o $@

clean:
	rm -f *.o