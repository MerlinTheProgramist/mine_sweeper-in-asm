section .text
global _start

%include "libs/macros.asm"
extern nextRand

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
%define FLAGGED    00100000b
%define CURSOR     00010000b
%define HAS_COUNT  00001000b
%define COUNT_MASK 00000111b

%define NREV_CHAR '#'
%define BOMB_CHAR '*'
%define EMPT_CHAR ' '
%define ENDL_CHAR 0ah

%define ESC  0x1B
%define CURSOR_HIGHLIGHT_START "\e[3m"
%define CURSOR_HIGHLIGHT_START_LEN 5
%define CURSOR_HIGHLIGHT_END "\e[0m"
%define CURSOR_HIGHLIHGT_END_LEN 5

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
        cmp     rax, 1599903625
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
    clear_term
    xor     r8, r8 ; zero the index
    xor     r15,r15

    ; for y in 0..BOARD_SIZE
    xor     rsi, rsi
    _pm_for_y:
        ; for x in 0..BOARD_SIZE
        xor     rdi, rdi
        _pm_for_x:
            push rsi
            push rdi

            ; sounding cell
            mov    rax, rsi
            mov    rbx, BOARD_SIZE
            mul    rbx ;rax *= BOARD_SIZE
            add    rax, rdi
            mov    al, BYTE[matrix + rax] ; could swap for lea            
            
                                             ; not a cursor

            cmp    rsi, [cursor_pos + Pos.y]                                    ; if its the cursor pos.y
            jnz _not_cursor
            cmp    rdi, [cursor_pos + Pos.x]                                    ; if its the cursor pos.x
            jnz _not_cursor
                %define START_H  0x31335b1b
                %define START_H2 0x6d ; len 5
                mov     DWORD[print_buffer + r8], START_H;ESC | "[31"<<8 | 'm'<<24                        ; split this color code on two moves because it is not a power of 2 len
                mov     BYTE[print_buffer + r8 + 4], START_H2
                add     r8, 5               ; calculate print_index
                mov     r15, 1                                           ; a cursor :)
            _not_cursor:
            

            test   al, REVEALED                                         ; if is not revealed
            jnz _rev
                mov     BYTE[print_buffer + r8], NREV_CHAR     ; print_row_buffer[rdi] = NREV_CHAR
                jmp     _pm_for_continue                                ; continue
            _rev:


            test    al, BOMB                                            ; if is bomb
            jz _not_bomb                                                
                mov     BYTE[print_buffer + r8], BOMB_CHAR   ; print_row_buffer[rdi] = BOMB_CHAR
                jmp     _pm_for_continue                                ; continue
            _not_bomb:


            test    al, HAS_COUNT                                       ; if count exists
            jz _not_count
                and     al, COUNT_MASK     
                add     al, '1'
                mov     BYTE[print_buffer + r8], al          ; print_row_buffer[rdi] = COUNT_MASK AND [`1`-`8`] 
                jmp     _pm_for_continue                                ; continue
            _not_count:
            

            mov     BYTE[print_buffer + r8], EMPT_CHAR       ; print_row_buffer[rdi] = ' '

            _pm_for_continue:
            inc    r8           ; inc print_buffer_index 
            ; end cursor highlight if needed
            cmp     r15, 1
            jnz __not_cursor
                %define END_H 0x6d305b1b ; len 4
                mov     DWORD[print_buffer + r8], END_H ;ESC | '[0'<<8 
                ;mov     BYTE[print_buffer + r8 + 4], "m"
                add     r8, 4
                xor    r15, r15
            __not_cursor:


            pop    rdi
            pop    rsi

            inc    rdi
            cmp    rdi, BOARD_SIZE
            jnz _pm_for_x    

        mov    BYTE[print_buffer+r8], ENDL_CHAR
        inc    r8               ; inc print_buffer_index because of ENDLINE

        inc    rsi
        cmp    rsi, BOARD_SIZE
        jnz _pm_for_y

    
    

    ; print rows buffer
    print  print_buffer, print_buffer_len
    ret

uncover_action:
    

_start:

    ; call sys_read
    ; mov     rax, [input_buffer]
    ; print input_buffer, 1
    ; call print_endl
    call generate_board

    xor  rcx, rcx
    
    


    call print_matrix

    ; call print_endl

    sys_exit


struc Cell
    .state: resb 1
endstruc

struc Pos
    .y: resb 1
    .x: resb 1
endstruc


section .data
matrix: times BOARD_SIZE*BOARD_SIZE db 00100000b



section .bss
input_buffer: resb 1


print_buffer: resb (BOARD_SIZE+1)*BOARD_SIZE + 10
print_buffer_len: equ $print_buffer
; print_index: resq 1

cursor_pos: resb 2
; cursor_blink: resb 1



