%include 'src/utils.asm'

section .data
noIpMsg db "No IP address provided", 0Ah

section .text
global _start

_start:
    pop ecx

    pop eax
    pop eax ; get second arg
    cmp eax, 0h
    jz noIp ; no ip provided
    call sprint ; debug

    mov edx, 0 ; starting port
    call _scanPort

    call quit

_scanPort:
    cmp edx, 65535
    jz quit

    inc edx
    call _scanPort