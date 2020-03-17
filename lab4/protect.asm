.386
 .model flat, stdcall
 option casemap: none

 include c:\masm32\include\kernel32.inc
 include c:\masm32\include\msvcrt.inc
 
 includelib	c:\masm32\lib\kernel32.lib
 includelib c:\masm32\lib\msvcrt.lib
 
 .data
   arr dw 10, 9, 8, 7, 6, 5, 4, 3, 2, 1
   n db 10
   fmt db "%hd ", 0
 .code
   output_array proc
    PUSH ESI
    PUSH ECX
    PUSH EAX
    PUSH EDI
    PUSH EDX
    MOV ESI, [ESP + 6*4]
    MOV ECX, [ESP + 7*4]
   out_loop:
    MOV EDI, ECX
    push [ESI]
    push offset fmt
    call crt_printf
    MOV ECX, EDI
    pop EAX
    pop EAX
    ADD ESI, 2
    DEC ECX
    CMP ECX, 0
    JA out_loop

    pop EDX
    pop EDI
    pop EAX
    pop ECX
    pop ESI
    
    ret 0
   output_array endp

  start:
    XOR EAX, EAX
    MOV AL, n
    push EAX
    push offset arr
    call output_array

    call crt__getch		; Задержка ввода
    push 0
    call ExitProcess 
  end start