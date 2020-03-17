.486
    .model flat, stdcall
    option casemap: none

    include c:\masm32\include\kernel32.inc
    include c:\masm32\include\msvcrt.inc
    includelib	c:\masm32\lib\kernel32.lib
    includelib	c:\masm32\lib\msvcrt.lib
 
.data
    number_format db "%d:", 0
    format_8 db "-%o", 13, 10, 0
    mask1 dw 001b
    mask5 dw 101b
    mask7 dw 111b

.code
 ; Процедура для вывода двоичного представления 8-битного числа
 ; void output (unsigned int a). Процедура в качестве аргумента принимает не 8-разрядное, а 32-разрядное целое число, но в процедуре используется только младший байт числа, остальные игнорируются
 output proc
    ;Сохранить в стеке значения регистров, которые будут использованы
    PUSH EAX ; Запомнить EAX
    PUSH EBX ; Запомнить EBX
    PUSH ECX ; Запомнить ECX
    XOR EBX, EBX ;  Обнулить EBX
    MOV AX, [ESP+4*4] ; Взять из стека аргумент, т.е. число, которое нужно вывести в двоичном представлении
    ROL AX, 1
    MOV ECX, 15 ; Чтобы вывести 8-битное число, необходим цикл. Помещаем в ECX количество итераций
 j1:
    ROL AX, 1 ; Сделать циклический сдвиг числа на один разряд влево. Таким образом старший бит попадёт на место младшего
    MOV BX, AX ; BL = AL
    AND BX, 00000001b ; Оставить только младший бит, остальные обнулить
    ADD BX, '0' ; Прибавить к BL код символа "0"
    PUSH EAX ; Команда для вывода символа на экран crt_putch изменяет регистры EAX и ECX, поэтому нужно сохранить их в стеке
    PUSH ECX  
    PUSH EBX ; Поместить выводимый символ в стек, т.е. передать его в качестве аргумента функции crt__putch
    CALL crt__putch ; Вызвать функцию
    ADD ESP, 4 ; Удалить аргумент из стека, так как функция crt__putch этого не делает
    POP ECX ; Восстановить ECX
    POP EAX ; Восстановить EAX 
    LOOP j1 ; ECX = ECX - 1. Выполнять цикл пока ECX ? 0
    POP ECX ; Восстановить ECX
    POP EBX ; Восстановить EBX
    POP EAX ; Восстановить EAX
    RET 4 ; Возврат к основной программе и очистка стека от аргумента размером 4 байта
 output endp 


start:
    MOV ESI, 1 ; номер последовательности
    MOV EBX, 5 ;количество символов в 8меричной системе счисления
    SUB ESP, 2 ; выделение 2 байт памяти в стеке
    MOV EBP, ESP ; сохранение адреса локальной переменной
    MOV dword ptr [EBP], 0 ; обнуление локальной переменной

    
    MOV EDX, EBX ; передаём в счётчик количество итераций, на каком месте встретится 5
j1:
    MOV EAX, 5 ; передаём в счётчик количество итераций, на каком месте встретится 7
    j2:
    
        
        MOV ECX, EBX
        j3:
            CMP EDX, EAX ; сравнение
            JE j5 ; пропускаем последовательность         
            CMP EDX, ECX 
            JE jmask5
            CMP EAX, ECX
            JE jmask7
            jmp jmask1
        j4:
        loop j3
        jmp joutput
        j6:
        MOV dword ptr [EBP], 0 ; обнуление локальной переменной
    j5:
    DEC EAX
    CMP EAX, 0 ; сравнение
    JG j2 ; если больше нуля, то перейти по ссылке
DEC EDX 
CMP EDX, 0 ; сравнение
JG j1 ; если больше нуля, то перейти по ссылке
jmp exit1    

jmask1:
    push EAX
    MOV AX, word ptr [EBP]
    SHL AX, 3 ; смещение влево на 3 бита
    OR AX, mask1 ; добавление 1 в конец
    MOV word ptr [EBP], AX
    POP EAX
    jmp j4
jmask5:
    push EAX
    MOV AX, word ptr [EBP]
    SHL AX, 3 ; смещение влево на 3 бита
    OR AX, mask5 ; добавление 5 в конец
    MOV word ptr [EBP], AX
    POP EAX
    jmp j4
jmask7:
    push EAX
    MOV AX, word ptr [EBP]
    SHL AX, 3 ; смещение влево на 3 бита
    OR AX, mask7 ; добавление 1 в конец
    MOV word ptr [EBP], AX
    POP EAX
    jmp j4
joutput:
    PUSH EAX
    PUSH EBX
    PUSH ECX
    PUSH EDX
    PUSH ESI
    PUSH offset number_format
    call crt_printf
    ADD ESP, 8
    push dword ptr[EBP]
    call output
    PUSH dword ptr[EBP]
    PUSH offset format_8
    call crt_printf
    ADD ESP, 8
    POP EDX
    POP ECX
    POP EBX
    POP EAX
    INC ESI
    jmp j6
exit1:
    call crt__getch	; Задержка ввода
    push 0
    call ExitProcess
    end start
