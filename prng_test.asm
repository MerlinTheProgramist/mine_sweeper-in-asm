section .text
global _start

%include "print.asm"
%include "PRNG.asm"

_start:	

	get_rdtsc

	mov 	rsi, 1 ; i=0
	_for:
	push 	rsi
	
	call nextRand
    call print_num ; number already in rax
    call print_endl

	pop rsi
	dec 	rsi
	test 	rsi, rsi
	jnz _for

	sys_exit