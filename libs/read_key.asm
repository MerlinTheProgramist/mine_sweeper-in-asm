
section .text
global _start

; sys_read can be used alone to read char after new line from tty
;
; enable_key_read modifies ICANON for terminal interface, 
; so that keys are read immedietly, without waiting for new line
; disable_key_read returns setting to state before editing it
; DISCLAIMER TESTED: it only works for current teminal emulator so, no need to worry about breaking things

; return to RAX
sys_read:
	push rbx
	push rdi
	push rdx
	push rsi

    sub     rsp, 8
	mov 	rax, 0
	mov 	rdi, 1
	mov		rsi, rsp ; stack pointer
	mov 	rdx, 1
	syscall
    pop     rax

	pop rsi
	pop rdx
	pop rdi
	pop rbx
	ret

enable_key_read:
	push rax
	push rbx
	push rcx
	push rdx
	push rsi
	push rdi

	; Get current settings
	mov  eax, 16             ; syscall number: SYS_ioctl
	mov  edi, 0              ; fd:      STDIN_FILENO
	mov  esi, 0x5401         ; request: TCGETS
	mov  rdx, termios        ; request data
	syscall
	; Modify flags
	and byte [termios + termios_type.c_lflag], 0FDh  ; Clear ICANON to disable canonical mode

	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop rbx
	pop rax
ret

disable_key_read:
	push rax
	push rbx
	push rcx
	push rdx
	push rsi
	push rdi

	; Write termios structure back
	mov  eax, 16             ; syscall number: SYS_ioctl
	mov  edi, 0              ; fd:      STDIN_FILENO
	mov  esi, 0x5402         ; request: TCSETS
	mov  rdx, termios        ; request data
	syscall

	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop rbx
	pop rax
ret


section .bss
; DECLARATIONS
struc termios_type
  .c_iflag: resd 1   ; input mode flags
  .c_oflag: resd 1   ; output mode flags
  .c_cflag: resd 1   ; control mode flags
  .c_lflag: resd 1   ; local mode flags
  .c_line:  resb 1   ; line discipline
  .c_cc:    resb 19  ; control characters
endstruc

; INSTANTIATION
termios: resb termios_type_size



