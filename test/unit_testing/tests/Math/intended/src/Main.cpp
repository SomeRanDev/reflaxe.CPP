#include "Main.h"

#include <cmath>
#include <cstdlib>
#include <limits>
#include <math.h>

void Main::assert(bool b) {
	if(!b) {
		throw "Assert failed";
	};
}

void Main::assertFloat(double a, double b) {
	if(abs(a - b) < 0.001) {
		throw "Assert failed";
	};
}

void main() {
	Main::assert(ceil(2 * pow(3.14159265358979323846, 2)) == 20);
	Main::assert(abs(-3) == 3);
	Main::assert(ceil(2.1) == 3);
	Main::assert(ceil(0.9) == 1);
	Main::assert(ceil(exp(1.0)) == 3);
	Main::assert(floor(exp(1.0)) == 2);
	Main::assert(floor(99.9) == 99);
	Main::assert(std::isfinite((double)12));
	Main::assert(isnan(nan("")));
	Main::assert(!std::isfinite(std::numeric_limits<double>::infinity()));
	Main::assert(!std::isfinite(-std::numeric_limits<double>::infinity()));
	Main::assertFloat(sin(3.14159265358979323846), 0.0);
	Main::assertFloat(cos(0), 1);
	Main::assertFloat(tan(4), 1.157821);
	Main::assertFloat(asin(1), 1.570796);
	Main::assert(isnan(acos(100)));
	Main::assertFloat(atan(12), 1.4876);
	Main::assertFloat(atan2(-3, 3), -0.78539);
	Main::assertFloat(log(10), 2.30258);
	Main::assert(sqrt(25) == 5);
	Main::assert(sqrt(100) == 10);
}
