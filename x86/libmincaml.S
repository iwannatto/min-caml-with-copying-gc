#if defined(__CYGWIN__) || defined(__MACH__)
#define U(x) _##x
#else
#define U(x) x
#endif
#if defined(__MACH__)
#define ALIGNSTACK0 andl $0xfffffff0, %esp
#define ALIGNSTACK1 andl $0xfffffff0, %esp; pushl %eax; pushl %eax; pushl %eax
#define ALIGNSTACK2 andl $0xfffffff0, %esp; pushl %eax; pushl %eax
#define ALIGNSTACK3 andl $0xfffffff0, %esp; pushl %eax
#else
#define ALIGNSTACK0
#define ALIGNSTACK1
#define ALIGNSTACK2
#define ALIGNSTACK3
#endif
.text
.globl min_caml_print_newline
min_caml_print_newline:
	pushl	%ebp
	movl	%esp, %ebp
	ALIGNSTACK1
	pushl	$10
	call	U(putchar)
	movl	%ebp, %esp
	popl	%ebp
	ret
.globl min_caml_print_int
min_caml_print_int:
	pushl	%ebp
	movl	%esp, %ebp
	sarl	$1, %eax
	ALIGNSTACK2
	pushl	%eax
	pushl	$format_int
	call	U(printf)
	movl	%ebp, %esp
	popl	%ebp
	ret
.globl min_caml_print_byte
min_caml_print_byte:
	pushl	%ebp
	movl	%esp, %ebp
	sarl	$1, %eax
	ALIGNSTACK1
	pushl	%eax
	call	U(putchar)
	movl	%ebp, %esp
	popl	%ebp
	ret
.globl min_caml_prerr_int
min_caml_prerr_int:
	pushl	%ebp
	movl	%esp, %ebp
	sarl	$1, %eax
	ALIGNSTACK3
	pushl	%eax
	pushl	$format_int
	pushl	U(min_caml_stderr)
	call	U(fprintf)
	movl	%ebp, %esp
	popl	%ebp
	ret
.globl min_caml_prerr_byte
min_caml_prerr_byte:
	pushl	%ebp
	movl	%esp, %ebp
	sarl	$1, %eax
	ALIGNSTACK2
	pushl	U(min_caml_stderr)
	pushl	%eax
	call	U(fputc)
	movl	%ebp, %esp
	popl	%ebp
	ret
.globl min_caml_prerr_float
min_caml_prerr_float:
	pushl	%ebp
	movl	%esp, %ebp
	ALIGNSTACK0
	subl	$8, %esp
	movsd	%xmm0, (%esp)
	pushl	$format_float
	pushl	U(min_caml_stderr)
	call	U(fprintf)
	movl	%ebp, %esp
	popl	%ebp
	ret
.globl min_caml_read_int
min_caml_read_int:
	pushl	%ebp
	movl	%esp, %ebp
	ALIGNSTACK3
	subl	$4, %esp
	leal	-4(%ebp), %eax
	pushl	%eax
	pushl	$format_int
	call	U(scanf)
	movl	-4(%ebp), %eax
	shll	$1, %eax
	orl	$1, %eax
	movl	%ebp, %esp
	popl	%ebp
	ret
.globl min_caml_read_float
min_caml_read_float:
	pushl	%ebp
	movl	%esp, %ebp
	ALIGNSTACK0
	subl	$8, %esp
	leal	-8(%ebp), %eax
	pushl	%eax
	pushl	$format_float
	call	U(scanf)
	movsd	-8(%ebp), %xmm0
	movl	%ebp, %esp
	popl	%ebp
	ret
.globl min_caml_create_array
min_caml_create_array:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ecx
	pushl	%edx
	sarl	$1, %eax
	movl	%eax, %ecx
	movl	%ecx, %edx
	shll	$2, %edx
	movl	min_caml_hp, %eax
	addl	$4, %eax
	addl	%eax, %edx
	cmpl	min_caml_hend, %edx
	ja	create_array_call_gc
create_array_gc_cont:
	movl	%edx, min_caml_hp
	movl	%ecx, %edx
	shll	$10, %edx
	movl	%edx, -4(%eax) # header
create_array_loop:
	cmpl	$0, %ecx
	jne	create_array_cont
create_array_exit:
	popl	%edx
	popl	%ecx
	movl	%ebp, %esp
	popl	%ebp
	ret
create_array_cont:
	decl	%ecx
	movl	%ebx, (%eax,%ecx,4)
	jmp	create_array_loop
create_array_call_gc:
	pushl	%eax
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	pushl	%ebp
	movl	%esp, stack_tmp
	ALIGNSTACK0
	call	gc
	movl	stack_tmp, %esp
	popl	%ebp
	popl	%edx
	popl	%ecx
	popl	%ebx
	popl	%eax
	movl	%ecx, %edx
	shll	$2, %edx
	movl	min_caml_hp, %eax
	addl	$4, %eax
	addl	%eax, %edx
	cmpl	min_caml_hend, %edx
	jbe	create_array_gc_cont
	call	gc_fail
.globl min_caml_create_float_array
min_caml_create_float_array:
	movl	%ebp, min_caml_stop
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ecx
	pushl	%edx
	sarl	$1, %eax
	movl	%eax, %ecx
	movl	%ecx, %edx
	shll	$3, %edx
	movl	min_caml_hp, %eax
	addl	$4, %eax
	addl	%eax, %edx
	cmpl	min_caml_hend, %edx
	ja	create_float_array_call_gc
create_float_array_gc_cont:
	movl	%edx, min_caml_hp
	movl	%ecx, %edx
	shll	$11, %edx
	addl	$254, %edx
	movl	%edx, -4(%eax) # header
create_float_array_loop:
	cmpl	$0, %ecx
	jne	create_float_array_cont
create_float_array_exit:
	popl	%edx
	popl	%ecx
	movl	%ebp, %esp
	popl	%ebp
	ret
create_float_array_cont:
	decl	%ecx
	movsd	%xmm0, (%eax,%ecx,8)
	jmp	create_float_array_loop
create_float_array_call_gc:
	pushl	%eax
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	pushl	%ebp
	movl	%esp, stack_tmp
	ALIGNSTACK0
	call	gc
	movl	stack_tmp, %esp
	popl	%ebp
	popl	%edx
	popl	%ecx
	popl	%ebx
	popl	%eax
	movl	%ecx, %edx
	shll	$3, %edx
	movl	min_caml_hp, %eax
	addl	$4, %eax
	addl	%eax, %edx
	cmpl	min_caml_hend, %edx
	jbe	create_float_array_gc_cont
	call	gc_fail
.globl min_caml_abs_float
min_caml_abs_float:
	pushl	%ebp
	movl	%esp, %ebp
	ALIGNSTACK2
	subl	$8, %esp
	movsd	%xmm0, (%esp)
	call	U(fabs)
	fstpl	(%esp)
	movsd	(%esp), %xmm0
	movl	%ebp, %esp
	popl	%ebp
	ret
.globl min_caml_sqrt
min_caml_sqrt:
	sqrtsd	%xmm0, %xmm0
	ret
.globl min_caml_floor
min_caml_floor:
	pushl	%ebp
	movl	%esp, %ebp
	ALIGNSTACK2
	subl	$8, %esp
	movsd	%xmm0, (%esp)
	call	U(floor)
	fstpl	(%esp)
	movsd	(%esp), %xmm0
	movl	%ebp, %esp
	popl	%ebp
	ret
.globl min_caml_int_of_float
min_caml_int_of_float:
.globl min_caml_truncate
min_caml_truncate:
	cvttsd2si	%xmm0, %eax
	shll	$1, %eax
	orl	$1, %eax
	ret
.globl min_caml_float_of_int
min_caml_float_of_int:
	sarl	$1, %eax
	cvtsi2sd	%eax, %xmm0
	ret
.globl min_caml_cos
min_caml_cos:
	pushl	%ebp
	movl	%esp, %ebp
	ALIGNSTACK2
	subl	$8, %esp
	movsd	%xmm0, (%esp)
	call	U(cos)
	fstpl	(%esp)
	movsd	(%esp), %xmm0
	movl	%ebp, %esp
	popl	%ebp
	ret
.globl min_caml_sin
min_caml_sin:
	pushl	%ebp
	movl	%esp, %ebp
	ALIGNSTACK2
	subl	$8, %esp
	movsd	%xmm0, (%esp)
	call	U(sin)
	fstpl	(%esp)
	movsd	(%esp), %xmm0
	movl	%ebp, %esp
	popl	%ebp
	ret
.globl min_caml_atan
min_caml_atan:
	pushl	%ebp
	movl	%esp, %ebp
	ALIGNSTACK2
	subl	$8, %esp
	movsd	%xmm0, (%esp)
	call	U(atan)
	fstpl	(%esp)
	movsd	(%esp), %xmm0
	movl	%ebp, %esp
	popl	%ebp
	ret
.globl float_malloc
float_malloc:
	movl	min_caml_hp, %eax
	addl	$12, %eax
	cmpl	min_caml_hend, %eax
	ja	float_malloc_call_gc
float_malloc_cont:
	movl	%eax, min_caml_hp
	subl	$8, %eax
	movl	$2301, -4(%eax) # 2048 (2 word) + 253 (float)
	movsd	%xmm0, (%eax)
	ret
float_malloc_call_gc:
	movl	%ebp, min_caml_stop
	pushl	%eax
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	pushl	%ebp
	movl	%esp, stack_tmp
	ALIGNSTACK0
	call	gc
	movl	stack_tmp, %esp
	popl	%ebp
	popl	%edx
	popl	%ecx
	popl	%ebx
	popl	%eax
	movl	min_caml_hp, %eax
	addl	$12, %eax
	cmpl	min_caml_hend, %eax
	jbe	float_malloc_cont
	call	gc_fail
.globl closure_malloc
closure_malloc:
	shrl	$1, %eax
	movl	%eax, %ecx
	movl	%ecx, %edx
	movl	min_caml_hp, %eax
	incl	%ecx
	shll	$2, %ecx
	addl	%eax, %ecx
	cmpl	min_caml_hend, %ecx
	ja	closure_malloc_call_gc
closure_malloc_cont:
	movl	%ecx, min_caml_hp
	addl	$4, %eax
	shll	$10, %edx
	addl	$247, %edx # 247 is closure tag
	movl	%edx, -4(%eax)
	movl	%ebx, (%eax)
	ret
closure_malloc_call_gc:
	movl	%ebp, min_caml_stop
	pushl	%eax
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	pushl	%ebp
	movl	%esp, stack_tmp
	ALIGNSTACK0
#	andl	$0xfffffff0, %esp
	call	gc
	movl	stack_tmp, %esp
	popl	%ebp
	popl	%edx
	popl	%ecx
	popl	%ebx
	popl	%eax
	movl	%edx, %ecx
	movl	min_caml_hp, %eax
	incl	%ecx
	shll	$2, %ecx
	addl	%eax, %ecx
	cmpl	min_caml_hend, %ecx
	jbe	closure_malloc_cont
	call	gc_fail
.globl tuple_malloc
tuple_malloc:
	shrl	$1, %eax
	movl	%eax, %ebx
	movl	%ebx, %ecx
	movl	min_caml_hp, %eax
	addl	$4, %eax
	shll	$2, %ebx
	addl	%eax, %ebx
	cmpl	min_caml_hend, %ebx
	ja	tuple_malloc_call_gc
tuple_malloc_cont:
	movl	%ebx, min_caml_hp
	shll	$10, %ecx
	movl	%ecx, -4(%eax)
	ret
tuple_malloc_call_gc:
	movl	%ebp, min_caml_stop
	pushl	%eax
	pushl	%ebx
	pushl	%ecx
	pushl	%edx
	pushl	%ebp
	movl	%esp, stack_tmp
	ALIGNSTACK0
	call	gc
	movl	stack_tmp, %esp
	popl	%ebp
	popl	%edx
	popl	%ecx
	popl	%ebx
	popl	%eax
	movl	%ecx, %ebx
	movl	min_caml_hp, %eax
	shll	$2, %ebx
	addl	%eax, %ebx
	cmpl	min_caml_hend, %ebx
	jbe	tuple_malloc_cont
	call	gc_fail
.globl min_caml_do_nothing
min_caml_do_nothing:
	ret
.globl min_caml_read_int_0
min_caml_read_int_0:
	movl	$1, %eax
	ret
.globl min_caml_read_float_0
min_caml_read_float_0:
	movl	$float_0, %eax
	movsd	(%eax), %xmm0
	ret
.data
format_int:
	.asciz	"%d"
format_float:
	.asciz	"%lf"
.balign 8
float_0:
	.long	0x0
	.long	0x0
float_1:
	.long	0x0
	.long	0x3ff00000
.balign 16
.globl min_caml_fnegd
min_caml_fnegd:
	.long	0
	.long	0x80000000
	.long	0
	.long	0
.globl min_caml_hbase
min_caml_hbase:
	.long 0x0
.globl min_caml_hp
min_caml_hp:
	.long	0x0
.globl min_caml_hend
min_caml_hend:
	.long 0x0
.globl min_caml_next_hbase
min_caml_next_hbase:
	.long 0x0
.globl min_caml_next_hend
min_caml_next_hend:
	.long 0x0
.globl min_caml_sbase
min_caml_sbase:
	.long 0x0
.globl min_caml_stop
min_caml_stop:
	.long 0x0
.globl stack_tmp
stack_tmp:
	.long 0x0
