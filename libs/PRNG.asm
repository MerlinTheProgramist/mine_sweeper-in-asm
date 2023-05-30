global get_rdtsc, genRandSeed
global nextRand


section .text
; retrun CPU time to RAX
genRandSeed:
get_rtsc:
	  push 	  rdx
	
    rdtsc ; edx:eax
    shr     rdx, 32
    or      rax, rdx

		pop rdx
ret

; Divident is RAX
; return is RAX
%macro modul 1
	xor 	rdx, rdx
	mov 	rbx, %1
	div 	rbx ; RAX=Quotient, RDX=Reminder
	mov 	rax, rdx
%endmacro

; linear Congruation Generator 
; seed = (a*seed+c) % m
; values are from wikipedia
%define M 	1<<32
%define A 	1664525
%define C 	1013904223
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