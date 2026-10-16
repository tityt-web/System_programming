format elf64
public _start

include 'func.asm'

section '.data' writable
  msg_err db "Usage: ./reverse_sum n", 0x0a, 0

section '.bss' writable
  place rb 32

section '.text' executable

_start:
  ;Считываем количество параметров командной строки
  pop rcx
  cmp rcx, 2
  jne .error

  ;Переводим параметр n из строки в число
  mov rsi, [rsp+8]
  call str_number
  ;r8 - верхняя граница n
  mov r8, rax

  ;r9 - накапливаемая сумма, rcx - текущее число k
  xor r9, r9
  mov rcx, 1
  mov rbx, 10
.loop:
  ;Если k > n - заканчиваем суммирование
  cmp rcx, r8
  ja .print
  mov rax, rcx
  ;r10 - реверсированное число
  xor r10, r10
  .rev:
    ;Отделяем последнюю цифру числа (остаток в rdx)
    xor rdx, rdx
    div rbx
    ;r10 = r10*10 + цифра
    imul r10, r10, 10
    add r10, rdx
    ;Пока в числе остались цифры - продолжаем
    cmp rax, 0
    jne .rev
  ;Прибавляем реверсированное число к сумме
  add r9, r10
  inc rcx
  jmp .loop

.print:
  ;Переводим сумму в строку и выводим на экран
  mov rax, r9
  mov rsi, place
  call number_str
  call print_str
  call new_line
  call exit

.error:
  ;Неверное число параметров - выводим подсказку
  mov rsi, msg_err
  call print_str
  call exit
