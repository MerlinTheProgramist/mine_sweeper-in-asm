; wersja NASM

section .text				; poczatek sekcji kodu
global _start				; symbol globalny dla linkera LD

_start:	

    mov     cx, 0           ; i = 0
_for:
    cmp     cx, 10          ; if (i >= 10)
    jae     _end_for        ;   goto end_for  
    push    cx

	mov		eax, 4			
	mov		ebx, 1			
	mov 	ecx, tekst  	; ECX = adres (offset) tekstu
	mov		edx, dlugosc	; EDC = długość tekstu
	int		80h				; wywołanie funkcji systemowej

    pop     cx
	inc     cx              ; i ++
	jmp     _for            ; goto for
_end_for:


	mov     eax, 1			; numer funkcji systemowej
							; (sys_exit - wyjdz z programu)
	int 	80h				; wywołanie funckji systemowej

section .data 				; poczatek sekcji danych

tekst 	db	"Iteracja", 0ah	; napis ktory wyswietlimy
dlugosc equ	$ - tekst		; dlugosc napisu

