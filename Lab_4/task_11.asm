format ELF64

public _start

include 'func.asm'

section '.text' executable

_start:
    call read_int
    mov r8, rax               ; r8 = n - число судей
    xor r9, r9                ; r9 - голоса "Да"
    xor r10, r10              ; r10 - голоса "Нет"
    xor r12, r12              ; r12 - номер судьи
.loop:
    cmp r12, r8               ; все проголосовали
    jge .decide
    call read_int             ; голос очередного судьи
    cmp rax, 1
    je .yes
    inc r10                   ; "Нет"
    jmp .next
.yes:
    inc r9                    ; "Да"
.next:
    inc r12
    jmp .loop
.decide:
    cmp r9, r10
    jg .accept                ; "Да" больше
    jl .reject                ; "Нет" больше
    mov rax, -1               ; поровну - решение не принято
    jmp .print
.accept:
    mov rax, 1
    jmp .print
.reject:
    mov rax, 0
.print:
    call print_int
    call exit
