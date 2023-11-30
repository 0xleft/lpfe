%include 'src/socket_errors.asm'

section .data
noIpMsg db "No IP address provided", 0Ah, 0x0
scanningMsg db "Scanning ", 0x0
doubleDot db ":", 0x0
exitingMsg db "Exiting", 0x0

section .bss
ip resb 16

section .text
global _start

_start:

    pop ecx

    pop eax
    pop eax ; get second arg
    cmp eax, 0h
    jz noIp ; no ip provided

    mov [ip], eax
    ; debug
    call sprintln

    mov edx, 8080 ; starting port

    call _scanPortImpl

    call quit

_scanPorts:
    cmp edx, 65535
    jz quit

    mov eax, edx
    call iprintln

    call _scanPortImpl

    inc edx
    call _scanPorts

; socket -> connect -> close
; if connect doesnt fail print port
_scanPortImpl:
    push edx

    call _socket
    mov ebx, eax ; save socket descriptor
    call _connect

    pop edx
    ret

_socket:
    mov eax, 0x66      ; socketcall syscall number
    mov ebx, 0x1       ; socketcall socket
    xor edx, edx
    ; push edx

    ; cmp eax, 0x0
    ; jl socketCreateError

    ret

_connect:
    cmp eax, 0x0
    jl socketConnectError

    ret