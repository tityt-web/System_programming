format ELF64
public _start

N = 435
M = 15
K = 29

section '.data' writeable
    buf db N dup ('%')        ; N символов в памяти
    nl  db 10

section '.text' executable
_start:
    mov r12, buf              ; r12 - начало текущей строки в памяти
    mov r13, K                ; r13 - сколько строк осталось
row:
    mov rax, 1                ; выводим M символов
    mov rdi, 1
    mov rsi, r12
    mov rdx, M
    syscall
    mov rax, 1                ; перевод строки
    mov rdi, 1
    mov rsi, nl
    mov rdx, 1
    syscall
    add r12, M                ; переходим к следующим M символам
    dec r13
    jnz row
    mov rax, 60
    xor rdi, rdi
    syscall
