#include <Windows.h>

#include <cmath>


const int StartWidth = 640;
const int StartHeight = 480;

int width;
int height;

int ballRadius = 50;

double ballX = 100;
double ballY = 100;
double ballVectorX = 1;
double ballVectorY = 2;

UINT_PTR timer = 1;


/* ���������� ��� �� ��� ������� ��������.
 *
 * ���������� ����� �������� ��� ���� ������.
 */
void moveBall()
{
	ballX += ballVectorX;
	ballY += ballVectorY;
}


/* ������������ ������������.
 *
 * ���� ��� ���������� �� ������, �� ����������� ���� ��������.
 * ��������, ���� ��� ���������� � ����� �������, ���������� ����
 * � ������� �������� ���� ������ ��������������� �� �����,
 * � ��� ����� ������. ���������� � ������� ��������.
 *
 * ���������� ����� �������� ��� ���� ������.
 */
void handleCollision()
{
	if (width - ballX <= ballRadius || ballX <= ballRadius)
	{
		ballVectorX = -ballVectorX;
	}
	if (height - ballY <= ballRadius || ballY <= ballRadius)
	{
		ballVectorY = -ballVectorY;
	}
}


/* ������������ ������� ����. */
LRESULT CALLBACK handleWindowMessage(HWND hWindow, UINT message, WPARAM wParam, LPARAM lParam)
{	
	switch (message)
	{
	case WM_CREATE:
		SetTimer(hWindow, timer, 1, NULL);
		break;

	case WM_DESTROY:
		KillTimer(hWindow, timer);
		PostQuitMessage(NULL);
		break;

	case WM_PAINT:
	{
		// ��������� �������������� ���������� ������� �������.
		RECT windowRect;
		GetClientRect(hWindow, &windowRect);
		width = windowRect.right - windowRect.left;
		height = windowRect.bottom - windowRect.top;

		PAINTSTRUCT ps;
		HDC hDC = BeginPaint(hWindow, &ps);

		// �������� �������� ��������� ��� ������� �����������.
		HDC hCompatibleDC = CreateCompatibleDC(hDC);
		HBITMAP hBitmap = CreateCompatibleBitmap(hDC, width, height);
		SelectObject(hCompatibleDC, hBitmap);

		// �������� ���� ����� ������.
		HBRUSH backgroundBrush = CreateSolidBrush(RGB(255, 255, 255));
		FillRect(hCompatibleDC, &windowRect, backgroundBrush);
		DeleteObject(backgroundBrush);

		// ��������� ����.
		HPEN ellipsePen = CreatePen(PS_SOLID, 3, RGB(255, 0, 67));
		HBRUSH ellipseBrush = CreateSolidBrush(RGB(255, 0, 67));
		SelectObject(hCompatibleDC, ellipsePen);
		SelectObject(hCompatibleDC, ellipseBrush);
		Ellipse(hCompatibleDC, ballX - ballRadius, ballY - ballRadius,
			ballX + ballRadius, ballY + ballRadius);
		DeleteObject(ellipseBrush);
		DeleteObject(ellipsePen);

		// ����������� ����������� �� �������� ��������� �� �����.
		SetStretchBltMode(hDC, COLORONCOLOR);
		BitBlt(hDC, 0, 0, width, height, hCompatibleDC, 0, 0, SRCCOPY);

		// ������� ��� �������� ��������� �������.
		DeleteDC(hCompatibleDC);
		DeleteObject(hBitmap);
		hCompatibleDC = NULL;

		EndPaint(hWindow, &ps);
	}
	break;

	case WM_TIMER:
		// ��� ������������ ������� �����������, �� �������� �� ��� � ������.
		handleCollision();
		
		moveBall();
		InvalidateRect(hWindow, NULL, false);
		break;

	default:
		return DefWindowProc(hWindow, message, wParam, lParam);
	}
	return 0;
}


/* ������������ ����� ����. */
ATOM registerClass(HINSTANCE hInstance, char* className)
{
	WNDCLASSEX windowClass;
	windowClass.cbSize = sizeof(WNDCLASSEX);
	windowClass.style = CS_HREDRAW | CS_VREDRAW;
	windowClass.lpfnWndProc = handleWindowMessage;
	windowClass.cbClsExtra = 0;
	windowClass.cbWndExtra = 0;
	windowClass.hInstance = hInstance;
	windowClass.hIcon = LoadIcon(hInstance, IDI_APPLICATION);
	windowClass.hCursor = LoadCursor(NULL, IDC_ARROW);
	windowClass.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
	windowClass.lpszMenuName = NULL;
	windowClass.lpszClassName = className;
	windowClass.hIconSm = LoadIcon(windowClass.hInstance, IDI_APPLICATION);

	return RegisterClassEx(&windowClass);
}


/* ������� ����. */
int mainWindow(HINSTANCE hInstance, DWORD nCommandShow, char* className, char* titleName)
{
	registerClass(hInstance, className);

	HWND hWindow = CreateWindowEx(
		NULL, className, titleName, WS_OVERLAPPEDWINDOW | WS_VISIBLE, CW_USEDEFAULT,
		CW_USEDEFAULT, StartWidth, StartHeight, NULL, NULL, hInstance, NULL);

	if (hWindow == NULL)
	{
		return FALSE;
	}

	ShowWindow(hWindow, nCommandShow);
	UpdateWindow(hWindow);

	HACCEL hAcceleratorsTable = LoadAccelerators(hInstance, MAKEINTRESOURCE(500));

	MSG message;
	while (GetMessage(&message, NULL, 0, 0))
	{
		if (!TranslateAccelerator(message.hwnd, hAcceleratorsTable, &message))
		{
			TranslateMessage(&message);
			DispatchMessage(&message);
		}
	}

	return (int)message.wParam;
}


int main()
{
	HMODULE hInstance = GetModuleHandle(NULL);

	const int MaxLoadString = 100;
	char titleName[MaxLoadString] = "Balls";
	char className[MaxLoadString] = "MyClass";
	mainWindow(hInstance, SW_SHOWDEFAULT, className, titleName);
	return 0;
}