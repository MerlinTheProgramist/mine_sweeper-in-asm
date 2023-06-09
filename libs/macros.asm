%macro sys_exit 0
	mov 	rax, 60 ; sys_exit
	mov     rdi, 0 ; exit code
	syscall
%endmacro

%macro print 2
	push 	rax
	push 	rbx
	push 	rdx
	push 	rsi
	push 	rdi
	push  	r8

	mov 	rsi, %1; char*
	mov 	rax, 1  ; sys_write
	mov     rdi, 1	; std_out
	mov 	rdx, %2	; size
	syscall

	pop 	r8
	pop 	rdi
	pop 	rsi
	pop 	rdx
	pop 	rbx
	pop 	rax
%endmacro

%macro static_print 1
%strlen len %1

	push 	rax
	push 	rbx
	push 	rdx
	push 	rsi
	push 	rdi

	push    %1
	mov 	rsi, rsp ; char*
	mov 	rax, 1  ; sys_write
	mov     rdi, 1	; std_out
	mov 	rdx, len; size
	syscall

	pop 	rdi
	pop 	rsi
	pop 	rdx
	pop 	rbx
	pop 	rax
%endmacro

%macro clear_term 0
	push rax

	mov		rax, 	27+"[H"+27+"[2J"
	push 	rax
	print 	rsp, 7
	add 	rsp, 8
	pop rax
%endmacro