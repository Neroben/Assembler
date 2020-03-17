.386
.MODEL FLAT, STDCALL
OPTION CASEMAP: NONE

include d:\masm32\include\windows.inc
include d:\masm32\include\user32.inc
include d:\masm32\include\gdi32.inc
include d:\masm32\include\kernel32.inc

includelib d:\masm32\lib\user32.lib
includelib d:\masm32\lib\gdi32.lib
includelib d:\masm32\lib\kernel32.lib

.DATA?
  hInstance DD ?

.DATA
  className DB "MyAsmClass", 0
  titleName DB "Balls", 0

  startWidth DD 640
  startHeight DD 480

  bigNumber DD 99999.0

  clientWidth DD ?
  clientHeight DD ?

  backgroundColor DD 0FF670Ch
  ballsColor DD 0FFFFFFh

  ballX DD 500.0
  ballY DD 100.0
  ballRadius DD 10
  ballVectorX DD -5.0
  ballVectorY DD 2.0




  ; Для треугольников

  point1 DD ?, ?
  point2 DD ?, ?
  point3 DD ?, ?
  triangle DD point1, point2, point3

  triangleX DD 3 dup (?) ; Икс координаты обоих треугольников
  triangleYTop DD 3 dup (?) ; Игрек координаты верхнего 
  triangleYBottom DD 3 dup (?) ; Игрек координаты нижнего




  koefFour DD 4
  koefThree DD 3
  koefTwo DD 2


  timer DD 1

  	; ----------------
	; Для отталкиваний
	nx DD ?
	ny DD ?
	avx DD ?
	avy DD ?
	scalar DD ?
	scalar1 DD ?
	scalar2 DD ?
	tmp1x DD ?
	tmp1y DD ?
	minusTwo DD -2
	; ----------------

  .CODE


moveBalls PROC
  FLD ballX
  FADD ballVectorX
  FSTP ballX

  FLD ballY
  FADD ballVectorY
  FSTP ballY

  RET
moveBalls ENDP


inSection PROC
  PUSH EBX
  PUSH EDX
  PUSH ECX
  
  ; [ESP + 16] = x1
  ; [ESP + 20] = y1
  ; [ESP + 24] = x2
  ; [ESP + 28] = y2

  ; Для одного угла
  FLD ballX
  FISUB DWORD PTR [ESP + 16] ; ST(0) = ballX - x1 (vb1x)
  FILD DWORD PTR [ESP + 24] ; ST(0) = x2
  FISUB DWORD PTR [ESP + 16] ; ST(0) = x2 - x1 (vt1x); ST(1) = vb1x
  FMULP ST(1), ST(0) ; ST(0) = vb1x * vt1x

  FLD ballY
  FISUB DWORD PTR [ESP + 20] ; ST(0) = ballY - y1 (vb1y)
  FILD DWORD PTR [ESP + 28] ; ST(0) = y2
  FISUB DWORD PTR [ESP + 20] ; ST(0) = y2 - y1 (vt1y); ST(1) = vb1y
  FMULP ST(1), ST(0) ; ST(0) = vb1y * vt1y; ST(1) = vb1x * vt1x

  FADDP ST(1), ST(0) ; ST(0) = vb1x * vt1x + vb1y * vt1y (scalar1)
  FLDZ
  db 0dbh, 0f0h + 1 ; FCOMI ST(0), ST(1)
  JA @ret_false ; Если scalar1 < 0 то угол больше 90 градусов, то есть мяч не попадает в отрезок


  ; Если scalar1 >= 0 то чистим стек сопроцессора и проверяем scalar2
  SUB ESP, 8
  FSTP DWORD PTR [ESP]
  FSTP DWORD PTR [ESP + 4]
  ADD ESP, 8

  FLD ballX
  FISUB DWORD PTR [ESP + 24] ; ST(0) = ballX - x2 (vb2x)
  FILD DWORD PTR [ESP + 16] ; ST(0) = x1
  FISUB DWORD PTR [ESP + 24] ; ST(0) = x1 - x2 (vt2x); ST(1) = vb2x
  FMULP ST(1), ST(0) ; ST(0) = vb2x * vt2x

  FLD ballY
  FISUB DWORD PTR [ESP + 28] ; ST(0) = ballY - y2 (vb2y)
  FILD DWORD PTR [ESP + 20] ; ST(0) = y1
  FISUB DWORD PTR [ESP + 28] ; ST(0) = y1 - y2 (vt2y); ST(1) = vb2y
  FMULP ST(1), ST(0) ; ST(0) = vb2y * vt2y; ST(1) = vb1x * vt1x

  FADDP ST(1), ST(0) ; ST(0) = vb1x * vt1x + vb1y * vt1y (scalar2)
  FLDZ
  db 0dbh, 0f0h + 1 ; FCOMI ST(0), ST(1)
  JA @ret_false

  ; Если scalar1 >= 0 и scalar2 >= 0, то возврат true
  MOV EAX, 1
  SUB ESP, 8
  FSTP DWORD PTR [ESP]
  FSTP DWORD PTR [ESP + 4]
  ADD ESP, 8
  JMP @end_func


@ret_false:
  MOV EAX, 0
  SUB ESP, 8
  FSTP DWORD PTR [ESP]
  FSTP DWORD PTR [ESP + 4]
  ADD ESP, 8
@end_func:
  POP ECX
  POP EDX
  POP EBX
  RET 16
inSection ENDP




distToLine PROC ; Результат в ST(0), в EAX такое се
  ; [ESP + 4] = x1
  ; [ESP + 8] = y1
  ; [ESP + 12] = x2
  ; [ESP + 16] = y2
  PUSH DWORD PTR [ESP + 16]
  PUSH DWORD PTR [ESP + 16]
  PUSH DWORD PTR [ESP + 16]
  PUSH DWORD PTR [ESP + 16]
  CALL inSection
  CMP EAX, 0
  JE @ret_big_number ; Если мяч не возле отрезка

  FILD DWORD PTR [ESP + 8] ; ST(0) = y1
  FISUB DWORD PTR [ESP + 16] ; ST(0) = y1 - y2 (A)
  FMUL ballX; ST(0) = A * ballX

  FILD DWORD PTR [ESP + 12] ; ST(0) = x2 ; ST(1) = A * ballX
  FISUB DWORD PTR [ESP + 4] ; ST(0) = x2 - x1 (B); ST(1) = A * ballX
  FMUL ballY ; ST(0) = B * ballY; ST(1) = A * ballX
  FADDP ST(1), ST(0) ; ST(0) = A * ballX + B * ballY

  FILD DWORD PTR [ESP + 4]
  FIMUL DWORD PTR [ESP + 16] ; ST(0) = x1 * y2
  FILD DWORD PTR [ESP + 12]
  FIMUL DWORD PTR [ESP + 8] ; ST(0) = x2 * y1; ST(1) = x1 * y2; ST(2) = A * ballX + B * ballY
  FSUBP ST(1), ST(0) ; ST(0) = C; ST(1) = A * ballX + B * ballY
  FADDP ST(1), ST(0) ; ST(0) = A * ballX + B * ballY + C
  FABS ; ST(0) = |A * ballX + B * ballY + C|

  FILD DWORD PTR [ESP + 8] ; ST(0) = y1
  FISUB DWORD PTR [ESP + 16] ; ST(0) = y1 - y2 (A)
  FMUL ST(0), ST(0) ; ST(0) = A^2

  FILD DWORD PTR [ESP + 12] ; ST(0) = x2 ; ST(1) = A^2
  FISUB DWORD PTR [ESP + 4] ; ST(0) = x2 - x1 (B); ST(1) = A^2
  FMUL ST(0), ST(0) ; ST(0) = B^2; ST(1) = A^2; ST(2) = |A * ballX + B * ballY + C|

  FADDP ST(1), ST(0) ; ST(0) = A^2 + B^2; ST(1) = |A * ballX + B * ballY + C|
  FSQRT ; ST(0) = sqrt(A^2 + B^2); ST(1) = |A * ballX + B * ballY + C|

  FDIVP ST(1), ST(0) ; ST(0) = dist


  SUB ESP, 4
  FST DWORD PTR [ESP]
  MOV EAX, [ESP]
  ADD ESP, 4

  JMP @end_func

@ret_big_number:
  FLD bigNumber ; ST(0) = 99999.0
  MOV EAX, 99999
@end_func:
  RET 16
distToLine ENDP



change_dir_func PROC

	FILD DWORD PTR [ESP + 4 + 12] ; nx = y2
	FILD DWORD PTR [ESP + 4 + 4] ; nx = y1 - y2
	FSUB ST(0), ST(1)
	FSTP nx

	; --------------------
	; Чистка мусора (ПОГ)
	SUB ESP, 4
  	FSTP DWORD PTR [ESP]
  	ADD ESP, 4
  	; --------------------

	FILD DWORD PTR [ESP + 4 + 0] ; ny = x1
	FILD DWORD PTR [ESP + 4 + 8] ; ny = x2 - x1
	FSUB ST(0), ST(1)
	FSTP ny

	; --------------------
	; Чистка мусора (ПОГ)
	SUB ESP, 4
  	FSTP DWORD PTR [ESP]
  	ADD ESP, 4
  	; --------------------

	FLD ballVectorX			; ax = ballVectorX
	FSTP avx
	FLD ballVectorY			; ay = ballVectorY
	FSTP avy

	FLD avx
	FMUL nx
	FSTP scalar1				; scalar1 = ax * nx
	FLD avy
	FMUL ny						; ST(0) = ay * ny
	FLD scalar1
	FADD ST(0), ST(1)
	FSTP scalar1				; scalar1 = ax * nx + ay * ny		

	; --------------------
	; Чистка мусора (ПОГ)
	SUB ESP, 4
  	FSTP DWORD PTR [ESP]
  	ADD ESP, 4
  	; --------------------

	FLD nx
	FMUL nx
	FSTP scalar2				; scalar1 = nx * nx
	FLD ny
	FMUL ny						; ST(0) = ny * ny
	FLD scalar2
	FADDP ST(1), ST(0)
	FSTP scalar2				; scalar2 = nx * nx + ny * ny

	; --------------------
	; Чистка мусора (ПОГ)
	SUB ESP, 4
  	FSTP DWORD PTR [ESP]
  	ADD ESP, 4
  	; --------------------

	FLD scalar2
	FLD scalar1
	FDIV ST(0), ST(1)
	FSTP scalar 				; scalar = scalar1 / scalar2;

	; --------------------
	; Чистка мусора (ПОГ)
	SUB ESP, 4
  	FSTP DWORD PTR [ESP]
  	ADD ESP, 4
  	; --------------------

	FILD minusTwo
	FLD scalar
	FLD nx
	FMUL ST(0), ST(1)
	FMUL ST(0), ST(2)
	FSTP tmp1x					; tmp1x = nx * scalar * (-2.0)

	; --------------------
	; Чистка мусора (ПОГ)
	SUB ESP, 8
  	FSTP DWORD PTR [ESP]
  	FSTP DWORD PTR [ESP+4]
  	ADD ESP, 8
  	; --------------------

	FILD minusTwo
	FLD scalar
	FLD ny
	FMUL ST(0), ST(1)
	FMUL ST(0), ST(2)
	FSTP tmp1y					; tmp1y = ny * scalar * (-2.0)

	; --------------------
	; Чистка мусора (ПОГ)
	SUB ESP, 8
  	FSTP DWORD PTR [ESP]
  	FSTP DWORD PTR [ESP+4]
  	ADD ESP, 8
  	; --------------------

	FLD tmp1x
	FLD ballVectorX
	FADDP ST(1), ST(0)		
	FSTP ballVectorX			; ballVectorX += tmp1x
	
	FLD tmp1y
	FLD ballVectorY
	FADDP ST(1), ST(0)		
	FSTP ballVectorY			; ballVectorY += tmp1y

	FLD ballVectorX
	FLD ballVectorY
	RET 16
change_dir_func ENDP




handleTriangleCollisions PROC
  PUSH EAX

  ; Левая сторона нижнего треугольника
  PUSH DWORD PTR triangleYBottom[4]
  PUSH DWORD PTR triangleX[4]
  PUSH DWORD PTR triangleYBottom[0]
  PUSH DWORD PTR triangleX[0]

  CALL distToLine
  FILD ballRadius
  db 0dbh, 0f0h + 1 ; FCOMI ST(0), ST(1)
  JAE @change_dir1

  SUB ESP, 8
  FSTP DWORD PTR [ESP]
  FSTP DWORD PTR [ESP + 4]
  ADD ESP, 8


  ; Правая сторона нижнего треугольника
  PUSH DWORD PTR triangleYBottom[8]
  PUSH DWORD PTR triangleX[8]
  PUSH DWORD PTR triangleYBottom[4]
  PUSH DWORD PTR triangleX[4]


  CALL distToLine
  FILD ballRadius
  db 0dbh, 0f0h + 1 ; FCOMI ST(0), ST(1)
  JAE @change_dir2

  SUB ESP, 8
  FSTP DWORD PTR [ESP]
  FSTP DWORD PTR [ESP + 4]
  ADD ESP, 8

  ; Левая сторона верхнего треугольника
  PUSH DWORD PTR triangleYTop[4]
  PUSH DWORD PTR triangleX[4]
  PUSH DWORD PTR triangleYTop[0]
  PUSH DWORD PTR triangleX[0]


  CALL distToLine
  FILD ballRadius
  db 0dbh, 0f0h + 1 ; FCOMI ST(0), ST(1)
  JAE @change_dir3

  SUB ESP, 8
  FSTP DWORD PTR [ESP]
  FSTP DWORD PTR [ESP + 4]
  ADD ESP, 8

  ; Правая сторона верхнего треугольника
  PUSH DWORD PTR triangleYTop[8]
  PUSH DWORD PTR triangleX[8]
  PUSH DWORD PTR triangleYTop[4]
  PUSH DWORD PTR triangleX[4]

  CALL distToLine
  FILD ballRadius
  db 0dbh, 0f0h + 1 ; FCOMI ST(0), ST(1)
  JAE @change_dir4

  SUB ESP, 8
  FSTP DWORD PTR [ESP]
  FSTP DWORD PTR [ESP + 4]
  ADD ESP, 8


  JMP @end_func
@change_dir1:
  SUB ESP, 8
  FSTP DWORD PTR [ESP]
  FSTP DWORD PTR [ESP + 4]
  ADD ESP, 8
  PUSH DWORD PTR triangleYBottom[4]
  PUSH DWORD PTR triangleX[4]
  PUSH DWORD PTR triangleYBottom[0]
  PUSH DWORD PTR triangleX[0]
  call change_dir_func
  
  JMP @end_func
  
@change_dir2:
  SUB ESP, 8
  FSTP DWORD PTR [ESP]
  FSTP DWORD PTR [ESP + 4]
  ADD ESP, 8
  PUSH triangleYBottom[8]
  PUSH triangleX[8]
  PUSH triangleYBottom[4]
  PUSH triangleX[4]
  call change_dir_func
  JMP @end_func
  
@change_dir3:
  SUB ESP, 8
  FSTP DWORD PTR [ESP]
  FSTP DWORD PTR [ESP + 4]
  ADD ESP, 8
  PUSH triangleYTop[4]
  PUSH triangleX[4]
  PUSH triangleYTop[0]
  PUSH triangleX[0]
  call change_dir_func
  JMP @end_func
 
@change_dir4:
  SUB ESP, 8
  FSTP DWORD PTR [ESP]
  FSTP DWORD PTR [ESP + 4]
  ADD ESP, 8
  PUSH triangleYTop[8]
  PUSH triangleX[8]
  PUSH triangleYTop[4]
  PUSH triangleX[4]
  call change_dir_func

@end_func:
  POP EAX
  RET
handleTriangleCollisions ENDP





























handleWallCollisions PROC
  FILD clientWidth
  FSUB ballX
  FILD ballRadius
  FCOMPP
  FSTSW AX
  SAHF
  JA collision_1X
  FLD ballX
  FILD ballRadius
  FCOMPP
  FSTSW AX
  SAHF
  JBE collision_2_if
collision_1X:
  FLD ballVectorX
  FCHS
  FSTP ballVectorX

collision_2_if:
  FILD clientHeight
  FSUB ballY
  FILD ballRadius
  FCOMPP
  FSTSW AX
  SAHF
  JA collision_1Y
  FLD ballY
  FILD ballRadius
  FCOMPP
  FSTSW AX
  SAHF
  JBE collision_end
collision_1Y:
  FLD ballVectorY
  FCHS
  FSTP ballVectorY

collision_end:
  RET
handleWallCollisions ENDP


handleWindowMessage PROC hWindow:HWND, message:UINT, wParam:WPARAM, lParam:LPARAM
  local windowRect:RECT
  local hDC:HDC
  local hCompatibleDC:HDC
  local hBitmap:HBITMAP
  local ps:PAINTSTRUCT
  local backgroundBrush:HBRUSH
  local ellipseBrush:HBRUSH
  local ellipsePen:HPEN
  local left:DWORD
  local top:DWORD
  local right:DWORD
  local bottom:DWORD

  MOV EBX, message

  .IF message == WM_CREATE
    invoke SetTimer, hWindow, timer, 1, NULL

  .ELSEIF message == WM_DESTROY
    invoke KillTimer, hWindow, timer
    invoke PostQuitMessage, NULL

  .ELSEIF message == WM_PAINT
    invoke GetClientRect, hWindow, ADDR windowRect
    MOV EAX, windowRect.right
    SUB EAX, windowRect.left
    MOV clientWidth, EAX
    MOV EAX, windowRect.bottom
    SUB EAX, windowRect.top
    MOV clientHeight, EAX

    invoke BeginPaint, hWindow, ADDR ps
    MOV hDC, EAX
    invoke CreateCompatibleDC, hDC
    MOV hCompatibleDC, EAX
    invoke CreateCompatibleBitmap, hDC, clientWidth, clientHeight
    MOV hBitmap, EAX
    invoke SelectObject, hCompatibleDC, hBitmap

    invoke CreateSolidBrush, backgroundColor
    MOV backgroundBrush, EAX
    invoke FillRect, hCompatibleDC, ADDR windowRect, backgroundBrush
    invoke DeleteObject, backgroundBrush

    invoke CreatePen, PS_SOLID, 3, ballsColor
    MOV ellipsePen, EAX
    invoke CreateSolidBrush, ballsColor
    MOV ellipseBrush, EAX
    invoke SelectObject, hCompatibleDC, ellipsePen
    invoke SelectObject, hCompatibleDC, ellipseBrush
    FLD ballX
    FISUB ballRadius
    FISTP left
    FLD ballY
    FISUB ballRadius
    FISTP top
    FLD ballX
    FIADD ballRadius
    FISTP right
    FLD ballY
    FIADD ballRadius
    FISTP bottom
    invoke Ellipse, hCompatibleDC, left, top, right, bottom

    invoke DeleteObject, ellipsePen
    invoke DeleteObject, ellipseBrush





    ; Cоздание и рисование треугольников
    invoke CreatePen, PS_SOLID, 3, ballsColor
    MOV ellipsePen, EAX
    invoke CreateSolidBrush, ballsColor
    MOV ellipseBrush, EAX
    invoke SelectObject, hCompatibleDC, ellipsePen
    invoke SelectObject, hCompatibleDC, ellipseBrush

    ; Заполним сначала иксы треугольников
    FILD clientWidth
    FIDIV koefFour
    FISTP triangleX[0]
    FILD clientWidth
    FIDIV koefTwo
    FISTP triangleX[4]
    FILD clientWidth
    FIDIV koefFour
    FIMUL koefThree
    FISTP triangleX[8]

    ; Игреки нижнего треугольника
    FILD clientHeight
    FISTP triangleYBottom[0]
    FILD clientHeight
    FIDIV koefThree
    FIMUL koefTwo
    FISTP triangleYBottom[4]
    FILD clientHeight
    FISTP triangleYBottom[8]

    ; Игреки верхнего треугольника
    FLDZ
    FISTP triangleYTop[0]
    FILD clientHeight
    FIDIV koefThree
    FISTP triangleYTop[4]
    FLDZ
    FISTP triangleYTop[8]


    ; Заполняем массив точек нижнего треугольника для отрисовки полигона
    ; point1Bottom
    FILD triangleX[0]
    FISTP triangle[0]
    FILD triangleYBottom[0]
    FISTP triangle[4]

    ; point2Bottom
    FILD triangleX[4]
    FISTP triangle[8]
    FILD triangleYBottom[4]
    FISTP triangle[12]

    ; point3Bottom
    FILD triangleX[8]
    FISTP triangle[16]
    FILD triangleYBottom[8]
    FISTP triangle[20]


    ; Рисуем треугольник через функцию Polygon
    invoke Polygon, hCompatibleDC, offset triangle, 3


    
    ; Корректируем игреки массива точек верхнего треугольника для отрисовки полигона
    ; point1
    FILD triangleYTop[0]
    FISTP triangle[4]

    ; point2
    FILD triangleYTop[4]
    FISTP triangle[12]

    ; point3
    FILD triangleYTop[8]
    FISTP triangle[20]


    ; Рисуем треугольник через функцию Polygon
    invoke Polygon, hCompatibleDC, offset triangle, 3

    ; С памаятью какая-то лажа, еще раз пересчитаем массивы, тк почему-то их содержимое страдает от заполнения массива точек
    ; Заполним сначала иксы треугольников
    FILD clientWidth
    FIDIV koefFour
    FISTP triangleX[0]
    FILD clientWidth
    FIDIV koefTwo
    FISTP triangleX[4]
    FILD clientWidth
    FIDIV koefFour
    FIMUL koefThree
    FISTP triangleX[8]

    ; Игреки нижнего треугольника
    FILD clientHeight
    FISTP triangleYBottom[0]
    FILD clientHeight
    FIDIV koefThree
    FIMUL koefTwo
    FISTP triangleYBottom[4]
    FILD clientHeight
    FISTP triangleYBottom[8]

    ; Игреки верхнего треугольника
    FLDZ
    FISTP triangleYTop[0]
    FILD clientHeight
    FIDIV koefThree
    FISTP triangleYTop[4]
    FLDZ
    FISTP triangleYTop[8]

    invoke DeleteObject, ellipsePen
    invoke DeleteObject, ellipseBrush


    invoke SetStretchBltMode, hDC, COLORONCOLOR
    invoke BitBlt, hDC, 0, 0, clientWidth, clientHeight, hCompatibleDC, 0, 0, SRCCOPY
    invoke DeleteDC, hCompatibleDC
    invoke DeleteObject, hBitmap

    invoke EndPaint, hWindow, ADDR ps

  .ELSEIF message == WM_TIMER
    invoke handleWallCollisions
    invoke handleTriangleCollisions
    ; invoke handleBallsCollision
    invoke moveBalls
    invoke InvalidateRect, hWindow, NULL, FALSE

  .ELSE
    invoke DefWindowProc, hWindow, message, wParam, lParam
    RET
  .ENDIF

  XOR EAX, EAX
  RET
handleWindowMessage ENDP


registerClass PROC
  local windowClass:WNDCLASSEX
  MOV windowClass.cbSize, SIZEOF WNDCLASSEX
  MOV windowClass.style, CS_HREDRAW OR CS_VREDRAW
  MOV windowClass.lpfnWndProc, offset handleWindowMessage
  MOV windowClass.cbClsExtra, NULL
  MOV windowClass.cbWndExtra, NULL
  PUSH hInstance
  POP windowClass.hInstance
  MOV windowClass.hbrBackground, COLOR_WINDOW + 1
  MOV windowClass.lpszMenuName, NULL
  MOV windowClass.lpszClassName, offset className
  invoke LoadIcon, hInstance, IDI_APPLICATION
  MOV windowClass.hIcon, EAX
  MOV windowClass.hIconSm, EAX
  invoke LoadCursor, NULL, IDC_ARROW
  MOV windowClass.hCursor, EAX
  invoke RegisterClassEx, ADDR windowClass
  RET
registerClass ENDP


mainWindow PROC nCommandShow:DWORD
  local hWindow:HWND
  local message:MSG
  invoke registerClass

  invoke CreateWindowEx, NULL, offset className, offset titleName,
   WS_OVERLAPPEDWINDOW OR WS_VISIBLE, CW_USEDEFAULT, CW_USEDEFAULT,
    startWidth, startHeight, NULL, NULL, hInstance, NULL

  MOV hWindow, EAX
  invoke ShowWindow, hWindow, nCommandShow
  invoke UpdateWindow, hWindow
  .WHILE TRUE
    invoke GetMessage, ADDR message, NULL, 0, 0
    .BREAK .IF (!EAX)
    invoke TranslateMessage, ADDR message
    invoke DispatchMessage, ADDR message
  .ENDW
  MOV EAX, message.wParam
  RET
mainWindow ENDP


START:
  invoke GetModuleHandle, NULL
  MOV hInstance, EAX
  invoke mainWindow, SW_SHOWDEFAULT
  invoke ExitProcess, NULL
END START
