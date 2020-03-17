.486
    .model flat, stdcall
    option casemap: none

    include c:\masm32\include\kernel32.inc
    include c:\masm32\include\msvcrt.inc
    includelib	c:\masm32\lib\kernel32.lib
    includelib	c:\masm32\lib\msvcrt.lib
 
.data
    str1 db 1024 dup(?)
    swap db 20 dup(?)
    format_str db "%s - %d", 0

.code
    comparison_word proc ; bool comparison_word(char* str1, char* str2, int n)
        PUSH ESI
        PUSH EDI
        PUSH ECX
        MOV ESI, [ESP+6*4]
        MOV EDI, [ESP+5*4]
        MOV ECX, [ESP+4*4]
        REPE CMPSB

        JA comp1; array_1 > array_2 
        JBE comp2; array_1 <= array_2 

    comp1:
        MOV EAX, 1
        jmp compend
    comp2:
        MOV EAX, 0
        jmp compend
    compend:
        POP ECX
        POP EDI
        POP ESI
        ret 12
    comparison_word endp

    word_symbol_count proc
        PUSH ESI
        PUSH EDI
        PUSH ECX

        MOV EDI, [ESP+16]
        MOV AL, ' ' ; ����������� ����
        MOV ECX, 1024
        REPNE SCASB
        MOV EAX, EDI
        SUB EAX, [ESP+16]

        POP ECX
        POP EDI
        POP ESI
        DEC EAX
        ret 4
    word_symbol_count endp

    swap_word proc ;  swap(char* a, char* b, int n)
        PUSH ESI
        PUSH EDI
        PUSH ECX
        PUSH EBX

        MOV EAX, [ESP+5*4]
        MOV EBX, [ESP+6*4]

        CLD
        MOV ESI, EAX     ; � ESI - ����� ��������� a
        MOV EDI, offset swap	; � EDI - ����� ��������
        MOV ECX, [ESP+7*4]	; ���������� ���������
        REP MOVSB		; ����������� ������� ����

        MOV ESI, EBX      ; � ESI - ����� ��������� b
        MOV EDI, EAX	; � EDI - ����� �������� a
        MOV ECX, [ESP+7*4]	; ���������� ���������
        REP MOVSB		; ����������� ������� ����

        MOV ESI, offset swap     ; � ESI - ����� ��������� swap
        MOV EDI, EBX	; � EDI - ����� �������� b
        MOV ECX, [ESP+7*4]	; ���������� ���������
        REP MOVSB		; ����������� ������� ����        

        POP EBX
        POP ECX
        POP EDI
        POP ESI
        ret 12
    swap_word endp

    get_word_count proc
        ; ��������� �������� ������������ ��������� � �����
        PUSH EBX
        PUSH ECX
        PUSH EDI
        ; ��������� � EDI ����� �������������� ������
        MOV EDI, [ESP+16]
        ; ������� ����� ����� ����� ������, ������� ����� ��������� � AL ������� ������. ������� ��������� ������ - ������� ������
        MOV AL, 0
        ; ��������� � ECX -1, ����� ���������������� ��� ������������ ���������, �.�. ����� �������� �� ��������, � �������� ��������� ���������� ������� �������� ���������� ������� �������� �����
        MOV ECX, -1
        ; ��������� ����� �������, ����������� � AL
        REPNE SCASB
        ; ������ ����� ��������� ����� ������
        MOV ECX, EDI
        ; ����� �������� ����� ��������. �� ��������� � EDI. ����� ������ ������ - � �����
        ; ������� ���� ������� � ���� ����� ������
        SUB ECX, [ESP+16]
        ; EBX - ������� ���������� ���� 
        XOR EBX, EBX
        ; ��������� � EDI ����� ������ ������
        MOV EDI, [ESP+16]
        ; ����� �������
        MOV AL, ' '
        ; ���������� ��� ������� � ������ ������, �.�. ��������� �������, ���� � ������� ������ �� ������ EDI �������
        REPE SCASB
    j1: 
        ; ���� ECX = 0, �� ����� ���������
        JECXZ j_end 
        ; ������� ��������� ������� - ECX = 0 ��� ������ ������ (����������� ����) 
        REPNE SCASB
        ; ���� ����� ������� ��������� ��������, �� ����� �� ��� ����������
        REPE SCASB
        ; ��������� ���������� ���� �� �������
        INC EBX
        ; ������� � ������ ����� � ���������� �����
        JMP j1
    j_end: 
        ; ��������� ��������� - ���������� ���� � EAX
        MOV EAX, EBX
        ; �������������� ��������� �� �����
        POP EDI
        POP ECX
        POP EBX
        ; ������� �� ������������
        RET 4
    get_word_count endp


    sort_bubble proc     ; sort(str, countword, sizeword)
        PUSH EAX
        PUSH EBX
        PUSH ECX
        PUSH EDI

        
        XOR EBX,EBX ; �������
    sortj1:
        MOV EDI, [ESP+5*4] ; ������ �����
        MOV ESI, EDI
        ADD ESI, [ESP+7*4] ; ������ �����
        INC ESI
        MOV ECX, [ESP+6*4] ; �������
        CMP ECX, 1
        JE jmpend
        DEC ECX
    sortj2:
        PUSH EDI
        PUSH ESI
        PUSH [ESP+7*4] ; ������ ����
        call comparison_word ; ��������� ���� ����
        CMP EAX, 1
        JE swapj ; �������� �� �����
        MOV EDI, ESI ; ��������� �����
        MOV ESI, EDI
        ADD ESI, [ESP+7*4] ; ��������� �����
        INC ESI
        
        LOOP sortj2
        INC EBX
        CMP EBX,[ESP+6*4]
        JNE sortj1
        jmp jmpend
    swapj:
        PUSH [ESP+7*4] ; ������ ����
        PUSH ESI
        PUSH EDI
        call swap_word
        MOV EDI, ESI ; ��������� �����
        MOV ESI, EDI
        ADD ESI, [ESP+7*4] ; ��������� �����
        INC ESI
        LOOP sortj2
        INC EBX
        CMP EBX,[ESP+6*4]
        JNE sortj1
        jmp jmpend

    jmpend:
        POP EDI
        POP ECX
        POP EBX
        POP EAX
        ret 12
    sort_bubble endp

    count_a proc ; int fnc(str)
        PUSH EDI
        PUSH EBX
        PUSH ECX
        PUSH EDX

        MOV EDI, [ESP+5*4]
        XOR EBX, EBX
        MOV EDX, [EDI]
        CMP DL, 160
        JNE count_aend
        MOV AL, ' '
        MOV ECX, 1023
    count_aj1:
        INC EBX
        REPNE SCASB
        XOR EDX, EDX
        MOV DL, byte ptr[EDI]
        CMP DL, 160
        JE count_aj1
    count_aend:
        MOV EAX, EBX
        POP EDX
        POP ECX
        POP EBX
        POP EDI
        ret 4
    count_a endp

start:
    PUSH offset str1
    call crt_gets
    ADD ESP, 8

    SUB ESP, 8
    MOV EDI, ESP

    PUSH offset str1
    call get_word_count
    MOV [EDI], EAX ; ��������� ���������� ����

    PUSH offset str1
    call word_symbol_count
    MOV [EDI+4], EAX ; ��������� ������ ����

    PUSH [EDI+4]
    PUSH [EDI]
    PUSH offset str1
    call sort_bubble

    ADD ESP, 8

    PUSH offset str1
    call count_a

    PUSH EAX
    PUSH offset str1
    PUSH offset format_str
    call crt_printf
    ADD ESP, 16

    

    call crt__getch ; �������� ����� � ����������
    push 0
    call ExitProcess ; ����� �� ���������
end start
