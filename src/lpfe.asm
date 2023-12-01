%include 'src/socket_errors.asm'

section .data
noIpMsg db "No IP address provided", 0Ah, 0x0
scanningMsg db "Scanning ", 0x0
doubleDot db ":", 0x0
exitingMsg db "Exiting", 0x0
successMsg db "Success ", 0x0

section .bss
ip_addr resb 32
port resb 8

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
    call sprintln

    mov edx, 8080 ; starting port

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
    
    ; decode ip address to int
    mov edi, [ip_addr]
    call str_to_int
    mov edi, eax

    ; move edi back
    mov edi, eax

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

str_to_int:
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx

next_digit:
    movzx edx, byte [edi + ecx]  ; Load the next byte (character) from the buffer into edx
    cmp dl, 0           ; Check if it's the null terminator (end of string)
    je  done             ; If it is, we are done

    sub dl, '0'         ; Convert ASCII character to integer ('0' -> 0, '1' -> 1, ..., '9' -> 9)
    imul eax, ebx        ; Multiply the current result by 10 (shift left by one decimal place)
    add eax, edx         ; Add the new digit to the result

    inc ecx             ; Move to the next character in the string
    jmp next_digit      ; Repeat the process for the next digit

done:
    ret