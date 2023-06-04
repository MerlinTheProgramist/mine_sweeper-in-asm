section .text
global _start

%include "libs/macros.asm"

extern genRandSeed
extern nextRand

extern sys_read
extern enable_key_read
extern disable_key_read

extern print_endl
extern print_num



; Project DESCRIPTION:
; Each matrix cell stores information: 
;   - is_revealed
;   - has_bomb
;   - has_count (count is calculated on generation of the grid )

; TODO:
; - 

%define TRUE 1
%define FALSE 0


%define BOARD_SIZE 16 ; 2^n -1 max=127
%define NOMINAL    00000000b
%define REVEALED   10000000b
%define BOMB       01000000b
%define FLAGGED    00100000b

%define UNDEFINED_YET 00010000b ; UNDEFINED FLAG

%define HAS_COUNT  00001000b
%define COUNT_MASK 00000111b

%define NREV_CHAR '#'
%define BOMB_CHAR 'B'
%define FLAG_CHAR '%'
%define EMPT_CHAR '.'
%define ENDL_CHAR 0ah

%define ESC  0x1B
%define CURSOR_HIGHLIGHT_START "\e[3m"
%define CURSOR_HIGHLIGHT_START_LEN 5
%define CURSOR_HIGHLIGHT_END "\e[0m"
%define CURSOR_HIGHLIHGT_END_LEN 5

%define HALF_RAND 1008451927    ; mess with this value please



%macro add_bomb 1
    inc QWORD[bomb_count]
    mov QWORD[matrix+%1], BOMB
%endmacro


generate_board:
    mov QWORD[bomb_count], 0
    mov QWORD[revealed_counter], 0

    call genRandSeed; rax

    mov     rsi, BOARD_SIZE*BOARD_SIZE
    _gen_board_for:

        call    nextRand
        
        ; if rax > HARF_QWORD => matrix[rsi] = BOMB 
        ; else => matrix[ris] = NOMINAL
        cmp     rax, HALF_RAND
        ja  _gen_greater
            add_bomb rsi
            jmp _gen_greater_skip
        _gen_greater:
        mov     BYTE[matrix + rsi], NOMINAL
        _gen_greater_skip:

        dec     rsi
        cmp     rsi, 0
        jnl _gen_board_for


    ; add_bomb 1
    ; add_bomb BOARD_SIZE+4

    ; add_bomb BOARD_SIZE*2+10
    add_bomb BOARD_SIZE*4+10
    add_bomb BOARD_SIZE*3+11

    add_bomb BOARD_SIZE*3+BOARD_SIZE-1
    add_bomb BOARD_SIZE-1
    
    gen_count:
        ; if matrix index is negative or greater than BOARF_SIZE**2 then its invalid

        ; O | O | O
        ; O | X | O
        ; O | O | O

        ; if x == BOARD_SIZE
        ;     then dont check right
        ; if x % BOARD_SI
        %define TOP    10000000
        %define BOTTOM 01000000
        %define LEFT   00100000
        %define RIGHT  00010000
        xor     r8,  r8  ; in r8 we store if cell is border case
        xor     rdx, rdx
        xor     rcx, rdx

        ; this is the first row from BOTTOM
        or     r8, BOTTOM

        ; start from BOARD_SIZE-1 to exclude borders
        mov     dl, BOARD_SIZE-1; y
        full:
        ; while dl >= 0
        .for_y

            or     r8, RIGHT
            and    r8, ~LEFT

            mov     cl, BOARD_SIZE-1; x    
            .for_x

                ; sounding cell
                xor    rax, rax
                mov    al, dl
                mov    bl, BOARD_SIZE
                mul    bl ; ax *= BOARD_SIZE
                add    ax, cx
                lea    rax, BYTE[matrix + rax] ; load address of THIS cell to rax  
                push   rax      ; save the original address
                
                mov    rbx, -1; set count to minimum <=> -1

                ; check every address around
                ; |←|←|←| 
                ; |←|x |→|
                ; |→|→|→|
                ; inc rbx if BOMB

                test   r8, LEFT
                jnz    .l


                test   BYTE[rax-1], BOMB
                jz     .l
                    inc rbx
                .l

                test    r8, TOP     
                jnz    .tl          ; skip all top checks

                test    r8, RIGHT
                jnz    .tr   

                test   BYTE[rax - BOARD_SIZE + 1], BOMB
                jz     .tr
                    inc rbx
                .tr

                test   BYTE[rax - BOARD_SIZE], BOMB
                jz     .t
                    inc rbx
                .t
                
                test   r8, LEFT
                jnz .tl              

                test   BYTE[rax - BOARD_SIZE - 1], BOMB
                jz     .tl
                    inc rbx
                .tl


                test    r8, RIGHT
                jnz    .r

                
                test   BYTE[rax + 1], BOMB
                jz     .r
                    inc rbx
                .r

                test   r8, BOTTOM
                jnz .br          ; skip all bottom checks   

                test   r8, LEFT
                jnz .bl              
                
                test   BYTE[rax + BOARD_SIZE - 1], BOMB
                jz     .bl
                    inc rbx
                .bl

                test   BYTE[rax + BOARD_SIZE], BOMB
                jz     .b
                    inc rbx
                .b
                
                test   r8, RIGHT
                jnz .br     

                test   BYTE[rax + BOARD_SIZE + 1], BOMB
                jz     .br
                    inc rbx
                .br


                pop    rax          ; restore ariginal cell address
                
                ; if no-bombs <=> rbx == -1
                ; then do nothing
                cmp    rbx, -1
                je    .skip_cell           

                ; set HAS_COUNT flag and the actuall COUNT
                or     BYTE[rax], HAS_COUNT
                or     BYTE[rax], bl; assuming that COUNT section is 0
                
                .skip_cell          

            and r8, ~RIGHT

            dec cl
            cmp cl, 0
            jnz .not_last_x ; if 0 then mark LEFT border
                or  r8, LEFT ; modifies flags
                cmp cl, 0
            .not_last_x
            jge    .for_x

        and r8, ~BOTTOM

        dec dl
        cmp dl, 0
        jnz .not_last_y ; if 0 then mark TOP border
            or   r8, TOP ; modifies flags
            cmp dl, 0
        .not_last_y
        jge    .for_y
    
    ret


print_matrix:
    ;clear_term
    
    xor     r8, r8 ; zero the index
    xor     r15,r15

    ; for y in 0..BOARD_SIZE
    xor     rsi, rsi
    .y:
        ; for x in 0..BOARD_SIZE
        xor     rdi, rdi
        .x:
            push rsi
            push rdi

            ; sounding cell
            mov    rax, rsi
            mov    rbx, BOARD_SIZE
            mul    rbx ;rax *= BOARD_SIZE
            add    rax, rdi
            mov    al, BYTE[matrix + rax] ; could swap for lea            

            cmp    sil, [cursor_pos + Pos.y]                                    ; if its the cursor pos.y
            jnz _not_cursor
            cmp    dil, [cursor_pos + Pos.x]                                    ; if its the cursor pos.x
            jnz _not_cursor
                %define START_H  0x31335b1b
                %define START_H2 0x6d ; len 5
                mov     DWORD[print_buffer + r8], START_H; split this color code on two moves because it is not a power of 2 len
                mov     BYTE[print_buffer + r8 + 4], START_H2
                add     r8, 5               ; calculate print_index
                mov     r15, 1              ; mark a cursor :)
            _not_cursor:
            
            test    al, FLAGGED                                            ; if is bomb
            jz _not_flag                                                
                mov     BYTE[print_buffer + r8], FLAG_CHAR              ; print_row_buffer[rdi] = BOMB_CHAR
                jmp     _pm_for_continue                                ; continue
            _not_flag:
 

            test   al, REVEALED                                         ; if is not revealed
            jnz _rev
                mov     BYTE[print_buffer + r8], NREV_CHAR              ; print_row_buffer[rdi] = NREV_CHAR
                jmp     _pm_for_continue                                ; continue
            _rev:


            test    al, BOMB                                            ; if is bomb
            jz _not_bomb                                                
                mov     BYTE[print_buffer + r8], BOMB_CHAR              ; print_row_buffer[rdi] = BOMB_CHAR
                jmp     _pm_for_continue                                ; continue
            _not_bomb:


            test    al, HAS_COUNT                                       ; if count exists
            jz _not_count
                and     al, COUNT_MASK     
                add     al, '1'
                mov     BYTE[print_buffer + r8], al                     ; print_row_buffer[rdi] = COUNT_MASK AND [`1`-`8`] 
                jmp     _pm_for_continue                                ; continue
            _not_count:
            
            mov     BYTE[print_buffer + r8], EMPT_CHAR                  ; print_row_buffer[rdi] = EMPT_CHAR

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
            jnz print_matrix.x    

        mov    BYTE[print_buffer+r8], ENDL_CHAR
        inc    r8               ; inc print_buffer_index because of ENDLINE

        inc    rsi
        cmp    rsi, BOARD_SIZE
        jnz print_matrix.y
    

    ; print rows buffer
    print  print_buffer, print_buffer_len
    ret

game_over:
    call print_endl
    call print_matrix

    print game_over_text,  game_over_len
    
    sys_exit
ret

game_win:
    call print_endl
    call print_matrix

    print game_win_text, game_win_len

    sys_exit

%macro jump_if_pos_invalid 1
    cmp cl, BOARD_SIZE
    je  %1
    cmp cl, 0
    jl  %1

    cmp dl, BOARD_SIZE
    je  %1
    cmp dl, 0
    jl  %1
%endmacro


; cl for x
; dl for y
; rax return
is_pos_valid:
    cmp cl, BOARD_SIZE
    je  is_pos_valid.invalid
    cmp cl, 0
    jl  is_pos_valid.invalid

    cmp dl, BOARD_SIZE
    je  is_pos_valid.invalid
    cmp dl, 0
    jl  is_pos_valid.invalid

    .valid
    mov     rax, 1
ret 
    .invalid
    xor     rax, rax
ret

; reveal tile on:
; cl for x
; dl for y
; r8 for auto: 1 for auto
reveal:
    push rax
    push rbx
    push rcx
    push rdx
    push r8

    call is_pos_valid ; if position not valid then return
    test  rax, rax
    jz reveal.nothing
        
    ; selected cell rax
    xor    rax, rax
    mov    al, dl
    mov    bl, BOARD_SIZE
    mul    bl ;ax = al * BOARD_SIZE
    add    al, cl

    xor    rbx, rbx
    mov    bl, BYTE[matrix + rax]


    test    bl, BOMB ; if BOMB
    jz     reveal.not_bomb
        test   r8, r8                ; if clicked <=> r8 = 0
        jnz    .nothing              ; if auto and bomb then dont reveal other
            or    byte[matrix + rax], REVEALED
            and   byte[matrix + rax], ~FLAGGED
            call game_over           ; then game over
    .not_bomb:

    ; do nothing when tile is revealed, if either cursor or auto
    test    bl, REVEALED
    jnz     reveal.nothing
    

    ; firstly reveal this tile and clear FLAG
    or    byte[matrix + rax], REVEALED
    and   byte[matrix + rax], ~FLAGGED

    ; update revealed counter
    inc QWORD[revealed_counter]

    ; if count: then stop revealing more
    test    bl, HAS_COUNT
    jnz     reveal.nothing

    ; reveal all neighbors
    mov r8, 1 ; as auto
    
    ; north
    dec dl   
    call reveal
    ; east
    inc  dl   
    inc  cl   
    call reveal
    ; south
    inc  dl
    dec  cl   
    call reveal
    ; west
    dec  dl 
    dec  cl   
    call reveal
    
    .nothing:
    pop r8
    pop rdx
    pop rcx
    pop rbx
    pop rax    
ret

flag:
    ; selected cell rax
    xor    rax, rax
    mov    al, [cursor_pos+Pos.y]
    mov    bl, BOARD_SIZE
    mul    bl ;ax = al * BOARD_SIZE
    add    al, [cursor_pos+Pos.x]

    test BYTE[matrix + rax], REVEALED
    jnz flag.nothing

    xor   BYTE[matrix + rax], FLAGGED

    flag.nothing:
ret


_start:

    ; call sys_read
    ; mov     rax, [input_buffer]
    ; print input_buffer, 1
    ; call print_endl
    
    call generate_board
    
    
    
    ; mov  cl, 1
    ; mov  dl, 0
    ; xor  r8, r8
    ; call reveal


    _game_loop:
        call print_matrix

        input:
        call enable_key_read
        call sys_read
        call disable_key_read

            xor     rdx, rdx
            cmp     rax, 119
            jnz input.w
                dec dl
                jmp .move_resolve
            .w:
            cmp     rax, 's'
            jnz input.s
                inc dl
                jmp .move_resolve
            .s:
            cmp     rax, 'a'
            jnz input.a
                dec dh
                jmp .move_resolve
            .a:
            cmp     rax, 'd'
            jnz input.d
                inc dh
                jmp .move_resolve
            .d:
            cmp     rax, 'r'
            jnz input.e
                mov  cl, [cursor_pos+Pos.x]
                mov  dl, [cursor_pos+Pos.y]
                xor  r8, r8
                call reveal

                ; if revealed_counter + bomb_count = BOARD_SIZE*BOARD_SIZE
                mov  rax,   [revealed_counter]
                add  rax,   [bomb_count]
                cmp  rax,   BOARD_SIZE*BOARD_SIZE
                jne input.end
                    call game_win
                jmp input.end
            .e:
            cmp     rax, 'f'
            jnz input.f
                call flag
                jmp input.end
            .f:
            ; if nothing from supported symboles was used 
            jmp input   ; read input again

            .move_resolve
        
            add dl, byte[cursor_pos+Pos.y]  ; temporary add
            add dh, byte[cursor_pos+Pos.x]  ; temporary add
            ; if (y == SIZE or y<0) then dont save y to mem
            cmp dl, BOARD_SIZE 
            je .dont_change_y
            cmp dl, 0
            jl .dont_change_y
                mov byte[cursor_pos+Pos.y], dl
            .dont_change_y:
            ; if (x == SIZE or x<0) then dont save x to mem
            cmp dh, BOARD_SIZE 
            je .dont_change_x
            cmp dh, 0
            jl .dont_change_x
                mov byte[cursor_pos+Pos.x], dh
            .dont_change_x:
        
        .end:


        call print_endl

        mov  rax, [revealed_counter]
        call print_num
        call print_endl

        mov  rax, [bomb_count]
        call print_num
        call print_endl
    
    jmp _game_loop

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

game_over_text db ENDL_CHAR,"Game over, you encounter a mine!", ENDL_CHAR
game_over_len equ $-game_over_text

game_win_text db ENDL_CHAR,"YOU WON! Congratulations and have a great day", ENDL_CHAR
game_win_len equ $-game_win_text

debug_text db ENDL_CHAR,"THIS IS A DEBUG MESSEGE", ENDL_CHAR
debug_text_len equ $-debug_text

section .bss
input_buffer: resb 1


print_buffer: resb (BOARD_SIZE+1)*BOARD_SIZE + 10
print_buffer_len: equ $print_buffer
; print_index: resq 1

cursor_pos: resb 2
; cursor_blink: resb 1

bomb_count: resq 1
revealed_counter: resq 1