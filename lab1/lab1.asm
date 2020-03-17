.386
.model flat, stdcall 
option casemap: none  
include c:\masm32\include\windows.inc
include c:\masm32\include\kernel32.inc
include c:\masm32\include\user32.inc
includelib c:\masm32\lib\user32.lib
includelib c:\masm32\lib\kernel32.lib
.data
	db "MASM32", 0
	db 250, 251, 252, 254
	a dw 500
	b dw 2
	cc dw 250
	float1 dd 13.5
	float2 dd 26.5
	dmas dq 5 DUP (5)
.code
start:
    mov EAX, 0
    add AL, byte ptr a[-1]
    adc AH, 0
    add AL, byte ptr a[-2]
    adc AH, 0
    add AL, byte ptr a[-3]
    adc AH, 0
    add AL, byte ptr a[-4]
    adc AH, 0
    mov ESI, EAX
    push NULL
    call ExitProcess
end start
