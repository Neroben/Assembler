#include <iostream>
#include <Windows.h>

int main() {
	typedef int(_stdcall* myFunc) (int* a, int start, int end, int* res);
	char dllName[] = "num1.dll";
	HMODULE hModule = LoadLibraryA(dllName);
	if (hModule != NULL) {
		char funcName[] = "sort4";
		myFunc func = (myFunc)GetProcAddress(hModule, funcName);
		if (func == NULL) {
			std::cout << "Function not found";
		}
		else {
			int a[] = { 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 };
			int res[10];
			func(a, 0, 9, res);
			for (int i = 0; i < 10; i++)
				std::cout << res[i] << " ";
		}
	}
	else {
		std::cout << "DLL file not found";
	}
}
