%include 'src/socket_errors.asm'

section .data
noIpMsg db "No IP address provided", 0Ah, 0x0
scanningMsg db "Scanning ", 0x0
doubleDot db ":", 0x0
exitingMsg db "Exiting", 0x0
successMsg db "Port open: ", 0x0

section .bss
ip_addr resb 32
port resb 8
ip_result resb 32

section .text
global _start

_start:

    xor     eax, eax            ; init eax 0
    xor     ebx, ebx            ; init ebx 0
    xor     edi, edi            ; init edi 0
    xor     esi, esi            ; init esi 0

    pop ecx ; get argc
    pop eax
    pop eax ; get second arg
    cmp eax, 0h
    jz noIp ; no ip provided

    mov [ip_addr], eax ; set ip address

    call iprintln

    mov edx, 21 ; starting port

    call _scanPorts

    ; exit
    call quit

_scanPorts:
    cmp edx, 65535 ; max port
    jz quit

    mov [port], edx ; set port
    call _scanPortImpl

    inc edx
    call _scanPorts

    ret

; socket -> connect -> close
; if connect doesnt fail print port
_scanPortImpl:
    push edx

    call _socket
    mov ebx, eax ; save socket descriptor
    call _connect
    call _close

    pop edx
    ret

_socket:
    push    byte 6              ; push 6 onto the stack (IPPROTO_TCP)
    push    byte 1              ; push 1 onto the stack (SOCK_STREAM)
    push    byte 2              ; push 2 onto the stack (PF_INET)
    mov     ecx, esp            ; move address of arguments into ecx
    mov     ebx, 1              ; invoke subroutine SOCKET (1)
    mov     eax, 102            ; invoke SYS_SOCKETCALL (kernel opcode 102)
    int     80h                 ; call the kernel

    cmp eax, 0x0
    jl socketCreateError

    add esp, 12 ; move stack pointer back

    ret

_connect:
    mov     edi, eax            ; move return value of SYS_SOCKETCALL into edi (file descriptor for new socket, or -1 on error)
    
    mov     eax, 0x00000000      ; move ip address into eax
    push    dword eax         ; push ip address onto stack
    push    word [port]
    push    word 2              ; push 2 dec onto stack AF_INET
    mov     ecx, esp            ; move address of stack pointer into ecx
    push    byte 16             ; push 16 dec onto stack (arguments length)
    push    ecx                 ; push the address of arguments onto stack
    push    edi                 ; push the file descriptor onto stack
    mov     ecx, esp            ; move address of arguments into ecx
    mov     ebx, 3              ; invoke subroutine CONNECT (3)
    mov     eax, 102            ; invoke SYS_SOCKETCALL (kernel opcode 102)
    int     80h                 ; call the kernel

    cmp eax, 0x0
    jnl .success

    add esp, 20 ; move stack pointer back

    ret

.success:
    mov eax, successMsg
    call sprint

    mov eax, [port]
    call iprintln

    add esp, 20 ; move stack pointer back

    ret

_close:
    mov     ebx, edi            ; move edi into ebx (connected socket file descriptor)
    mov     eax, 6              ; invoke SYS_CLOSE (kernel opcode 6)
    int     80h                 ; call the kernel

    cmp eax, 0x0
    jl socketCloseError

    ret