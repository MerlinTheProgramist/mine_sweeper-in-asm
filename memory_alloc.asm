global _start

%include "libs/macros.asm"

extern print_num
extern print_endl

%define BRK 12

%define TRUE  1
%define FALSE 0

%define MIN_BRK 100; in bytes

%define SET_SIZE(addr,size) mov QWORD[addr + Header.size], size
%define SET_FULL(addr) mov BYTE[addr + Header.full], TRUE
%define SET_FREE(addr) mov BYTE[addr + Header.full], FALSE

%define GET_SIZE(addr) QWORD[addr + Header.size]
%define GET_FULL(addr) BYTE[addr + Header.full]

%define CHECK_FULL(addr) TEST BYTE[addr + Header.full], TRUE

; ENDING address to rax
%macro sys_sbrk 1
    push rdi 
        mov  rdi, %1
        mov  rax, 12
        syscall
    pop  rdi
%endmacro

; memory block headrer
struc Header
    .size: resq 1 ; could change to DWORD, because <4GB is still a LOT
    .full: resb 1
endstruc

;section .data

section .text 



; rdi = size
; out:
; rax = addr
heap_alloc:
    ; if size == 0: then do nothing
    test rdi, rdi
    jnz .input_asserted
        ret ; size was 0
    .input_asserted:

    mov   rax, [root]       ; load root_heap address

    .block_check:

    CHECK_FULL(rax)         ; if full then check next
    jnz    .check_next_block
    ; if empty 
    ;   check size

    mov   rbx, GET_SIZE(rax)
    test   rbx, rbx          
    jz    .last_block       ; if zero then request more memory
    cmp   rbx, rdi
    jl    .check_next_block ; if too small, then check next

    .allocate:
    ; bigger than our desire, so we can allocate it
    SET_FULL(rax)  
    SET_SIZE(rax, rdi)

    add     rax, Header_size    ; set to start of allocated block (addr to return) 

    add     rbx, rdi            ; what is left to the next chunk
    add     rbx, Header_size    ; sub next block header_size, to only have its true size
    SET_FREE(rax + rdi)
    SET_SIZE(rax + rdi , rbx)
ret
    .check_next_block
    add     rax, rbx
    jmp .block_check

    .last_block ; this is the last block, has size 0
                ; so we need to request more memory from kernel and then our last will  
    
    ; override this header
    SET_FULL(rax)
    SET_SIZE(rax, rdi)

    add rax, Header_size    ; |this H| <RAX> this DATA |next H|
    push rax
    add rax, rdi            ; |this H| this DATA |<RAX> next H|
    mov rbx, rax

    add rax, Header_size    ; allocate enough space 
    sys_sbrk rax            ; + space for ending header

    ; new ending header ending
    SET_FREE(rbx)           
    SET_SIZE(rbx, 0)
    pop rax
ret

; rdi = addr 
; no return
heap_free:
    push rdi

    sub rdi, Header_size ;|<RDI> this H| this DATA |


    pop rdi
ret



heap_init:
    sys_sbrk 0
    mov [root], rax

    ; reserve Header_size
    mov rdi, rax
    add rdi, Header_size
    mov rax, BRK
    syscall

    mov rax, [root]
    SET_FREE(rax)
    SET_SIZE(rax, 0)
ret


_start:
    call heap_init

    mov  rdi, 'Z'-'A'
    call heap_alloc

    mov  rcx, 'Z' - 'A' + 3
    .loop:
    push rcx

    mov rbx, rcx
    add bl, 'A'
    mov BYTE[rax + rcx], bl
    
    loop .loop


    sys_exit

    
section .bss
    root: resq 1 ; address of root