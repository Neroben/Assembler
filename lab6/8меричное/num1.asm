.486
    .model flat, stdcall
    option casemap: none

    include c:\masm32\include\kernel32.inc
    include c:\masm32\include\msvcrt.inc
    includelib	c:\masm32\lib\kernel32.lib
    includelib	c:\masm32\lib\msvcrt.lib
 
.data
    number_format db "%d", 0
    new_line_format db 13, 10, 0
    a dw 11010101b

.code
 ; Процедура для вывода двоичного представления 8-битного числа
 ; void output (unsigned int a). Процедура в качестве аргумента принимает не 8-разрядное, а 32-разрядное целое число, но в процедуре используется только младший байт числа, остальные игнорируются
 output proc
    ;Сохранить в стеке значения регистров, которые будут использованы
    PUSH EAX ; Запомнить EAX
    PUSH EBX ; Запомнить EBX
    PUSH ECX ; Запомнить ECX
    XOR EAX, EAX
    XOR EBX, EBX ;  Обнулить EBX
    MOV AX, [ESP+4*4] ; Взять из стека аргумент, т.е. число, которое нужно вывести в двоичном представлении
    SHL AX, 1
    MOV ECX, 5 ; Чтобы вывести 5-знаковое число, необходим цикл. Помещаем в ECX количество итераций
  j1:
    ROL AX, 3 ; Сделать циклический сдвиг числа на три разряда влево. Таким образом старший бит попадёт на место младшего
    MOV BX, AX ; BL = AL
    AND BX, 000000000000111b ; Оставить только младший бит, остальные обнулить
    PUSH EAX ; Команда для вывода символа на экран crt_putch изменяет регистры EAX и ECX, поэтому нужно сохранить их в стеке
    PUSH ECX
    PUSH EBX ; Поместить выводимый символ в стек, т.е. передать его в качестве аргумента функции crt__putch
    push offset number_format
    CALL crt_printf ; Вызвать функцию
    
    ADD ESP, 8 ; Удалить аргумент из стека, так как функция crt__putch этого не делает
    POP ECX ; Восстановить ECX
    POP EAX ; Восстановить EAX
    LOOP j1 ; ECX = ECX - 1. Выполнять цикл пока ECX ? 0
    POP ECX ; Восстановить ECX
    POP EBX ; Восстановить EBX
    POP EAX ; Восстановить EAX
    RET 4 ; Возврат к основной программе и очистка стека от аргумента размером 4 байта
 output endp 

start:
    push a

    call output

exit1:
    call crt__getch	; Задержка ввода
    push 0
    call ExitProcess
    end start
