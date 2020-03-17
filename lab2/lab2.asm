.386
.model flat, stdcall 
option casemap: none  
include c:\masm32\include\windows.inc
include c:\masm32\include\kernel32.inc
include c:\masm32\include\user32.inc
includelib c:\masm32\lib\user32.lib
includelib c:\masm32\lib\kernel32.lib
.data
	
.code
start:
    XOR BX, 100b 
    MOV DWORD PTR [EBX], 'b' 
    CMP [EBP+2], DL
    SBB AX, DX 
    ADD EAX, [EBX*8+EDI+4Ah] 

    ;8A442E 02
    ;B0 5A

    push NULL
    call ExitProcess
end start
