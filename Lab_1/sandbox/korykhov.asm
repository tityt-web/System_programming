format ELF executable 3
entry start

section '.data' readable writeable
msg db 'Korykhov', 10, 'Ivan', 10, 'Andreevich', 10
msg_len = $ - msg

section '.text' executable readable
start:
mov eax, 4
mov ebx, 1
mov ecx, msg
mov edx, msg_len
int 0x80

mov eax, 1
xor ebx, ebx
int 0x80
