; wersja NASM

section .text				; poczatek sekcji kodu
global _start				; symbol globalny dla linkera LD

_start:	
	mov 	rax, 1		    ; sys_write
	mov     rdi, 1			; std_out
	mov 	rsi, tekst		; char*
	mov 	rdx, dlugosc	; size
	syscall		

section .data 				; poczatek sekcji danych

tekst db	"Czesc", 0ah	; napis ktory wyswietlimy
dlugosc equ	$ - tekst		; dlugosc napisu

