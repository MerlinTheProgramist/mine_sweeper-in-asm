section .text
global _start

extern genRandSeed
extern nextRand

extern print_num
extern print_endl

%include "libs/macros.asm"

_start:	

	call genRandSeed

	mov 	rsi, 50 ; i=0
	_for:
	push 	rsi
	
	call nextRand

	cmp  rax, 1508451927
	jg g
	print less, 1
	jmp endl
	g:
	print greater,1
	endl:
	call print_endl

    call print_num ; number already in rax
    call print_endl


	pop rsi
	dec 	rsi
	test 	rsi, rsi
	jnz _for

	sys_exit

section .data
greater db 'g'
less 	db 'l'