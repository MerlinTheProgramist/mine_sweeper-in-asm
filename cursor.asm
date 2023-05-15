
section .text
global _start


_start:

%macro sys_exit 0
	mov 	rax, 60 ; sys_exit
	mov     rdi, 0 ; exit code
	syscall
%endmacro

%macro print_char 1
    mov 	rax, 1		    ; sys_write
    mov     rdi, 1			; std_out
    mov 	rsi, %1         ; char*
    mov 	rdx, 1        	; size
    syscall
%endmacro

mov     r8w, WORD[cursor_pos+pos.y]
_y:
test    r8w,r8w
jz      _y_exit

	mov 	rax, 1		    ; sys_write
	mov     rdi, 1			; std_out
	mov 	rsi, whiteLine	; char*
	mov 	rdx, width  	; size
    syscall

dec     r8w
jmp _y
_y_exit:

push    WORD[cursor_pos+pos.x]
_x:
cmp     WORD[rsp], 0
jz      _x_exit

	mov 	rax, 1		    ; sys_write
	mov     rdi, 1			; std_out
	mov 	rsi, whiteChar	; char*
	mov 	rdx, 1  	; size
    syscall

dec     WORD[rsp]
jmp _x
_x_exit:
sub     rsp, 16

print_char cursor_char

push    WORD[cursor_pos+pos.x]
_2x:
cmp     WORD[rsp], 0
jz      _2x_exit

	mov 	rax, 1		    ; sys_write
	mov     rdi, 1			; std_out
	mov 	rsi, whiteChar	; char*
	mov 	rdx, 1  	; size
    syscall

dec     WORD[rsp]
jmp _2x
_2x_exit:
sub     rsp, 16

print_char endl


sys_exit


struc pos
    .y: resw 1
    .x: resw 1
endstruc

section .data
ClearTerm: db   27,"[H",27,"[2J"    ; <ESC> [H <ESC> [2J
CLEARLEN   equ  $-ClearTerm         ; Length of term clear string

cursor_char: db '^'
whiteChar: db ' '
endl: db 0ah

whiteLine: times 10 db ' ', 0ah
width equ $ - whiteLine



cursor_pos: istruc pos
    at pos.y, dw 20
    at pos.x, dw 30
iend
