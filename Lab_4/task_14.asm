format ELF64

public _start

include 'func.asm'

section '.text' executable

_start:
    call read_int
    mov r8, rax               ; r8 = n
    mov r9, 1                 ; r9 - текущее число k
.loop:
    cmp r9, r8                ; k > n - конец
    jg .end

    mov r10, 10               ; r10 = 10^(кол-во цифр k)
.pow:
    cmp r10, r9
    jg .check
    imul r10, 10
    jmp .pow
.check:
    mov rax, r9
    mul r9                    ; rax = k^2
    xor rdx, rdx
    div r10                   ; rdx = последние разряды k^2
    cmp rdx, r9               ; совпадают с k
    jne .next
    mov rax, r9
    call print_int            ; печатаем найденное число
.next:
    inc r9
    jmp .loop
.end:
    call exit
