format ELF64 executable 3

segment readable writeable
msg db 'Korykhov', 10, 'Ivan', 10, 'Andreevich', 10
msg_len = $ - msg

segment readable executable
_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, msg_len
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall
