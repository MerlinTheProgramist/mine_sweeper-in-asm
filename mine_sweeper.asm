section .text
global _start

%include "print.asm"
%include "PRNG.asm"

; Project DESCRIPTION:
; Each matrix cell stores information: 
;   - is_revealed
;   - has_bomb
;   - has_count (count is calculated on generation of the grid )

; TODO:
; 


%define TRUE 1
%define FALSE 0

%define BOARD_SIZE 7 ; 2^n -1
%define NOMINAL    00000000b
%define REVEALED   10000000b 
%define BOMB       01000000b
%define HAS_COUNT  00100000b
%define COUNT_MASK 00000111b

%define NREV_CHAR '#'
%define BOMB_CHAR '*'
%define EMPT_CHAR ' '
%define ENDL_CHAR 0ah


sys_read:
	push rax
	push rbx
	push rdi
	push rdx
	push rsi

	mov 	rax, 0
	mov 	rdi, 1
	mov		rsi, input_buffer
	mov 	rdx, 1
	syscall

	pop rsi
	pop rdx
	pop rdi
	pop rbx
	pop rax
	ret

%define BOMB_PROBABILITY 3
%define HALF_QWORD, 4294967296

generate_board:
    get_rdtsc ; rax
    mov     rsi, 0
    _gen_board_for:
        push    rsi 
        push    rax

        call    nextRand
        
        ; if rax > HARF_QWORD => matrix[rsi] = BOMB 
        ; else => matrix[ris] = NOMINAL
        cmp     rax, 
        jg  _gen_greater
            mov     BYTE[matrix + rsi], NOMINAL
            jmp _gen_greater_skip
        _gen_greater:
        mov     BYTE[matrix + rsi], BOMB
        _gen_greater_skip:

        pop     rax
        pop     rsi
        inc     rsi
        cmp     rsi, BOARD_SIZE*BOARD_SIZE
        jnz _gen_board_for

    ret

print_matrix:

    ; for y in 0..BOARD_SIZE
    mov     rsi, 0
    _pm_for_y:
        ; for x in 0..BOARD_SIZE
        mov     rdi, 0
        _pm_for_x:
            push rsi
            push rdi

            
            ; sounding cell
            mov    rax, rsi
            mov    rbx, BOARD_SIZE
            mul    rbx ;rax *= BOARD_SIZE
            add    rdi, rax
            mov    al, BYTE[matrix + rdi] ; could swap for lea

            ; if is not revealed
            ; print_row_buffer[rdi] = NREV_CHAR
            ; continue
            test   al, REVEALED
            jnz _rev
                mov     BYTE[print_row_buffer + rdi + rsi], NREV_CHAR
                jmp     _pm_for_continue
            _rev:

            ; if is bomb
            ; print_row_buffer[rdi] = BOMB_CHAR
            test    al, BOMB
            jz _not_bomb
                mov     BYTE[print_row_buffer + rdi + rsi], BOMB_CHAR
                jmp     _pm_for_continue
            _not_bomb:

            ; if count exists
            ; print_row_buffer[rdi] = COUNT_MASK AND [1-8] 
            test    al, HAS_COUNT
            jz _not_count
                and     al, COUNT_MASK     
                add     al, '1'
                mov     BYTE[print_row_buffer + rdi + rsi], al
                jmp     _pm_for_continue
            _not_count:
            ; print_row_buffer[rdi] = ' '
            mov     BYTE[print_row_buffer + rsi + rdi], EMPT_CHAR

            _pm_for_continue:
            pop    rdi
            pop    rsi

            inc    rdi
            cmp    rdi, BOARD_SIZE
            jnz _pm_for_x    

        mov    BYTE[print_row_buffer+rsi*(BOARD_SIZE+1) + BOARD_SIZE], ENDL_CHAR
           
        

        inc    rsi
        cmp    rsi, BOARD_SIZE
        jnz _pm_for_y

    ; print rows buffer
    print  print_row_buffer, (BOARD_SIZE+1)*BOARD_SIZE
    ret

_start:

    ; call sys_read
    ; mov     rax, [input_buffer]
    ; print input_buffer, 1
    ; call print_endl
    call generate_board

    call print_matrix

    ; call print_endl

    sys_exit


struc Cell
.state: resb 1
endstruc

section .data
matrix: times BOARD_SIZE*BOARD_SIZE db 00100000b

section .bss
input_buffer: resb 1
print_row_buffer: resb (BOARD_SIZE+1)*BOARD_SIZE



