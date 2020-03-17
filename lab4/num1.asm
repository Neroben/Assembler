.386
 .model flat, stdcall
 option casemap: none

 include c:\masm32\include\kernel32.inc
 include c:\masm32\include\msvcrt.inc
 
 includelib	c:\masm32\lib\kernel32.lib
 includelib c:\masm32\lib\msvcrt.lib

 .data
   x dw -10
   y dw 4
   z dw 2
   format db "a = %d", 0
 .code
 start:
   push EBX ; запоминаем EBX
   push ECX ; запоминаем ECX
   MOV AX, x ; AX = x
   CWDE ; расширяем AX до EAX
   MOV EBX, EAX ; EBX = x
   MOV AX, y ; AX = y
   CWDE ; расширяем AX до EAX
   MOV ECX, EAX ; ECX = y
   CMP EBX, 10 ;сравниваем x и 10
   JL j1 ; x < 10
   IMUL EBX ; EAX = x*y
   IMUL EAX ; EAX*EAX
   JMP j_out ; прыжок на выход
  j1:
    CMP ECX, 2 ; сравниваем y и 2
    JL j2 ; y < 2
    MOV AX, z ; AX = z
    CWDE
    MOV ECX, EAX ; ECX = z
    MOV EAX, EBX ; EAX = x
    CDQ
    IDIV ECX ; x/z
    SUB EAX, 6 ; x/z - 6
    JMP j_out    
  j2:
    IMUL EBX ; EAX = x*y
    ADD EAX,4


  j_out:
    pop ECX
    pop EBX
    
    push EAX
    push offset format
    call crt_printf

    call crt__getch		; Задержка ввода
    push 0
    call ExitProcess 

 end start
