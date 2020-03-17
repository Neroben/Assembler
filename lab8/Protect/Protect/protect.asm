.486
    .model flat, stdcall
    option casemap: none

    include c:\masm32\include\kernel32.inc
    include c:\masm32\include\msvcrt.inc
    includelib	c:\masm32\lib\kernel32.lib
    includelib	c:\masm32\lib\msvcrt.lib

.data

.code

DllMain proc hlnstDLL:DWORD, reason:DWORD, unused:DWORD
    mov EAX, 1
    ret
DllMain Endp

sum proc ; sum(Complex &B)
    PUSH EAX
    PUSH esi
    MOV ESI, [ESP + 4*3] ; B
    FLD QWORD PTR [ESI] ; ST(0) = B.re
    FLD QWORD PTR [ECX] ; ST(1) = A.re ST(0) = B.re
    FADDP ST(1), ST(0) ; ST(0) = A.re + B.re
;    SUB ESP, 8 ; выделить память под re
    FSTP QWORD PTR [ECX]
;    MOV EAX, dword PTR[ESP] ; A.re = A.re+B.re
;    MOV [ECX], EAX
;    MOV EAX, dword PTR[ESP + 4]
;    MOV [ECX + 4], EAX

    FLD QWORD PTR [ESI + 8] ; ST(0) = B.im
    FLD QWORD PTR [ECX + 8] ; ST(1) = A.im ST(0) = B.im
    FADDP ST(1), ST(0) ; ST(0) = A.im + B.im
    FSTP QWORD PTR [ECX + 8]
;    MOV EAX, dword ptr [ECX+8]
;    MOV [ECX + 8], EAX
;    MOV EAX, dword ptr[ESP + 4]
;    MOV [ECX + 12], EAX
;    ADD ESP, 8 ; освободить локальную переменную
    pop ESI
    pop EAX
    ret 4
sum endp

mull proc ; Complex mul(Complex& D, Complex& B); ecx = A
    PUSH edi
    PUSH esi
    push ebx
    push eax

    MOV ESI, [ESP + 4*5] ; D
    MOV EDI, [ESP + 4*6] ; B

    ; Вычисляем re

    FLD QWORD PTR [ECX] ; ST(0) = A.re
    FLD QWORD PTR [EDI] ; ST(1) = B.re , ST(0) = A.re
    FMULP ST(1), ST(0) ; ST(0) = A.re*B.re
    FLD QWORD PTR [ECX + 8] ; ST(1) = A.im , ST(0) = A.re*B.re
    FLD QWORD PTR [EDI + 8] ; ST(2) = B.im , ST(1) = A.im, ST(0) = A.re*B.re
    FMULP ST(1), ST(0) ; ST(1) = A.im*B.im , ST(0) = A.re*B.re
    FSUBP ST(1), ST(0)
    SUB ESP, 8
    FSTP QWORD PTR [ESP]
    MOV EAX, DWORD PTR [ESP]
    MOV [ESI], eax
    MOV EAX, DWORD PTR [ESP + 4]
    MOV [ESI+4], eax

    ; Вычисляем im
    FLD QWORD PTR [ECX] ; ST(0) = A.re
    FLD QWORD PTR [EDI + 8] ; ST(1) = B.im , ST(0) = A.re
    FMULP ST(1), ST(0) ; ST(0) = A.re*B.im
    FLD QWORD PTR [ECX + 8] ; ST(1) = A.im , ST(0) = A.re*B.im
    FLD QWORD PTR [EDI] ; ST(2) = B.re , ST(1) = A.im, ST(0) = A.re*B.re
    FMULP ST(1), ST(0) ; ST(1) = A.im*B.re , ST(0) = A.re*B.re
    FADDP ST(1), ST(0)
    FSTP QWORD PTR [ESP]
    MOV EAX, DWORD PTR [ESP]
    MOV [ESI + 8], eax
    MOV EAX, DWORD PTR [ESP + 4]
    MOV [ESI+12], eax
    ADD ESP, 8
    pop eax
    pop ebx
    POP ESI
    pop edi
    ret 8
mull endp

END DllMain
