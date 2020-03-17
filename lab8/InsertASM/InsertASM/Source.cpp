#include <iostream>

int* sort(int* a, int start, int end, int* res);
void swap(int* a, int index);

int main() {
	int a[10] = { 10,9,8,7,6,5,4,3,2,1 };
	int res[10];
	sort(a, 0, 9, res);
	for (int i = 0; i < 10; i++)
		std::cout << res[i] << " ";
}

int* sort(int *a, int start, int end, int *res) {
	int index = 0;
	for (int i = start; i <= end; i++) {
		res[index++] = a[i];
	}
	bool flag;
	for (int i = 1; i < (end - start + 1); i++) {
		flag = true;
		index = i;
		while (index > 0 && flag) {
			if (res[index] < res[index - 1])
				swap(res, index--);
			else
				flag = !flag;
		}
	}
	return res;
}

void swap(int *a, int index) {
	int path = a[index - 1];
	a[index - 1] = a[index];
	a[index] = path;
}