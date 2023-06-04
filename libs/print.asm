
%macro pop_qword 0
	add rsp, 8
%endmacro

global print_num
global print_endl

section .text

%macro print 2
	push 	rax
	push 	rbx
	push 	rdx
	push 	rsi
	push 	rdi


	mov 	rsi, %1; char*
	mov 	rax, 1  ; sys_write
	mov     rdi, 1	; std_out
	mov 	rdx, %2	; size
	syscall

	pop 	rdi
	pop 	rsi
	pop 	rdx
	pop 	rbx
	pop 	rax
%endmacro

; Print decimal representation of number
; rdx:rax is the number parameter
print_num:
	push rax
	push rbx
	push rdx
	push rsi
	push rdi

	mov 	rbx, 10	; bx stays the 10 all the time
	mov 	rsi, 0	; i = 0

	_loop:
	xor		rdx, rdx; clear rdx
	div 	rbx		; rax = rdx:rax/10,  rdx = rdx:rax%10

	add 	rdx, '0'; add '0' to create for char
	push 	rdx		; push remaider to stack
	
	inc 	rsi		; i++
	
	test	rax, rax	; if remainer is not 0 then _loop
	jnz 	_loop	

	_print_dig:
	; create digit char
	; pop 	rbx		; get next digit from stack
	mov 	rax, rsi
	mov 	rsi, rsp
	push 	rax		; save coutner
	
	mov 	rax, 1  ; sys_write
	mov     rdi, 1	; std_out
	mov 	rdx, 1	; size
	syscall
	
	pop 	rsi		; recover counter
	
	pop_qword		; pop char used by sys_write
	
	cmp		rsi, 0
	dec		rsi

	jnz _print_dig

	pop rdi
	pop rsi
	pop rdx
	pop rbx
	pop rax
ret

print_endl:
	print endl, 1
	ret

section .data
endl 	db 	0ah
ClearTerm: db   27,"[H",27,"[2J"    ; <ESC> [H <ESC> [2J
CLEARLEN   equ  $-ClearTerm         ; Length of term clear string