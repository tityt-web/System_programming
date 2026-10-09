format ELF64

public _start

include 'func.asm'

section '.text' executable

_start:
    call read_int
    mov r8, rax               ; r8 = n
    xor r9, r9                ; r9 - счетчик подходящих чисел
    mov r10, 1                ; r10 - текущее число i
.loop:
    cmp r10, r8               ; i > n - конец
    jg .print

    mov rax, r10
    xor rdx, rdx
    mov rbx, 11
    div rbx                   ; i % 11
    test rdx, rdx
    jz .skip                  ; делится на 11 - не считаем

    mov rax, r10
    xor rdx, rdx
    mov rbx, 5
    div rbx                   ; i % 5
    test rdx, rdx
    jz .skip                  ; делится на 5 - не считаем

    inc r9                    ; не делится ни на 11, ни на 5
.skip:
    inc r10
    jmp .loop
.print:
    mov rax, r9
    call print_int
    call exit
