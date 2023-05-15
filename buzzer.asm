section .text				; poczatek sekcji kodu
global _start				; symbol globalny dla linkera LD

%define KIOCSOUND	4B2Fh
%define sys_ioctl   16

%define sys_nanosleep 35

%macro sys_exit 0
	mov 	rax, 60 ; sys_exit
	mov     rdi, 65 ; exit code
	syscall
%endmacro

custom_pause:	; pause for CX:DX ms
	push 	rbx
	push 	rcx
	push 	rdx

	mov 	ax, cx
	shl		eax, 16
	mov 	ebx, 1000000
	mov 	ax, dx
	xor		edx, edx
	div 	ebx
	mov 	[t1+timespec.tv_nsec], eax

	mov 	rax, sys_nanosleep
	mov 	rdi, t1
	mov 	rsi, t2
	syscall

	pop 	rdx
	pop 	rcx
	pop 	rbx
	ret

_start:
mov 	rax, 2 ; sys_open
mov 	rdi, console
mov 	rsi, 777o
mov 	rdx, 1 ; O_WRONLY
syscall
cmp		rax, 0 ; if errors
jg	_opened

sys_exit

_opened:
mov 	rdi, rax 		; RBX = file descriptor
mov 	rax, sys_ioctl	; 
mov 	rsi, KIOCSOUND	; 
xor		rdx, rdx		; no arguments
syscall 

mov 	rax, sys_ioctl
mov 	rdx, 2711	; 2711 = 1234DDh/440. 440Hz => A note
syscall

mov 	cx, 0fh
mov 	dx, 4240h
call custom_pause

mov		rax, sys_ioctl
mov		rsi, KIOCSOUND
xor 	rdi, rdi
syscall


section .bss 
struc timespec	; timespec_size
 	.tv_sec:	resd 1	; seconds
 	.tv_nsec: 	resd 1	; nano seconds
endstruc

t1 istruc timespec
t2 istruc timespec

section .data
console		db	"/dev/console", 0

; section .bss

