
%macro pop_qword 0
	add rsp, 8
%endmacro

; Print decimal representation of number
; rdx:rax is the number parameter
print_num:
	push rax
	push rbx
	push rdx
	push rcx
	push rsi
	push rdi

	mov 	rbx, 10	; bx stays the 10 all the time
	mov 	rcx, 0	; i = 0

	_loop:
	xor		rdx, rdx; clear rdx
	div 	rbx		; rax = rdx:rax/10,  rdx = rdx:rax%10

	; xor 	dx, dx
	; mov 	dl, ah	; save remaider to dx

	add 	rdx, '0'; add '0' to create for char
	push 	rdx		; push remaider to stack
	
	inc 	rcx		; i++
	; and 	ax, 0FFh; ax = quotient
	
	test	rax, rax	; if remainer is not 0 then _loop
	jnz 	_loop	

	_print_dig:
	; create digit char
	; pop 	rbx		; get next digit from stack
	lea 	rsi, [rsp]

	push 	rcx		; save coutner
	
	mov 	rax, 1  ; sys_write
	mov     rdi, 1	; std_out
	mov 	rdx, 1	; size
	syscall
	
	pop 	rcx		; recover counter
	
	pop_qword		; pop char used by sys_write
	
	cmp		rcx, 0
	dec		rcx

	jnz _print_dig

	pop rdi
	pop rsi
	pop rcx
	pop rdx
	pop rbx
	pop rax
	ret

print_endl:
	mov 	rsi, endl; char*
	mov 	rax, 1  ; sys_write
	mov     rdi, 1	; std_out
	mov 	rdx, 1	; size
	syscall
ret

endl 	db 	0ah
