default:
	clang -O2 -target bpf -c xdp-pass.c -o xdp-pass.o

attach:
	ip link set dev eth0 xdpgeneric obj xdp-pass.o sec xdp
	
unattach:
	ip link set dev eth0 xdpgeneric off