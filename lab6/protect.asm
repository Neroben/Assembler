.386
.model flat, stdcall 
option casemap: none  
include c:\masm32\include\windows.inc
include c:\masm32\include\kernel32.inc
include c:\masm32\include\user32.inc
includelib c:\masm32\lib\user32.lib
includelib c:\masm32\lib\kernel32.lib
include c:\masm32\include\msvcrt.inc
includelib c:\masm32\lib\msvcrt.lib
.data
      formatscan db "%X", 0
      format db "%X", 0
      n dd 0
 .code
del_symb proc	 
    PUSH EBX
    PUSH ECX
    PUSH EDX
    SUB ESP, 4
    MOV EBP, ESP
    MOV dword ptr[EBP], 0
    XOR EAX, EAX
    XOR EBX, EBX
    XOR EDX, EDX
    MOV EAX, [ESP+4*5]		
    MOV ECX, 8 			
j1: 
    			
    MOV EBX, EAX			
    AND EBX, 00001111b				
    CMP EBX, 10
    JL j2
    ROR EAX, 4
    LOOP j1
j2:
    CMP EBX, 0
    je j6
    CMP ECX, 0
    JE jend
    PUSH EAX
    MOV EAX, dword ptr[EBP]
    INC dword ptr[EBP]
    CMP EAX, 0
    je j5
j4:
    ROL EBX, 4
    DEC EAX
    CMP EAX, 0
   JNE j4
j5:
    POP EAX
    OR EDX, EBX
    ROR EAX, 4
j6:
    LOOP j1
jend:
    MOV EAX, EDX
    ADD ESP, 4
    POP EDX              
    POP ECX
    POP EBX
    ret 4			
del_symb endp   

start:	

    PUSH offset n
    PUSH offset formatscan
    call crt_scanf
    ADD ESP, 8

    MOV EDX, n
    PUSH EDX
    call del_symb	

    PUSH EAX
    PUSH offset format
    call crt_printf
    ADD ESP, 8

    call crt__getch 
    push 0
    call ExitProcess 
 end start
