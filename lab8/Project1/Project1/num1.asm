.486
    .model flat, stdcall
    option casemap: none

    include c:\masm32\include\kernel32.inc
    include c:\masm32\include\msvcrt.inc
    includelib	c:\masm32\lib\kernel32.lib
    includelib	c:\masm32\lib\msvcrt.lib

.data
    str1 dd 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1
    res dd 100 dup(?)
    first dd 0
    fend dd 19
    format db "%d ", 0

.code
DllMain proc hlnstDLL:DWORD, reason:DWORD, unused:DWORD
    mov EAX, 1
   ret
DllMain Endp

sort1 proc stdcall ; float* sort(float *a, int start, int end, float *res);
    PUSH EAX
    PUSH EDX
    PUSH ESI
    PUSH ECX
    PUSH EDI
    PUSH EBX

    MOV EAX, [ESP + 36] ; EAX = end
    SUB EAX, [ESP + 32] ; EAX = end - start
    INC EAX ; EAX += 1

    MOV ECX, EAX ; ECX = end - start + 1
    MOV EBX, ECX

    MOV ESI, [ESP + 32] ; ESI = start
    MOV EAX, 4
    MUL ESI
    MOV ESI, EAX
    MOV EAX, 4
    MUL ECX
    PUSH EAX
    MOV EAX, [ESP + 32] ; EAX = a
    ADD EAX, ESI
    PUSH EAX ; push a
    PUSH [ESP + 48] ; push res
    call memcopy32


    MOV EAX, [ESP + 40] ; EAX = ������ �������
sort1j1: ; ������ ����
    jmp sort1j2 ; ��������� EAX �� ������ �����
sort1j3: ; ������� �� sortj2
    ADD EAX, 4 ; ���������� � ��������
    loop sort1j1 ; �������� ��������� ���������� ECX
    jmp sort1end ; ������ �� �����

sort1j2: ; ������ �������
    MOV EDX, EBX ; ������� �������� ��� ������� �����
    SUB EDX, ECX ; ���������� 2 ��������
    CMP EDX, 0
    JE sort1j3
    MOV ESI, EAX ; ���������� ������� ��� ������� �����
sort1j4:
    MOV EDI, ESI ; �������� ������ ����������, ��� ���������
    SUB EDI, 4 ; EDI = ������ ����������
    PUSH EAX
    PUSH EBX
    MOV EAX, dword ptr[ESI]
    MOV EBX, dword ptr[EDI]
    CMP EAX, EBX ; ��������� �� ���������
    POP EBX
    POP EAX
    JB sort1j5    ; ������ �� swap
    jmp sort1j3 ; ����� �� �������� 2�� ��������

sort1j5:
    PUSH ESI
    PUSH EDI
    call swap
    DEC EDX
    SUB ESI, 4
    CMP EDX, 0
    je sort1j3 ; ����� � �������� 2�� ��������
    jmp sort1j4 ; ������ ��������
sort1end:
    POP EBX
    POP EDI
    POP ECX
    POP ESI
    POP EDX
    POP EAX
    MOV EAX, [ESP + 16]
    ret 16
sort1 endp

sort2 proc cdecl ; float* sort(float *a, int start, int end, float *res);
    PUSH EAX
    PUSH EDX
    PUSH ESI
    PUSH ECX
    PUSH EDI
    PUSH EBX

    MOV EAX, [ESP + 40] ; EAX = end
    SUB EAX, [ESP + 36] ; EAX = end - start
    INC EAX ; EAX += 1

    MOV ECX, EAX ; ECX = end - start + 1
    MOV EBX, EAX

    MOV ESI, [ESP + 36] ; ESI = start
    MOV EAX, 4
    MUL ESI
    MOV ESI, EAX
    MOV EAX, 4
    MUL ECX
    PUSH EAX
    MOV EAX, [ESP + 36] ; EAX = a
    ADD EAX, ESI
    PUSH EAX ; push a
    PUSH [ESP + 52] ; push res
    call memcopy32

    MOV EAX, [ESP + 44] ; EAX = ������ �������
sort2j1: ; ������ ����
    jmp sort2j2 ; ��������� EAX �� ������ �����
sort2j3: ; ������� �� sortj2
    ADD EAX, 4 ; ���������� � ��������
    loop sort2j1 ; �������� ��������� ���������� ECX
    jmp sort2end ; ������ �� �����

sort2j2: ; ������ �������
    MOV EDX, EBX ; ������� �������� ��� ������� �����
    SUB EDX, ECX ; ���������� 2 ��������
    CMP EDX, 0
    JE sort2j3
    MOV ESI, EAX ; ���������� ������� ��� ������� �����
sort2j4:
    MOV EDI, ESI ; �������� ������ ����������, ��� ���������
    SUB EDI, 4 ; EDI = ������ ����������
    PUSH EAX
    PUSH EBX
    MOV EAX, dword ptr[ESI]
    MOV EBX, dword ptr[EDI]
    CMP EAX, EBX ; ��������� �� ���������
    POP EBX
    POP EAX
    JB sort2j5    ; ������ �� swap
    jmp sort2j3 ; ����� �� �������� 2�� ��������

sort2j5:
    PUSH ESI
    PUSH EDI
    call swap
    DEC EDX
    SUB ESI, 4
    CMP EDX, 0
    je sort2j3 ; ����� � �������� 2�� ��������
    jmp sort2j4 ; ������ ��������
sort2end:
    POP EBX
    POP EDI
    POP ECX
    POP ESI
    POP EDX
    POP EAX
    MOV EAX, [ESP + 20]
    ret
sort2 endp

sort3 proc fastcall ; float* sort(float *a, int start, int end, float *res); ECX, EDX, ����
    PUSH EAX
    PUSH EDX
    PUSH ESI
    PUSH ECX
    PUSH EDI
    PUSH EBP
    PUSH EBX

    SUB ESP, 16
    MOV EBP, ESP
    MOV dword ptr[EBP], ECX             ; [EBP] = *a
    MOV dword ptr[EBP+4], EDX           ; [EBP + 4] = start
    MOV ECX, dword ptr[ESP + 13*4]
    MOV dword ptr[EBP + 8], ECX         ; [EBP + 8] = end
    MOV ECX, dword ptr[ESP + 14*4]
    MOV dword ptr[EBP + 12], ECX        ; [EBP + 12] = *res

    MOV EAX, [EBP + 8] ; EAX = end
    SUB EAX, [EBP + 4] ; EAX = end - start
    INC EAX ; EAX += 1

    MOV ECX, EAX ; ECX = end - start + 1
    MOV EBX, EAX

    MOV ESI, [EBP + 4] ; ESI = start
    MOV EAX, 4
    MUL ESI
    MOV ESI, EAX
    MOV EAX, 4
    MUL ECX
    PUSH EAX
    MOV EAX, [EBP] ; EAX = a
    ADD EAX, ESI
    PUSH EAX ; push a
    PUSH [EBP + 12] ; push res
    call memcopy32

    MOV EAX, [EBP + 12] ; EAX = ������ �������
sort3j1: ; ������ ����
    jmp sort3j2 ; ��������� EAX �� ������ �����
sort3j3: ; ������� �� sortj2
    ADD EAX, 4 ; ���������� � ��������
    loop sort3j1 ; �������� ��������� ���������� ECX
    jmp sort3end ; ������ �� �����

sort3j2: ; ������ �������
    MOV EDX, EBX ; ������� �������� ��� ������� �����
    SUB EDX, ECX ; ���������� 2 ��������
    CMP EDX, 0
    JE sort3j3
    MOV ESI, EAX ; ���������� ������� ��� ������� �����
sort3j4:
    MOV EDI, ESI ; �������� ������ ����������, ��� ���������
    SUB EDI, 4 ; EDI = ������ ����������
    PUSH EAX
    PUSH EBX
    MOV EAX, dword ptr[ESI]
    MOV EBX, dword ptr[EDI]
    CMP EAX, EBX ; ��������� �� ���������
    POP EBX
    POP EAX
    JB sort3j5    ; ������ �� swap
    jmp sort3j3 ; ����� �� �������� 2�� ��������

sort3j5:
    PUSH ESI
    PUSH EDI
    call swap
    DEC EDX
    SUB ESI, 4
    CMP EDX, 0
    je sort3j3 ; ����� � �������� 2�� ��������
    jmp sort3j4 ; ������ ��������
sort3end:
    ADD ESP, 16
    POP EBX
    POP EBP
    POP EDI
    POP ECX
    POP ESI
    POP EDX
    POP EAX
    MOV EAX, [ESP + 12]
    ret 8
sort3 endp

; float* sort(float *a, int start, int end, float *res);
sort4 proc stdcall a: DWORD, start: DWORD, endt: DWORD, rest: DWORD
    PUSH EAX
    PUSH EDX
    PUSH ESI
    PUSH ECX
    PUSH EDI
    PUSH EBX

    MOV EAX, endt ; EAX = end
    SUB EAX, start ; EAX = end - start
    INC EAX ; EAX += 1

    MOV ECX, EAX ; ECX = end - start + 1
    MOV EBX, EAX

    MOV ESI, start ; ESI = start
    MOV EAX, 4
    MUL ESI
    MOV ESI, EAX
    MOV EAX, 4
    MUL ECX
    PUSH EAX
    MOV EAX, a ; EAX = a
    ADD EAX, ESI
    PUSH EAX ; push a
    PUSH rest ; push res
    call memcopy32

    MOV EAX, rest ; EAX = ������ �������
sort4j1: ; ������ ����
    jmp sort4j2 ; ��������� EAX �� ������ �����
sort4j3: ; ������� �� sortj2
    ADD EAX, 4 ; ���������� � ��������
    loop sort4j1 ; �������� ��������� ���������� ECX
    jmp sort4end ; ������ �� �����

sort4j2: ; ������ �������
    MOV EDX, EBX ; ������� �������� ��� ������� �����
    SUB EDX, ECX ; ���������� 2 ��������
    CMP EDX, 0
    JE sort4j3
    MOV ESI, EAX ; ���������� ������� ��� ������� �����
sort4j4:
    MOV EDI, ESI ; �������� ������ ����������, ��� ���������
    SUB EDI, 4 ; EDI = ������ ����������
    PUSH EAX
    PUSH EBX
    MOV EAX, dword ptr[ESI]
    MOV EBX, dword ptr[EDI]
    CMP EAX, EBX ; ��������� �� ���������
    POP EBX
    POP EAX
    JB sort4j5    ; ������ �� swap
    jmp sort4j3 ; ����� �� �������� 2�� ��������

sort4j5:
    PUSH ESI
    PUSH EDI
    call swap
    DEC EDX
    SUB ESI, 4
    CMP EDX, 0
    je sort4j3 ; ����� � �������� 2�� ��������
    jmp sort4j4 ; ������ ��������
sort4end:
    POP EBX
    POP EDI
    POP ECX
    POP ESI
    POP EDX
    POP EAX
    MOV EAX, [ESP + 16]
    ret 16
sort4 endp

; float* sort(float *a, int start, int end, float *res);
sort5 proc c a: DWORD, start: DWORD, endt: DWORD, rest: DWORD
    PUSH EAX
    PUSH EDX
    PUSH ESI
    PUSH ECX
    PUSH EDI
    PUSH EBX

    MOV EAX, endt ; EAX = end
    SUB EAX, start ; EAX = end - start
    INC EAX ; EAX += 1

    MOV ECX, EAX ; ECX = end - start + 1
    MOV EBX, EAX

    MOV ESI, start ; ESI = start
    MOV EAX, 4
    MUL ESI
    MOV ESI, EAX
    MOV EAX, 4
    MUL ECX
    PUSH EAX
    MOV EAX, a ; EAX = a
    ADD EAX, ESI
    PUSH EAX ; push a
    PUSH rest ; push res
    call memcopy32

    MOV EAX, rest ; EAX = ������ �������
sort5j1: ; ������ ����
    jmp sort5j2 ; ��������� EAX �� ������ �����
sort5j3: ; ������� �� sortj2
    ADD EAX, 4 ; ���������� � ��������
    loop sort5j1 ; �������� ��������� ���������� ECX
    jmp sort5end ; ������ �� �����

sort5j2: ; ������ �������
    MOV EDX, EBX ; ������� �������� ��� ������� �����
    SUB EDX, ECX ; ���������� 2 ��������
    CMP EDX, 0
    JE sort5j3
    MOV ESI, EAX ; ���������� ������� ��� ������� �����
sort5j4:
    MOV EDI, ESI ; �������� ������ ����������, ��� ���������
    SUB EDI, 4 ; EDI = ������ ����������
    PUSH EAX
    PUSH EBX
    MOV EAX, dword ptr[ESI]
    MOV EBX, dword ptr[EDI]
    CMP EAX, EBX ; ��������� �� ���������
    POP EBX
    POP EAX
    JB sort5j5    ; ������ �� swap
    jmp sort5j3 ; ����� �� �������� 2�� ��������

sort5j5:
    PUSH ESI
    PUSH EDI
    call swap
    DEC EDX
    SUB ESI, 4
    CMP EDX, 0
    je sort5j3 ; ����� � �������� 2�� ��������
    jmp sort5j4 ; ������ ��������
sort5end:
    POP EBX
    POP EDI
    POP ECX
    POP ESI
    POP EDX
    POP EAX
    MOV EAX, rest
    ret
sort5 endp

swap proc stdcall ; void swap(float* a, float* b)
    PUSH EAX
    PUSH EBX
    PUSH EBP
    MOV EAX, [ESP + 16] ; EAX = a
    MOV EBX, [ESP + 20] ; EBX = b

    SUB ESP, 4
    MOV EBP, ESP

    PUSH 4
    PUSH EAX
    PUSH EBP
    call memcopy32

    PUSH 4
    PUSH EBX
    PUSH EAX
    call memcopy32

    PUSH 4
    PUSH EBP
    PUSH EBX
    call memcopy32

    ADD ESP, 4

    POP EBP
    POP EBX
    POP EAX
    ret 8
swap endp

memcopy32 proc stdcall ; void memcopy(void* a, void* b, int size) �� b � a
    ; ���������� ������������ ��������� � �����
    push ESI
    push EDI
    push ECX
    mov ECX, [ESP+24]	; ECX = mem_size
    shr ECX, 2		; ECX = ECX / 4 (mem_size = mem_size >> 2)
    cld			; ������� ����� �����������
    mov esi, [ESP+20]	; ESI = source
    mov edi, [ESP+16]	; EDI = dest
    rep movsd		; ����������� �����
    ; �������������� ������������ ���������
    pop ECX
    pop EDI
    pop ESI
    ret 12
memcopy32 endp

END DllMain
