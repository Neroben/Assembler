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

  startWidth DD 600
  startHeight DD 600

  clientWidth DD 800
  clientHeight DD 800

  backgroundColor DD 0FF670Ch
  ballsColor DD 0FFFFFFh

  ballstopX DD 0.0
  ballstopY DD 0.0

  ballnull DD 0.0

  balltwo DD 2.0

  ballX DD 400.0
  ballY DD 400.0
  ballRadius DD 50
  ballVectorX DD 2.0
  ballVectorY DD 5.0

  timer DD 1


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
  JBE collision_circle
  jmp collision_1Y

collision_circle:
  FLD ballX
  FLD ballX
  FMULP ST(1), ST(0)
  FLD ballY
  FLD ballY
  FMULP ST(1), ST(0)
  FADDP ST(1), ST(0) ; расстояние между точками
  FSQRT

  FILD clientHeight
  FLD balltwo
  FDIVP ST(1), ST(0)
  FIADD ballRadius

  FCOMPP
  FSTSW AX
  SAHF
  JAE collision_circle2
  JMP collision_end

collision_circle2:
    FLD ballY
    FLD ballX
    




    jmp collision_end

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

    FILD clientHeight
    FLD balltwo
    FDIVP ST(1), ST(0)
    FLD ballstopX
    FSUBRP ST(1), ST(0)
    FISTP left
    FILD clientHeight
    FLD balltwo
    FDIVP ST(1), ST(0)
    FLD ballstopY
    FSUBRP ST(1), ST(0)
    FISTP top
    FILD clientHeight
    FLD balltwo
    FDIVP ST(1), ST(0)
    FLD ballstopX
    FADDP ST(1), ST(0)
    FISTP right
    FILD clientHeight
    FLD balltwo
    FDIVP ST(1), ST(0)
    FLD ballstopY
    FADDP ST(1), ST(0)
    FISTP bottom
    invoke Ellipse, hCompatibleDC, left, top, right, bottom

    invoke DeleteObject, ellipsePen
    invoke DeleteObject, ellipseBrush

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
