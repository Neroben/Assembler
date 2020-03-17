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
 ; ��������� ��� ������ ��������� ������������� 8-������� �����
 ; void output (unsigned int a). ��������� � �������� ��������� ��������� �� 8-���������, � 32-��������� ����� �����, �� � ��������� ������������ ������ ������� ���� �����, ��������� ������������
 output proc
    ;��������� � ����� �������� ���������, ������� ����� ������������
    PUSH EAX ; ��������� EAX
    PUSH EBX ; ��������� EBX
    PUSH ECX ; ��������� ECX
    XOR EAX, EAX
    XOR EBX, EBX ;  �������� EBX
    MOV AX, [ESP+4*4] ; ����� �� ����� ��������, �.�. �����, ������� ����� ������� � �������� �������������
    SHL AX, 1
    MOV ECX, 5 ; ����� ������� 5-�������� �����, ��������� ����. �������� � ECX ���������� ��������
  j1:
    ROL AX, 3 ; ������� ����������� ����� ����� �� ��� ������� �����. ����� ������� ������� ��� ������ �� ����� ��������
    MOV BX, AX ; BL = AL
    AND BX, 000000000000111b ; �������� ������ ������� ���, ��������� ��������
    PUSH EAX ; ������� ��� ������ ������� �� ����� crt_putch �������� �������� EAX � ECX, ������� ����� ��������� �� � �����
    PUSH ECX
    PUSH EBX ; ��������� ��������� ������ � ����, �.�. �������� ��� � �������� ��������� ������� crt__putch
    push offset number_format
    CALL crt_printf ; ������� �������
    
    ADD ESP, 8 ; ������� �������� �� �����, ��� ��� ������� crt__putch ����� �� ������
    POP ECX ; ������������ ECX
    POP EAX ; ������������ EAX
    LOOP j1 ; ECX = ECX - 1. ��������� ���� ���� ECX ? 0
    POP ECX ; ������������ ECX
    POP EBX ; ������������ EBX
    POP EAX ; ������������ EAX
    RET 4 ; ������� � �������� ��������� � ������� ����� �� ��������� �������� 4 �����
 output endp 

start:
    push a

    call output

exit1:
    call crt__getch	; �������� �����
    push 0
    call ExitProcess
    end start
