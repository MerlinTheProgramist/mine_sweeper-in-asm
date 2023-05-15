section .text
global _start


%include "print.asm"

; retrun CPU time to RAX
%macro get_rdtsc 0 
    rdtsc ; edx:eax
    shr     rdx, 32
    or      rax, rdx
%endmacro

; Divident is RAX
; return is RDX
%macro modul 1
	xor 	rdx, rdx
	mov 	rbx, %1
	div 	rbx ; RAX=Quotient, RDX=Reminder
%endmacro

; linear Congruation Generator 
; seed = (a*seed+c) % m
; values are from wikipedia
%define M 	1<<32
%define A 	1664525
%define C 	16645223
; seed in RAX 
; return seed in RAX
nextRand:
	push rbx
	push rdx

	xor 	rdx, rdx
	mov 	rbx, A
	mul 	rbx ; RDX:RAX := RAX ∗ r/m64
	add		rax, C
	modul	M

	pop rdx
	pop rbx
	ret

_start:	

	get_rdtsc

	mov 	rcx, 100 ; i=0
	_for:
	push 	rcx
	
	call nextRand
    call print_num ; number already in rax

    call print_endl

	pop rcx
	dec 	rcx
	test 	rcx, rcx
	jnz _for
	mov 	rax, 60 ; sys_exit
	mov     rdi, 0 ; exit code
	syscall