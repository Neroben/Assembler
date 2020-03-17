.386
.MODEL FLAT, STDCALL
OPTION CASEMAP: NONE

include c:\masm32\include\windows.inc
include c:\masm32\include\user32.inc
include c:\masm32\include\gdi32.inc
include c:\masm32\include\kernel32.inc

includelib c:\masm32\lib\user32.lib
includelib c:\masm32\lib\gdi32.lib
includelib c:\masm32\lib\kernel32.lib

.DATA?
  hInstance DD ?

.DATA
  className DB "MyAsmClass", 0
  titleName DB "Balls", 0

  startWidth DD 500
  startHeight DD 500

  clientWidth DD ?

  clientHeight DD ?
  null_ DD 0

  backgroundColor DD 0FF670Ch
  ballsColor DD 000000Fh
  ballsColor2 DD 00FFFFFh

  ballX DD 200.0
  ballY DD 200.0
  ballRadius DD 40
  ballVectorX DD 2.5
  ballVectorY DD 1.0

  radius__ DD 0

  timer DD 1


  NormVectX DD ?;
  NormVectY DD ?;

  sizeVectNorm DD ?;

  BasVectX DD ?;
  BasVectY DD ?;

  cofX DD ?;
  cofY DD ?;








  .CODE


moveBalls PROC
  FLD ballX
  FADD ballVectorX
  FADD ballVectorX

  FSTP ballX

  FLD ballY
  FADD ballVectorY
  FADD ballVectorY

  FSTP ballY

  RET
moveBalls ENDP


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
  JBE collision_next
collision_1Y:
  FLD ballVectorY
  FCHS
  FSTP ballVectorY

collision_next:
 ;Проверка на пересечение с 1 окружностью
  FLD ballX
  FMUL  ballX ;

  FLD ballY
  FMUL  ballY ;
  FADDP ST(1), ST(0) ; RESULT CHAST 1

  FILD ballRadius
  FIADD radius__

  FILD ballRadius
  FIADD radius__
  FMULP ST(1), ST(0) ; в s(0) r^2

  PUSH EAX
  PUSH EBX

  FSTP DWORD PTR [ESP + 4] ;  r^2
  FSTP DWORD PTR [ESP] ;

  POP EBX
  POP EAX

  CMP EBX, EAX
  JG collision_next2
;***************************************************************************************


  FILD null_
  FILD ballX
  FSUBP ST(1), ST(0)
  FSTP NormVectX


  FILD null_
  FILD ballY
  FSUBP ST(1), ST(0)
  FSTP NormVectY

;*Нормализуем вектор нормали вектор нормали*/

  FILD null_
  FADD NormVectX
  FMUL NormVectX

  FILD null_
  FADD NormVectY
  FMUL NormVectY
  FADDP ST(1), ST(0)
  FSQRT



  FILD null_
  FADD NormVectX
  FDIV ST(0), ST(1)
  FSTP NormVectX


  FILD null_
  FADD NormVectY
  FDIV ST(0), ST(1)
  FSTP NormVectY

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;ВЕРНО

;****Получаем базис*/

  FLD NormVectY
  FCHS
  FSTP BasVectX

  FLD NormVectX
  FSTP BasVectY


;;*Получим коэффицэнты X' и Y'*/


  FLD NormVectX
  FLD ballVectorX
  FMULP ST(1), ST(0)


  FLD NormVectY
  FLD ballVectorY
  FMULP ST(1), ST(0)

  FADDP ST(1), ST(0)
  FCHS
  FSTP cofX

  FLD BasVectX
  FLD ballVectorX
  FMULP ST(1), ST(0)

  FLD BasVectY
  FLD ballVectorY
  FMULP ST(1), ST(0)

  FADDP ST(1), ST(0)
  FSTP cofY

;/*Получаем новый вектор скорости*/

  FLD NormVectX
  FLD cofX
  FMULP ST(1), ST(0)
  FSTP NormVectX

  FLD NormVectY
  FLD cofX
  FMULP ST(1), ST(0)
  FSTP NormVectY

  FLD BasVectX
  FLD cofY
  FMULP ST(1), ST(0)
  FSTP BasVectX

  FLD BasVectY
  FLD cofY
  FMULP ST(1), ST(0)
  FSTP BasVectY

  FLD NormVectX
  FLD BasVectX
  FADDP ST(1), ST(0)
  FSTP ballVectorX

  FLD NormVectY
  FLD BasVectY
  FADDP ST(1), ST(0)
  FSTP ballVectorY

  SUB ESP, 4

  FSTP DWORD PTR [ESP]
  FSTP DWORD PTR [ESP]
   FSTP DWORD PTR [ESP]

  ADD ESP, 4





collision_next2:


  ;Проверка на пересечение с 2 окружностью
  FLD ballX
  FISUB clientWidth
  FLD ballX
  FISUB clientWidth
  FMULP ST(1), ST(0)



  FLD ballY
  FISUB  clientHeight ;
  FLD ballY
  FISUB  clientHeight ;
  FMULP ST(1), ST(0)
  FADDP ST(1), ST(0) ; RESULT CHAST 1

  FILD ballRadius
  FIADD radius__

  FILD ballRadius
  FIADD radius__
  FMULP ST(1), ST(0) ; в s(0) r^2

  PUSH EAX
  PUSH EBX

  FSTP DWORD PTR [ESP + 4] ;  r^2
  FSTP DWORD PTR [ESP] ;

  POP EBX
  POP EAX

  CMP EBX, EAX
  JG collision_end
  jmp collision_end
; 2-----------------------------------------------------------

  FILD clientWidth
  FILD ballX
  FSUBP ST(1), ST(0)
  FSTP NormVectX


  FILD clientHeight
  FILD ballY
  FSUBP ST(1), ST(0)
  FSTP NormVectY

;*Нормализуем вектор нормали вектор нормали*/

  FILD null_
  FADD NormVectX
  FMUL NormVectX

  FILD null_
  FADD NormVectY
  FMUL NormVectY
  FADDP ST(1), ST(0)
  FSQRT



  FILD null_
  FADD NormVectX
  FDIV ST(0), ST(1)
  FSTP NormVectX


  FILD null_
  FADD NormVectY
  FDIV ST(0), ST(1)
  FSTP NormVectY

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;ВЕРНО

;****Получаем базис*/

  FLD NormVectY
  FCHS
  FSTP BasVectX

  FLD NormVectX
  FSTP BasVectY


;;*Получим коэффицэнты X' и Y'*/


  FLD NormVectX
  FLD ballVectorX
  FMULP ST(1), ST(0)


  FLD NormVectY
  FLD ballVectorY
  FMULP ST(1), ST(0)

  FADDP ST(1), ST(0)
  FCHS
  FSTP cofX

  FLD BasVectX
  FLD ballVectorX
  FMULP ST(1), ST(0)

  FLD BasVectY
  FLD ballVectorY
  FMULP ST(1), ST(0)

  FADDP ST(1), ST(0)
  FSTP cofY

;/*Получаем новый вектор скорости*/

  FLD NormVectX
  FLD cofX
  FMULP ST(1), ST(0)
  FSTP NormVectX

  FLD NormVectY
  FLD cofX
  FMULP ST(1), ST(0)
  FSTP NormVectY

  FLD BasVectX
  FLD cofY
  FMULP ST(1), ST(0)
  FSTP BasVectX

  FLD BasVectY
  FLD cofY
  FMULP ST(1), ST(0)
  FSTP BasVectY

  FLD NormVectX
  FLD BasVectX
  FADDP ST(1), ST(0)
  FSTP ballVectorX

  FLD NormVectY
  FLD BasVectY
  FADDP ST(1), ST(0)
  FSTP ballVectorY
  SUB ESP, 4

   FSTP DWORD PTR [ESP]
  FSTP DWORD PTR [ESP]
FSTP DWORD PTR [ESP]


  ADD ESP, 4




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
 ;****************************
  local ellipseBrush2:HBRUSH
  local ellipsePen2:HPEN

  local ellipseBrush3:HBRUSH
  local ellipsePen3:HPEN
 ;*********************************
  local arcPen:HPEN
  local arcPen2:HPEN
  local left:DWORD
  local top:DWORD
  local right:DWORD
  local bottom:DWORD

  local left2:DWORD
  local top2:DWORD
  local right2:DWORD
  local bottom2:DWORD

  local left3:DWORD
  local top3:DWORD
  local right3:DWORD
  local bottom3:DWORD


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

	PUSH ECX
	push edx
	xor edx , edx
	MOV ECX,2
	DIV ECX

	MOV radius__, EAX
	pop edx
	POP ECX

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





;**************************************************************
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
;*************************************************************

	;invoke CreatePen, PS_SOLID, 3, ballsColor
    ;MOV arcPen, EAX
	;invoke SelectObject, hCompatibleDC, arcPen
	;invoke AngleArc, hCompatibleDC,0,0, radius__, 100, -1
	;invoke DeleteObject,arcPen






	invoke CreatePen, PS_SOLID, 3, ballsColor
    MOV ellipsePen2, EAX
    invoke CreateSolidBrush, ballsColor
    MOV ellipseBrush2, EAX
    invoke SelectObject, hCompatibleDC, ellipsePen2
    ;invoke SelectObject, hCompatibleDC, ellipseBrush2



	FILD clientWidth
	FISUB radius__
    FISTP left2


	FILD clientHeight
	FISUB radius__
    FISTP top2


	FILD clientWidth
    FIADD radius__
    FISTP right2


	FILD clientHeight
    FIADD radius__
    FISTP bottom2
    ;invoke Ellipse, hCompatibleDC, left2, top2, right2, bottom2

	MOV left2, 0
	MOV top2,0
	MOV right2, 0
	MOV bottom2, 0

    invoke DeleteObject, ellipsePen2
    invoke DeleteObject, ellipseBrush2


	;**************************************************************************************************
    invoke CreatePen, PS_SOLID, 3, ballsColor
    MOV ellipsePen3, EAX
    invoke CreateSolidBrush, ballsColor
    MOV ellipseBrush3, EAX
    invoke SelectObject, hCompatibleDC, ellipsePen3
    ;invoke SelectObject, hCompatibleDC, ellipseBrush3



	FLD null_
	FISUB radius__
    FISTP left3


	FLD null_
	FISUB radius__
    FISTP top3


	FLD null_
    FIADD radius__
    FISTP right3


	FLD null_
    FIADD radius__
    FISTP bottom3
    invoke Ellipse, hCompatibleDC, left3, top3, right3, bottom3



    invoke DeleteObject, ellipsePen2
    invoke DeleteObject, ellipseBrush2

    ;*****************************************************************************

    invoke SetStretchBltMode, hDC, COLORONCOLOR
    invoke BitBlt, hDC, 0, 0, clientWidth, clientHeight, hCompatibleDC, 0, 0, SRCCOPY
    invoke DeleteDC, hCompatibleDC
    invoke DeleteObject, hBitmap






    invoke EndPaint, hWindow, ADDR ps

  .ELSEIF message == WM_TIMER
    invoke handleWallCollisions
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
