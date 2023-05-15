section .text			
global _start




%include "print.asm"
; Print string at current cursor pos
; string address at `rbx`
print:
	push rsi
	push rax
	push rdi
	push rdx

	_print:
	mov 	rsi, rbx; char*
	mov 	rax, 1  ; sys_write
	mov     rdi, 1	; std_out
	mov 	rdx, 1	; size
	syscall		

	mov 	dl,  BYTE[rbx]
	inc     rbx
	cmp 	dl, 0
	jnz		_print

	pop rdx
	pop rdi
	pop rax
	pop rsi
	ret



_start:	
    mov     rcx, 0xfffffffffffff0           ; i = 0
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

    pop     rcx				 ; restore i
	inc     rcx            	 ; i ++
	cmp 	rcx, 0xffffffff		 ;if (i >= 9)
	jbe 	_for 

	mov 	rax, 60 ; sys_exit
	mov     rdi, 0 ; exit code
	syscall

section .data

tekst 	db	"Iteracja nr ", 0h

