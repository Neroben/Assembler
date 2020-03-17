#include <iostream>
#include <complex>

class Complex {
public:
	double re;
	double im;

	void add(Complex& a);
	//Complex mul(Complex& A, Complex& B);
	Complex operator*(Complex& B);
};

int main() {
	Complex A, B;
	A.re = 10.2;
	A.im = 0.2;
	B.re = 100.2;
	B.im = 300.2;
	A.add(B);
	//D.mul(A, B);
	Complex D = A * B;


	std::complex<double> A1(A.re, A.im);
	std::complex<double> B1(B.re, B.im);
	std::cout << (A1 * B1) << std::endl;


	//std::cout << D.re << " " << D.im << std::endl;
	std::cout << A.re << " " << A.im << std::endl;
	//std::cout << B.re << " " << B.im << std::endl;
}	