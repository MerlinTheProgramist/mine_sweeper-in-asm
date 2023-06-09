global _start

; address to rax
%macro sys_sbrk 1
    mov  rax, 12
    mov  rdi, %1
    sys_call
%endmacro

section .text 

_start:

