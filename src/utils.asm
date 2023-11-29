;https://asmtutor.com/

quit:
    mov ebx, 0
    mov eax, 1
    int 0x80
    ret

strlen:
    push ebx
    mov ebx, eax

nextChar:
    cmp byte [eax], 0
    jz finished
    inc eax
    jmp nextChar

finished:
    sub eax, ebx
    pop ebx
    ret

sprint:
    push edx
    push ecx
    push ebx
    push eax
    call strlen

    mov edx, eax
    pop eax

    mov ecx, eax
    mov ebx, 1
    mov eax, 4
    int 0x80

    pop ebx
    pop ecx
    pop edx

    ret