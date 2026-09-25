format ELF64
public _start

N = 435

section '.data' writeable
    buf db N dup ('%')
    nl  db 10

section '.text' executable
_start:
    mov r12, 1                ; r12 - длина текущей строки
    mov r13, N                ; r13 - сколько символов осталось
row:
    cmp r12, r13              ; если осталось меньше, чем длина строки,
    jbe @f
    mov r12, r13              ; выводим сколько осталось
@@:
    mov rax, 1
    mov rdi, 1
    mov rsi, buf
    mov rdx, r12
    syscall
    mov rax, 1                ; перевод строки
    mov rdi, 1
    mov rsi, nl
    mov rdx, 1
    syscall
    sub r13, r12              ; вычитаем выведенные символы
    inc r12                   ; следующая строка на 1 длиннее
    test r13, r13
    jnz row
    mov rax, 60
    xor rdi, rdi
    syscall
