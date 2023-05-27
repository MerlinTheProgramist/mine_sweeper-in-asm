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

%macro print_endl 0 
	print endl, 1
%endmacro

%macro clear_term 0
	push rax

	mov		rax, 	27+"[H"+27+"[2J"
	push 	rax
	print 	rsp, 7
	add 	rsp, 8
	pop rax
%endmacro