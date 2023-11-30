; most is taken from: https://asmtutor.com/
quit:
    mov eax, exitingMsg
    call sprintln

    mov ebx, 0
    mov eax, 1
    int 0x80
    ret

slen:
    push ebx
    mov ebx, eax

nextChar:
    cmp byte [eax], 0 ; if null byte
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
    call slen
 
    mov edx, eax
    pop eax
 
    mov ecx, eax
    mov ebx, 1
    mov eax, 4
    int 80h
 
    pop ebx
    pop ecx
    pop edx
    ret

; print but also add a newline
sprintln:
    call sprint
    push eax
    mov eax, 0Ah
    push eax
    mov eax, esp
    call sprint
    pop eax
    pop eax
    ret

noIp:
    mov eax, noIpMsg
    call sprint
    call quit

iprint:
    ; preserve registers
    push eax
    push ebx
    push ecx
    push edx

    mov ecx, 0 ; counter


divideLoop:
    inc ecx
    mov edx, 0
    mov esi, 10
    idiv esi
    add edx, 48         ; convert edx to it's ascii representation - edx holds the remainder after
    push edx
    cmp eax, 0
    jnz divideLoop

printLoop:
    dec ecx
    mov eax, esp
    call sprint
    pop eax
    cmp ecx, 0
    jnz printLoop

    ; restore registers
    pop edx
    pop ecx
    pop ebx
    pop eax

    ret

iprintln:
    call iprint
    push eax
    mov eax, 0Ah
    push eax
    mov eax, esp
    call sprint
    pop eax
    pop eax
    ret