#include <iostream>

extern "C" int* _stdcall sort1(int* a, int start, int end, int* res); //++
extern "C" int* _stdcall sort4(int* a, int start, int end, int* res); //++

extern "C" int* _cdecl sort2(int* a, int start, int end, int* res);
extern "C" int* _cdecl sort5(int* a, int start, int end, int* res); //++

extern "C" int* _fastcall sort3(int* a, int start, int end, int* res); //++

int main() {
	int a[100];
	int res[100];
	int* resp;
	int index = 100;
	for (int i = 0; i < 100; i++)
		a[i] = index - i;
	resp = sort4(a, 0, 99, res);
	for (int i = 0; i < 99; i++)
		std::cout << resp[i] << " ";
}