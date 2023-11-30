%include 'src/utils.asm'

section .data
socketErrorMsg db "Socket error", 0x0
socketCreateErrorMsg db "Socket creation error", 0x0
socketConnectErrorMsg db "Socket connection error", 0x0

socketCreateError:
    mov eax, socketCreateErrorMsg
    call sprintln
    call quit

socketConnectError:
    mov eax, socketConnectErrorMsg
    call sprintln
    call quit