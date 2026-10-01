format ELF64
public _start

section '.data' writeable
    buf rb 20                 ; буфер под цифры числа
    nl db 10                  ; символ перевода строки

section '.text' executable
_start:
    mov rcx, [rsp]            ; argc
    cmp rcx, 2                ; нужен ровно один аргумент
    jl exit
    mov rsi, [rsp + 16]       ; argv[1] - указатель на строку
    movzx rax, byte [rsi]     ; ASCII-код первого символа
    call print_num
exit:
    mov rax, 60               ; sys_exit
    xor rdi, rdi
    syscall

;вход: rax - число для вывода
print_num:
    mov rdi, buf + 20         ; заполняем буфер с конца
    mov rbx, 10               ; делитель - основание СС
digit:
    xor rdx, rdx
    div rbx                   ; rax = частное, rdx = очередная цифра
    add dl, '0'               ; цифра -> ASCII
    dec rdi
    mov [rdi], dl
    test rax, rax             ; пока частное не ноль
    jnz digit
    mov rdx, buf + 20
    sub rdx, rdi              ; длина числа
    mov rsi, rdi
    mov rax, 1                ; sys_write
    mov rdi, 1                ; stdout
    syscall
    mov rax, 1                ; выводим '\n'
    mov rdi, 1
    mov rsi, nl
    mov rdx, 1
    syscall
    ret
