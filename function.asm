section .text			
global _start




%include "print.asm"
; Print string at current cursor pos
; string address at `rbx`
_start:	
    mov     rcx, 1           ; i = 0
_for:
    push    rcx

	; print
	;mov     rbx,    tekst
	;call    print

	; new print number
	xor  rbx, rbx
	mov  rax, [rsp]		; counter from stack
	call print_num
	
	; endline
	call print_endl
	; print endl, 1

    pop     rcx				 ; restore i
	inc     rcx            	 ; i ++
	cmp 	rcx, 10		 ;if (i >= 9)
	jbe 	_for 

	mov 	rax, 60 ; sys_exit
	mov     rcx, 0 ; exit code
	syscall

section .data

tekst 	db	"Iteracja nr ", 0h

