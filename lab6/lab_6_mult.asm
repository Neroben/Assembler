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
    n dd 6
    a dd 1, 0, 0, 0, 0, 0, 0, 0, 0
    res dd 18 dup(0)
    fmt db "n = %hu", 13, 10, 0
    number_format_a db "a = %08X %08X %08X %08X %08X %08X %08X %08X %08X", 13, 10, 0
    number_format_res db "res = %08X %08X %08X %08X %08X %08X %08X %08X %08X %08X %08X %08X %08X %08X %08X %08X %08X %08X", 13, 10, 0
    
.code
multiplication proc
    ;Сохранить в стеке значения регистров, которые будут использованы
    push eax
    push ebx
    push ecx
    push esi
    push edi
    push ebp
    
    ; достать данные
    xor eax, eax
    xor ebx, ebx
    mov esi, [esp+8+4*7] ; res
    mov edi, [esp+4*7]   ; a
    mov ecx, [esp+4+4*7] ; n

    push ecx
    mov ecx, 34
; заполнение массива результата изначальными числами
init_res_loop:
    mov al, byte ptr[edi + ecx]
    mov byte ptr[esi + ecx], al
loop init_res_loop
    mov al, byte ptr[edi]
    mov byte ptr[esi], al
    pop ecx
    
outer_loop:
    push ecx
    mov ecx, 34
    mov ebp, ecx
    mov AL, byte ptr[esi+ebp]
    mov BL, byte ptr[esi+ebp]
    rol BL, 1
    and BL, 00000001b; сдвинутый бит
    shl AL, 1; готовый байт
    mov byte ptr[esi+ebp], AL
inner_loop:
    dec ebp
    mov AL, byte ptr[esi+ebp]
    mov DL, byte ptr[esi+ebp]
    rol DL, 1
    and DL, 00000001b; сдвинутый бит
    sal AL, 1; cмещенный байт
    or AL, BL; готовый байт с учетом сдвинутого бита старшего байта
    mov byte ptr[esi+ebp], AL
    mov BL, DL; запомнить сдвинутый бит для младшего байта
loop inner_loop
    pop ecx
loop outer_loop

    pop ebp
    pop edi
    pop esi
    pop ecx
    pop ebx
    pop eax
    ret 12
multiplication endp

start:
    push dword ptr a[0]
    push dword ptr a[4]
    push dword ptr a[8]
    push dword ptr a[12]
    push dword ptr a[16]
    push dword ptr a[20]
    push dword ptr a[24]
    push dword ptr a[28]
    push dword ptr a[32]
    push offset number_format_a
    call crt_printf
    add esp, 10*4

    push word ptr n
    push offset fmt
    call crt_printf
    add ESP, 8

    push offset res
    push n
    push offset a
    call multiplication

    ; вывод результата
    push dword ptr res[0]
    push dword ptr res[4]
    push dword ptr res[8]
    push dword ptr res[12]
    push dword ptr res[16]
    push dword ptr res[20]
    push dword ptr res[24]
    push dword ptr res[28]
    push dword ptr res[32]
    push dword ptr res[36]
    push dword ptr res[40]
    push dword ptr res[44]
    push dword ptr res[48]
    push dword ptr res[52]
    push dword ptr res[56]
    push dword ptr res[60]
    push dword ptr res[64]
    push dword ptr res[68]
    push offset number_format_res
    call crt_printf
    add esp, 10*4

    call crt__getch ; задержка ввода с клавиатуры
    push 0
    call ExitProcess
end start