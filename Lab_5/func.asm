section '.bss' writeable
    num_buf rb 24             ; буфер под цифры числа

section '.text' executable

;вход: rsi - адрес строки, выход: rax - число из строки
str_to_int:
    push rbx
    push rcx
    xor rax, rax              ; накапливаемое число
    xor rcx, rcx              ; индекс символа
.loop:
    movzx rbx, byte [rsi+rcx]
    cmp rbx, '0'              ; не цифра - конец числа
    jb .done
    cmp rbx, '9'
    ja .done
    sub rbx, '0'              ; ASCII -> цифра
    imul rax, 10              ; число * 10
    add rax, rbx              ; + цифра
    inc rcx
    jmp .loop
.done:
    pop rcx
    pop rbx
    ret

;вход: rax - число, выход: rsi - адрес строки с цифрами, rdx - длина строки
int_to_str:
    push rax
    push rbx
    push rdi
    mov rdi, num_buf + 24     ; заполняем буфер с конца
    mov rbx, 10
.digit:
    xor rdx, rdx
    div rbx                   ; rdx - очередная цифра
    add dl, '0'
    dec rdi
    mov [rdi], dl
    test rax, rax
    jnz .digit
    mov rsi, rdi
    mov rdx, num_buf + 24
    sub rdx, rdi              ; длина строки
    pop rdi
    pop rbx
    pop rax
    ret

;вход: rsi - адрес строки, заканчивающейся нулём
print_str:
    push rax
    push rdi
    push rdx
    push rcx
    push r11
    xor rdx, rdx
.len:
    cmp byte [rsi+rdx], 0     ; считаем длину строки
    je .write
    inc rdx
    jmp .len
.write:
    mov rax, 1                ; sys_write
    mov rdi, 1                ; stdout
    syscall
    pop r11
    pop rcx
    pop rdx
    pop rdi
    pop rax
    ret

;вход: rsi - буфер, rdx - размер буфера, выход: строка с клавиатуры без '\n', заканчивается нулём
read_line:
    push rax
    push rbx
    push rdi
    push rcx
    push r11
    push rdx
    push rsi
    mov rbx, rsi              ; rbx - текущая позиция в буфере
    lea rcx, [rsi+rdx-1]      ; последнее место под завершающий ноль
.next:
    cmp rbx, rcx              ; буфер заполнен
    jae .done
    push rcx
    mov rax, 0                ; sys_read одного символа
    mov rdi, 0                ; stdin
    mov rsi, rbx
    mov rdx, 1
    syscall
    pop rcx
    cmp rax, 1                ; конец ввода
    jl .done
    cmp byte [rbx], 10        ; '\n' - конец строки
    je .done
    inc rbx
    jmp .next
.done:
    mov byte [rbx], 0         ; завершаем строку нулём
    pop rsi
    pop rdx
    pop r11
    pop rcx
    pop rdi
    pop rbx
    pop rax
    ret

exit:
    mov rax, 60               ; sys_exit
    xor rdi, rdi
    syscall
