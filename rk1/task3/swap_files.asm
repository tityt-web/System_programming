format elf64
public _start

include 'func.asm'

;Размер буфера для чтения каталога
len = 4096
;Максимальный размер обрабатываемого файла (1 Мб)
max_size = 1048576

section '.data' writable
  rnd_dev db "/dev/urandom", 0
  cur_dir db ".", 0
  msg_usage db "Usage: ./swap_files dir", 0x0a, 0
  msg_dir db "Error: cannot open directory", 0x0a, 0
  msg_few db "Error: need at least 2 files", 0x0a, 0
  msg_file db "Error: cannot read/write file", 0x0a, 0
  msg_big db "Error: file is too big", 0x0a, 0
  msg_swap db "Swapped: ", 0
  msg_and db " <-> ", 0

section '.bss' writable
  ;Буфер для структур linux_dirent
  buffer rb len
  ;Имена найденных файлов подряд, через 0
  names rb 65536
  ;Массив указателей на имена файлов
  ptrs rq 2048
  ;Количество найденных файлов
  count rq 1
  ;Место для случайного числа
  rnd rq 1
  ;Указатели на имена выбранных файлов
  file_a rq 1
  file_b rq 1
  ;Размеры содержимого выбранных файлов
  size_a rq 1
  size_b rq 1
  ;Буферы для содержимого файлов
  buf_a rb max_size
  buf_b rb max_size

section '.text' executable

_start:
  ;Считываем количество параметров командной строки
  pop rcx
  cmp rcx, 2
  jne .usage

  ;Заходим в каталог (chdir)
  mov rax, 80
  mov rdi, [rsp+8]
  syscall
  cmp rax, 0
  jl .dir_error

  ;Открываем текущий каталог на чтение (O_DIRECTORY)
  mov rax, 2
  mov rdi, cur_dir
  mov rsi, 65536
  syscall
  cmp rax, 0
  jl .dir_error
  ;Сохраняем дескриптор каталога
  mov r8, rax

  mov qword [count], 0
  ;r12 - текущая позиция для записи очередного имени
  mov r12, names

.read_dir:
  ;Читаем записи каталога (getdents)
  mov rax, 78
  mov rdi, r8
  mov rsi, buffer
  mov rdx, len
  syscall
  cmp rax, 0
  jle .dir_done
  ;r10 - количество прочитанных байт, rdx - текущая позиция в буфере
  mov r10, rax
  xor rdx, rdx

  .entry:
    ;r9 - размер текущей структуры (d_reclen)
    xor r9, r9
    mov r9w, word [buffer+16+rdx]
    ;Тип файла - последний байт структуры, берём только обычные файлы (8)
    mov al, byte [buffer+rdx+r9-1]
    cmp al, 8
    jne .next_entry
    cmp qword [count], 2048
    jae .next_entry

    ;Запоминаем указатель на имя и увеличиваем счётчик файлов
    mov rbx, [count]
    mov [ptrs+rbx*8], r12
    inc qword [count]
    ;Копируем имя файла (d_name) вместе с завершающим нулём
    lea rsi, [buffer+18+rdx]
    .copy:
      mov al, byte [rsi]
      mov byte [r12], al
      inc rsi
      inc r12
      cmp al, 0
      jne .copy

  .next_entry:
    ;Переходим к следующей структуре
    add rdx, r9
    cmp rdx, r10
    jl .entry
  jmp .read_dir

.dir_done:
  ;Закрываем каталог
  mov rax, 3
  mov rdi, r8
  syscall

  ;Для обмена нужно минимум два файла
  cmp qword [count], 2
  jb .few_files

  ;Открываем /dev/urandom для получения случайных чисел
  mov rax, 2
  mov rdi, rnd_dev
  xor rsi, rsi
  syscall
  cmp rax, 0
  jl .file_error
  mov r8, rax

  ;Первый файл: r13 = random mod count
  call random
  xor rdx, rdx
  div qword [count]
  mov r13, rdx

  ;Второй файл: r14 = (r13 + 1 + random mod (count-1)) mod count
  ;так r14 гарантированно не совпадает с r13
  call random
  mov rbx, [count]
  dec rbx
  xor rdx, rdx
  div rbx
  lea rax, [r13+rdx+1]
  xor rdx, rdx
  div qword [count]
  mov r14, rdx

  ;Закрываем /dev/urandom
  mov rax, 3
  mov rdi, r8
  syscall

  ;Получаем имена выбранных файлов
  mov rax, [ptrs+r13*8]
  mov [file_a], rax
  mov rax, [ptrs+r14*8]
  mov [file_b], rax

  ;Читаем содержимое первого файла в buf_a
  mov rdi, [file_a]
  mov rsi, buf_a
  call read_file
  cmp rax, 0
  jl .file_error
  mov [size_a], rax

  ;Читаем содержимое второго файла в buf_b
  mov rdi, [file_b]
  mov rsi, buf_b
  call read_file
  cmp rax, 0
  jl .file_error
  mov [size_b], rax

  ;Записываем содержимое второго файла в первый
  mov rdi, [file_a]
  mov rsi, buf_b
  mov rdx, [size_b]
  call write_file
  cmp rax, 0
  jl .file_error

  ;Записываем содержимое первого файла во второй
  mov rdi, [file_b]
  mov rsi, buf_a
  mov rdx, [size_a]
  call write_file
  cmp rax, 0
  jl .file_error

  ;Выводим имена файлов, содержимое которых поменяли
  mov rsi, msg_swap
  call print_str
  mov rsi, [file_a]
  call print_str
  mov rsi, msg_and
  call print_str
  mov rsi, [file_b]
  call print_str
  call new_line
  call exit

.usage:
  mov rsi, msg_usage
  call print_str
  call exit

.dir_error:
  mov rsi, msg_dir
  call print_str
  call exit

.few_files:
  mov rsi, msg_few
  call print_str
  call exit

.file_error:
  ;Код -2 означает слишком большой файл
  cmp rax, -2
  jne .print_file_error
  mov rsi, msg_big
  call print_str
  call exit
.print_file_error:
  mov rsi, msg_file
  call print_str
  call exit


;The function reads 8 random bytes
;input r8 - descriptor of /dev/urandom
;output rax - random number
random:
  mov rax, 0
  mov rdi, r8
  mov rsi, rnd
  mov rdx, 8
  syscall
  mov rax, [rnd]
  ret


;The function reads the whole file to the buffer
;input rdi - file name, rsi - buffer
;output rax - size of file, -1 - error, -2 - file is too big
read_file:
  push rbx
  push r12
  push r15
  mov r12, rsi
  ;Открываем файл только на чтение
  mov rax, 2
  xor rsi, rsi
  syscall
  cmp rax, 0
  jl .err
  mov rbx, rax
  ;r15 - сколько байт уже прочитано
  xor r15, r15
  .loop:
    ;Читаем очередную порцию в свободную часть буфера
    mov rax, 0
    mov rdi, rbx
    lea rsi, [r12+r15]
    mov rdx, max_size
    sub rdx, r15
    cmp rdx, 0
    je .too_big
    syscall
    cmp rax, 0
    jl .close_err
    je .done
    add r15, rax
    jmp .loop
  .too_big:
    ;Буфер заполнен - проверяем, остались ли ещё данные в файле
    mov rax, 0
    mov rdi, rbx
    mov rsi, rnd
    mov rdx, 1
    syscall
    cmp rax, 0
    je .done
    mov rax, 3
    mov rdi, rbx
    syscall
    mov rax, -2
    jmp .err
  .close_err:
    mov rax, 3
    mov rdi, rbx
    syscall
    mov rax, -1
    jmp .err
  .done:
    ;Закрываем файл и возвращаем его размер
    mov rax, 3
    mov rdi, rbx
    syscall
    mov rax, r15
  .err:
  pop r15
  pop r12
  pop rbx
  ret


;The function rewrites the file with the buffer
;input rdi - file name, rsi - buffer, rdx - size
;output rax - 0 - success, -1 - error
write_file:
  push rbx
  push r12
  push r15
  mov r12, rsi
  mov r15, rdx
  ;Открываем файл на запись с обнулением (O_WRONLY | O_TRUNC = 513)
  mov rax, 2
  mov rsi, 513
  syscall
  cmp rax, 0
  jl .err
  mov rbx, rax
  .loop:
    ;Пишем, пока не запишем все r15 байт
    cmp r15, 0
    je .done
    mov rax, 1
    mov rdi, rbx
    mov rsi, r12
    mov rdx, r15
    syscall
    cmp rax, 0
    jle .close_err
    add r12, rax
    sub r15, rax
    jmp .loop
  .close_err:
    mov rax, 3
    mov rdi, rbx
    syscall
    mov rax, -1
    jmp .err
  .done:
    ;Закрываем файл
    mov rax, 3
    mov rdi, rbx
    syscall
    xor rax, rax
  .err:
  pop r15
  pop r12
  pop rbx
  ret
