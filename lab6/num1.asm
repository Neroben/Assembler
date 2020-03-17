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
 ; ��������� ��� ������ ��������� ������������� 8-������� �����
 ; void output (unsigned int a). ��������� � �������� ��������� ��������� �� 8-���������, � 32-��������� ����� �����, �� � ��������� ������������ ������ ������� ���� �����, ��������� ������������
 output proc
    ;��������� � ����� �������� ���������, ������� ����� ������������
    PUSH EAX ; ��������� EAX
    PUSH EBX ; ��������� EBX
    PUSH ECX ; ��������� ECX
    XOR EBX, EBX ;  �������� EBX
    MOV AX, [ESP+4*4] ; ����� �� ����� ��������, �.�. �����, ������� ����� ������� � �������� �������������
    ROL AX, 1
    MOV ECX, 15 ; ����� ������� 8-������ �����, ��������� ����. �������� � ECX ���������� ��������
 j1:
    ROL AX, 1 ; ������� ����������� ����� ����� �� ���� ������ �����. ����� ������� ������� ��� ������ �� ����� ��������
    MOV BX, AX ; BL = AL
    AND BX, 00000001b ; �������� ������ ������� ���, ��������� ��������
    ADD BX, '0' ; ��������� � BL ��� ������� "0"
    PUSH EAX ; ������� ��� ������ ������� �� ����� crt_putch �������� �������� EAX � ECX, ������� ����� ��������� �� � �����
    PUSH ECX  
    PUSH EBX ; ��������� ��������� ������ � ����, �.�. �������� ��� � �������� ��������� ������� crt__putch
    CALL crt__putch ; ������� �������
    ADD ESP, 4 ; ������� �������� �� �����, ��� ��� ������� crt__putch ����� �� ������
    POP ECX ; ������������ ECX
    POP EAX ; ������������ EAX 
    LOOP j1 ; ECX = ECX - 1. ��������� ���� ���� ECX ? 0
    POP ECX ; ������������ ECX
    POP EBX ; ������������ EBX
    POP EAX ; ������������ EAX
    RET 4 ; ������� � �������� ��������� � ������� ����� �� ��������� �������� 4 �����
 output endp 


start:
    MOV ESI, 1 ; ����� ������������������
    MOV EBX, 5 ;���������� �������� � 8�������� ������� ���������
    SUB ESP, 2 ; ��������� 2 ���� ������ � �����
    MOV EBP, ESP ; ���������� ������ ��������� ����������
    MOV dword ptr [EBP], 0 ; ��������� ��������� ����������

    
    MOV EDX, EBX ; ������� � ������� ���������� ��������, �� ����� ����� ���������� 5
j1:
    MOV EAX, 5 ; ������� � ������� ���������� ��������, �� ����� ����� ���������� 7
    j2:
    
        
        MOV ECX, EBX
        j3:
            CMP EDX, EAX ; ���������
            JE j5 ; ���������� ������������������         
            CMP EDX, ECX 
            JE jmask5
            CMP EAX, ECX
            JE jmask7
            jmp jmask1
        j4:
        loop j3
        jmp joutput
        j6:
        MOV dword ptr [EBP], 0 ; ��������� ��������� ����������
    j5:
    DEC EAX
    CMP EAX, 0 ; ���������
    JG j2 ; ���� ������ ����, �� ������� �� ������
DEC EDX 
CMP EDX, 0 ; ���������
JG j1 ; ���� ������ ����, �� ������� �� ������
jmp exit1    

jmask1:
    push EAX
    MOV AX, word ptr [EBP]
    SHL AX, 3 ; �������� ����� �� 3 ����
    OR AX, mask1 ; ���������� 1 � �����
    MOV word ptr [EBP], AX
    POP EAX
    jmp j4
jmask5:
    push EAX
    MOV AX, word ptr [EBP]
    SHL AX, 3 ; �������� ����� �� 3 ����
    OR AX, mask5 ; ���������� 5 � �����
    MOV word ptr [EBP], AX
    POP EAX
    jmp j4
jmask7:
    push EAX
    MOV AX, word ptr [EBP]
    SHL AX, 3 ; �������� ����� �� 3 ����
    OR AX, mask7 ; ���������� 1 � �����
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
    call crt__getch	; �������� �����
    push 0
    call ExitProcess
    end start
