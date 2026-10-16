format ELF64

public _start

include 'func.asm'

section '.data' writeable
    msg_f1 db 'File for all primes: ', 0
    msg_f2 db 'File for primes ending in 1: ', 0
    msg_n db 'n = ', 0
    msg_err db 'Error: cannot open file', 10, 0
    new_line db 10

section '.bss' writeable
    name1 rb 256              ; имя первого файла
    name2 rb 256              ; имя второго файла
    num_str rb 32             ; строка с n
    buf rb 4096               ; буфер для чтения первого файла
    line rb 32                ; текущее число из файла

section '.text' executable

_start:
    mov rsi, msg_f1           ; ввод имени первого файла
    call print_str
    mov rsi, name1
    mov rdx, 256
    call read_line
    mov rsi, msg_f2           ; ввод имени второго файла
    call print_str
    mov rsi, name2
    mov rdx, 256
    call read_line
    mov rsi, msg_n            ; ввод n
    call print_str
    mov rsi, num_str
    mov rdx, 32
    call read_line
    call str_to_int
    mov r12, rax              ; r12 = n

    mov rax, 2                ; sys_open первого файла на запись
    mov rdi, name1
    mov rsi, 577              ; O_WRONLY | O_CREAT | O_TRUNC
    mov rdx, 644o
    syscall
    cmp rax, 0
    jl .error
    mov r8, rax               ; r8 - дескриптор первого файла

    mov r13, 2                ; r13 - проверяемое число
.primes:
    cmp r13, r12              ; дошли до n
    ja .primes_done
    mov rax, r13
    call is_prime
    test rax, rax
    jz .next_num
    mov rax, r13
    call int_to_str           ; простое число -> строка
    mov rax, 1                ; sys_write числа в первый файл
    mov rdi, r8
    syscall
    mov rax, 1                ; sys_write '\n'
    mov rdi, r8
    mov rsi, new_line
    mov rdx, 1
    syscall
.next_num:
    inc r13
    jmp .primes
.primes_done:
    mov rax, 3                ; sys_close первого файла
    mov rdi, r8
    syscall

    mov rax, 2                ; повторно открываем первый файл на чтение
    mov rdi, name1
    mov rsi, 0                ; O_RDONLY
    syscall
    cmp rax, 0
    jl .error
    mov r8, rax

    mov rax, 2                ; sys_open второго файла на запись
    mov rdi, name2
    mov rsi, 577
    mov rdx, 644o
    syscall
    cmp rax, 0
    jl .error
    mov r9, rax               ; r9 - дескриптор второго файла

    xor r14, r14              ; r14 - длина текущего числа в line
.read:
    mov rax, 0                ; sys_read порции первого файла
    mov rdi, r8
    mov rsi, buf
    mov rdx, 4096
    syscall
    cmp rax, 0                ; конец файла
    jle .finish
    mov r15, rax              ; r15 - прочитано байт
    xor rbx, rbx              ; rbx - индекс в буфере
.scan:
    cmp rbx, r15
    jge .read
    mov al, [buf+rbx]
    inc rbx
    cmp al, 10                ; конец строки - число прочитано
    je .check
    mov [line+r14], al        ; копируем цифру в line
    inc r14
    jmp .scan
.check:
    test r14, r14             ; пустая строка
    jz .scan
    cmp byte [line+r14-1], '1'  ; последняя цифра - 1
    jne .reset
    mov byte [line+r14], 10   ; дописываем '\n'
    mov rax, 1                ; sys_write числа во второй файл
    mov rdi, r9
    mov rsi, line
    lea rdx, [r14+1]
    syscall
.reset:
    xor r14, r14
    jmp .scan

.finish:
    mov rax, 3                ; sys_close обоих файлов
    mov rdi, r8
    syscall
    mov rax, 3
    mov rdi, r9
    syscall
    call exit

.error:
    mov rsi, msg_err
    call print_str
    call exit

;вход: rax - число (>= 2), выход: rax = 1 - простое, 0 - составное
is_prime:
    push rbx
    push rcx
    push rdx
    mov rcx, rax              ; rcx - проверяемое число
    mov rbx, 2                ; rbx - делитель
.try:
    mov rax, rbx
    mul rbx                   ; делитель^2
    cmp rax, rcx              ; делитель^2 > числа - делителей нет
    ja .prime
    mov rax, rcx
    xor rdx, rdx
    div rbx
    test rdx, rdx             ; делится без остатка - составное
    jz .not_prime
    inc rbx
    jmp .try
.prime:
    mov rax, 1
    jmp .ret
.not_prime:
    xor rax, rax
.ret:
    pop rdx
    pop rcx
    pop rbx
    ret
