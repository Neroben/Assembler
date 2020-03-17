.386 ; ���_����������
.model flat, stdcall ; ������_������_�_�����_������_�����������
 option casemap: none ; ����������������_�_��������
 ;    �����������_������_�_�����_���������_�����������_�����������_�������_�_��
 include c:\masm32\include\windows.inc
 include c:\masm32\include\kernel32.inc
 include c:\masm32\include\user32.inc
 include c:\masm32\include\msvcrt.inc

 ;    ������������_���������� 
 includelib c:\masm32\lib\user32.lib
 includelib c:\masm32\lib\kernel32.lib
 includelib c:\masm32\lib\msvcrt.lib

 ;      �������_������ 
.DATA
     CONST_1 dq 1.0
     CONST_2 dq 2.0
     CONST_3 dq 3.0
     CONST_4 dq 4.0
     CONST_Q dq 23.14069263277926
	n dd 10
	fmt db "n = %d, q^(4*%d) = %lf, 4/(q^(2*%d) - 1) = %lf", 10, 0
.code
pow proc
	FINIT		 			;������������� ������.
	FLD QWORD PTR [ESP + 12]      ;st(0) = y
	FLDZ					;st(0) = 0, st(1) = y
	DB 0DBh, 0F0h+1 		      ;FCOMI 0, y (��������� 0 � y)
	FLD1					;st(0) = 1, st(1) = 0, st(2) = y
	JE exit 				;if(0 == y) -> ����� st0 = 1
	FLD QWORD PTR [ESP + 4]       ;st(0) = x, st(1) = 1, st(2) = 0, st(3) = y
	FXCH ST(2)				;st(0) = 0, st(1) = 1, st(2) = x, st(3) = y
	DB 0DBh, 0F0h+2 		      ;FCOMI 0, x (��������� 0 � x)
	JE exit 				;if(0 == x) -> �����, st0 = 0
	
	FINIT 				;��������+�������������
	FLD QWORD PTR [ESP + 4]       ;st(0) = x
	FLD ST(0) 				;st(0) = x, st(1) = x
	FABS 					;st(0) = abs(x), st(1) = x
	FDIV ST(0), ST(1) 		;st(0) = ���� �, st(1) = x
	
	FLD1				;st(0) = 1, st(1) = ���� �, st(2) = x
	;DF 0DBh, 0F0h+1 		;FCOMIP -1, ���� �
							;st(0) = ���� �, st(1) = x
	SUB ESP, 4
	DB 0DBh, 0F0h+1
	fstp DWORD PTR [ESP]	;st(0) = ���� �, st(1) = x

	FXCH ST(1) 				;����� �������� ST(0) � ST(1)
							;st(0) = x, st(1) = ���� �
	FABS					;st(0) = abs(x), st(1) = ���� �
	JA qw 					;if(1 > ���� �)
	ADD ESP, 4
	JMP contin				;���� ������ �� �����
	
qw:
	ADD ESP, 4
	FLD QWORD PTR [ESP + 12];st(0) = y, st(1) = x, st(2) = ���� �
	FABS
	FLD QWORD PTR [ESP + 12];st(0) = y, st(1) = y, st(2) = x, st(3) = ���� �
	FRNDINT 				;��������� y
	FABS
	DB 0DBh, 0F0h+1			;�������� ������. y � y  
	JA qw1 					;if(ST(0) > ST(1))
	JMP qw2
	
qw1:
	FLD1			  	;st(0) = 1, st(1) = ������.y, st(2) = y, 
						;st(3) = x, st(4) = ���� �
	FSUBP ST(1), ST(0)	;ST(i-1)=ST(i)-ST(0)
						;ST(0)=����� ����� y, ST(1)=y, ST(2)=x, ST(3)=���� �
	JMP qw2
	
qw2:	
	PUSH EAX
	PUSH ECX
	PUSH EDX
	SUB ESP, 4
	fistp DWORD PTR [ESP];ST(0)=y, ST(1)=x, ST(2)=���� �
	MOV EAX, [ESP]		;EAX = ����� ����� y
	ADD ESP, 4
	MOV ECX, 2
	XOR EDX, EDX
	DIV ECX
	CMP EDX, 0
	POP EDX
	POP ECX
	POP EAX
	JE revers_znak 		;���� ������ �������
	SUB ESP, 4
	fstp DWORD PTR [ESP];ST(0)=x, ST(1)=���� �
	ADD ESP, 4
	JMP contin
	
revers_znak:
	SUB ESP, 4
	fstp DWORD PTR [ESP];ST(0)=x, ST(1)=���� �
	ADD ESP, 4
	FXCH ST(1)		;ST(1)=���� �, ST(2)=�
	FCHS			;�������� ����
	FXCH ST(1)		;ST(0)=x, ST(1)=���� �			
	JMP contin


contin:	
	FLD QWORD PTR [ESP + 12];st(0) = y, ST(1)=x, ST(2)=���� �
	FXCH ST(1) 		;����� �������� ST(0) � ST(1)
					;st(0) = x, st(1) = y, st(2) = ���� �
	FYL2X 			;ST(0) = ST(1)�log2(ST(0))
					;����������� �������� �� ST(0) � ST(1)
					;st(0) = y*log2(x), st(1) = ���� �
	FLD1 			;st(0) = 1, st(1) = y*log2(x), st(2) = ���� �
	FSCALE 			;��������������� �� �������� 2
					;ST(0) = ST(0) � 2^ST(1)
					;st(0) = 2^y*log2(x), 
					;st(1) = y*log2(x), st(2) = ���� �
	FLD1 			;st(0) = 1, st(1) = 2^y*log2(x), 
					;st(2) = y*log2(x), st(3) = ���� �
	FLD ST(2) 		;st(0) = y*log2(x), st(1) = 1, st(2) = 2^y*log2(x), 
					;st(3) = y*log2(x), st(4) = ���� �
	FPREM 			;��������� ���������� ������� �� �������
					;ST(0) = ST(0) - Q*ST(1)
					;Q � ������������� ������� �� �������
	F2XM1 			;ST(0) = 2^ST(0) - 1
	
	FADD ST(0), ST(1) 
	FMUL ST(0), ST(2) 
	FMUL ST(0), ST(4) ;st(0) = |x|^y * ���� �
exit:
	SUB ESP, 8
	fstp QWORD PTR [ESP]
	FINIT 				;��������+�������������
	FLD QWORD PTR [ESP] ;ST(0)= x^y
	ADD ESP, 8
	RET 16
	pow endp


start:
	MOV ECX, n ;ecx = n
	MOV ESI, 0 ;i
	FLDZ ;st(0) = 0
	;����====================================================
loop1:
    INC ESI ;���������� n
    CMP ESI, ECX ;���������, ���� ecx==esi -> �����
    JG exit1

    PUSH ESI
    FILD DWORD PTR [ESP]	;ST(0) = i
    POP ESI
    FLD CONST_2 
    FMULP ST(1), ST(0)
    FLD CONST_Q				;ST(0) = q, ST(1) = i
    FSTP QWORD PTR [ESP]	           ;�������� � ���� q
    FSTP QWORD PTR [ESP + 8]       ;�������� � ���� i
    CALL pow 			;����� pow, st(0) = q^i
    FSUB CONST_1
    SUB ESP, 8
    FSTP QWORD PTR[ESP]
    FLD CONST_4
    FDIV QWORD PTR [ESP]

    SUB ESP, 8 ; ��������� ������ ��� q2
    FSTP QWORD PTR[ESP]
    MOV EAX, [ESP]
    MOV EDX, [ESP+4]
    ADD ESP, 8

    PUSH ESI
    FILD DWORD PTR [ESP]	;ST(0) = i
    POP ESI
    FLD CONST_4 
    FMULP ST(1), ST(0)
    FLD CONST_Q				;ST(0) = q, ST(1) = i
    FSTP QWORD PTR [ESP]	           ;�������� � ���� q
    FSTP QWORD PTR [ESP + 8]       ;�������� � ���� i
    CALL pow 				;����� pow, st(0) = q^i

    MOV EBX, ECX
    PUSH EDX
    PUSH EAX
    PUSH ESI
    SUB ESP, 8
    FSTP QWORD PTR[ESP] ; �������� � esp q1
    PUSH ESI
    PUSH ESI
    PUSH offset fmt
    CALL crt_printf
    ADD ESP, 8
    MOV ECX, EBX

    JMP loop1
    ;����====================================================
exit1:
	
    call crt__getch	; �������� �����
    push 0
    call ExitProcess
    end start




