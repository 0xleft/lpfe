section .data
prompt db "Enter something: ", 0 ; or 0 to make no newline
prompt_len equ $ - prompt

section .bss
input resb 256 ; buffer for user input

section .text        
global _start

_start:
    ; print prompt
    mov edx, prompt_len
    mov ecx, prompt
    mov ebx, 1
    mov eax, 4
    int 0x80

    ; read user input
    mov edx, 256
    mov ecx, input
    mov ebx, 0 ; set file descriptor to 0 for input
    mov eax, 3
    int 0x80

    ; print for debug
    mov edx, 256
    mov ecx, input
    mov ebx, 2 ; set file descriptor to 2 for stderr
    mov eax, 4
    int 0x80

    ; exit
    mov eax, 1
    int 0x80