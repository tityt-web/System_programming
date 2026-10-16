format ELF64

public _start

include 'func.asm'

section '.data' writeable
    msg_usage db 'Usage: ./task_5 file1 file2 k m', 10, 0
    msg_err db 'Error: cannot open file', 10, 0

section '.bss' writeable
    sym rb 1                  ; прочитанный символ

section '.text' executable

_start:
    pop rcx
    cmp rcx, 5                ; имя программы + 4 параметра
    jne .usage
    mov rsi, [rsp+24]         ; k
    call str_to_int
    mov r12, rax
    mov rsi, [rsp+32]         ; m
    call str_to_int
    mov r13, rax

    mov rax, 2                ; sys_open первого файла на чтение
    mov rdi, [rsp+8]          ; имя первого файла
    mov rsi, 0                ; O_RDONLY
    syscall
    cmp rax, 0
    jl .error
    mov r8, rax               ; r8 - дескриптор первого файла

    mov rax, 2                ; sys_open второго файла на запись
    mov rdi, [rsp+16]         ; имя второго файла
    mov rsi, 577              ; O_WRONLY | O_CREAT | O_TRUNC
    mov rdx, 644o             ; права rw-r--r--
    syscall
    cmp rax, 0
    jl .error
    mov r9, rax               ; r9 - дескриптор второго файла

    mov rax, r12
    call copy_char            ; k-й символ
    mov r14, 1                ; r14 = i - смещение от k
.loop:
    cmp r14, r13              ; i > m - конец
    ja .close
    mov rax, r12
    add rax, r14
    call copy_char            ; символ k+i
    mov rax, r12
    sub rax, r14
    call copy_char            ; символ k-i
    inc r14
    jmp .loop

.close:
    mov rax, 3                ; sys_close
    mov rdi, r8
    syscall
    mov rax, 3
    mov rdi, r9
    syscall
    call exit

.usage:
    mov rsi, msg_usage
    call print_str
    call exit

.error:
    mov rsi, msg_err
    call print_str
    call exit

;вход: rax - позиция символа (с 1), копирует символ из r8 в r9, если он есть в файле
copy_char:
    cmp rax, 1                ; позиция левее начала файла - пропускаем
    jl .skip
    mov rsi, rax
    dec rsi                   ; смещение в файле с 0
    mov rax, 8                ; sys_lseek
    mov rdi, r8
    mov rdx, 0                ; SEEK_SET
    syscall
    mov rax, 0                ; sys_read одного символа
    mov rdi, r8
    mov rsi, sym
    mov rdx, 1
    syscall
    cmp rax, 1                ; позиция за концом файла - пропускаем
    jne .skip
    mov rax, 1                ; sys_write символа во второй файл
    mov rdi, r9
    mov rsi, sym
    mov rdx, 1
    syscall
.skip:
    ret
