section '.bss' writeable
    ch_buf rb 1               ; один прочитанный символ
    out_buf rb 24             ; буфер под цифры числа

section '.text' executable

;вход: нет, выход: rax - число, введенное с клавиатуры
read_int:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r15
    xor rbx, rbx              ; накапливаемое число
    xor r15, r15              ; r15 = 1, если цифры уже были
.next:
    mov rax, 0                ; sys_read
    mov rdi, 0                ; stdin
    mov rsi, ch_buf
    mov rdx, 1                ; читаем по одному символу
    syscall
    cmp rax, 1                ; конец ввода
    jl .done
    movzx rcx, byte [ch_buf]
    cmp rcx, '0'              ; не цифра - разделитель
    jb .sep
    cmp rcx, '9'
    ja .sep
    sub rcx, '0'              ; ASCII -> цифра
    imul rbx, 10              ; число * 10
    add rbx, rcx              ; + цифра
    mov r15, 1
    jmp .next
.sep:
    test r15, r15             ; пробел или '\n' после цифр - конец числа
    jz .next
.done:
    mov rax, rbx
    pop r15
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

;вход: rax - число со знаком для вывода
print_int:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    mov rdi, out_buf + 24     ; заполняем буфер с конца
    dec rdi
    mov byte [rdi], 10        ; в конце '\n'
    mov rcx, rax              ; запоминаем знак
    test rax, rax
    jns .digit
    neg rax                   ; берем модуль
.digit:
    xor rdx, rdx
    mov rbx, 10
    div rbx                   ; rdx - очередная цифра
    add dl, '0'
    dec rdi
    mov [rdi], dl
    test rax, rax
    jnz .digit
    test rcx, rcx             ; отрицательное - дописываем '-'
    jns .write
    dec rdi
    mov byte [rdi], '-'
.write:
    mov rdx, out_buf + 24
    sub rdx, rdi              ; длина строки
    mov rsi, rdi
    mov rax, 1                ; sys_write
    mov rdi, 1                ; stdout
    syscall
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

exit:
    mov rax, 60               ; sys_exit
    xor rdi, rdi
    syscall
