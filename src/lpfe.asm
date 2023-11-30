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

    call quit

noIp:
    mov eax, noIpMsg
    call sprint
    call quit