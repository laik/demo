	.arch armv8-a
	.file	"asm-demo1.c"
	.text
	.align	2
	.global	add_a_and_b
	.type	add_a_and_b, %function
add_a_and_b:
.LFB0:
	.cfi_startproc
	stp	x29, x30, [sp, -32]!
	.cfi_def_cfa_offset 32
	.cfi_offset 29, -32
	.cfi_offset 30, -24
	mov	x29, sp
	str	w0, [sp, 28]
	str	w1, [sp, 24]
	ldr	w1, [sp, 24]
	ldr	w0, [sp, 28]
	bl	_add_a_and_b
	ldp	x29, x30, [sp], 32
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE0:
	.size	add_a_and_b, .-add_a_and_b
	.align	2
	.global	_add_a_and_b
	.type	_add_a_and_b, %function
_add_a_and_b:
.LFB1:
	.cfi_startproc
	sub	sp, sp, #16
	.cfi_def_cfa_offset 16
	str	w0, [sp, 12]
	str	w1, [sp, 8]
	ldr	w1, [sp, 12]
	ldr	w0, [sp, 8]
	add	w0, w1, w0
	add	sp, sp, 16
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE1:
	.size	_add_a_and_b, .-_add_a_and_b
	.global	a
	.data
	.align	2
	.type	a, %object
	.size	a, 4
a:
	.word	123
	.text
	.align	2
	.global	main
	.type	main, %function
main:
.LFB2:
	.cfi_startproc
	stp	x29, x30, [sp, -32]!  -- > arm v8 通用寄存器，x0-x30, x29 为栈底指针，x30 链接寄存器，指向下一条指令，x86 push
	.cfi_def_cfa_offset 32
	.cfi_offset 29, -32
	.cfi_offset 30, -24
	mov	x29, sp
	mov	w0, 123
	str	w0, [sp, 28]
	adrp	x0, a
	add	x0, x0, :lo12:a
	ldr	w0, [x0]            - > ldr/str 指令将操作数x0 放入寄存器，为什么不用mov? 因为ldr/str 跟mov操作直接数是不同的指令，x86好像可以用mov
	ldr	w1, [sp, 28]
	bl	add_a_and_b         - > bl/b == x86 call
	ldp	x29, x30, [sp], 32  - > x86里的 pop 出栈指令 
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE2:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0"
	.section	.note.GNU-stack,"",@progbits
