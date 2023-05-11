#include "Main.h"

#include <cmath>
#include <cstdlib>
#include <iostream>
#include <limits>
#include <math.h>
#include <string>
#include "_AnonStructs.h"

using namespace std::string_literals;

int Main::returnCode = 0;

void Main::assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(!b) {
		{
			auto temp = infos.value_or(haxe::shared_anon<haxe::PosInfos>("", "test/unit_testing/tests/Math/Main.hx"s, 10, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed"s << std::endl;
		};
		Main::returnCode = 1;
	};
}

void Main::assertFloat(double a, double b, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(abs(a - b) >= 0.001) {
		{
			auto temp = infos.value_or(haxe::shared_anon<haxe::PosInfos>("", "test/unit_testing/tests/Math/Main.hx"s, 17, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed"s << std::endl;
		};
		Main::returnCode = 1;
	};
}

void Main::main() {
	Main::assert(static_cast<int>(ceil(2 * pow(3.14159265358979323846, (double)(2)))) == 20, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Math/Main.hx"s, 23, "main"s));
	Main::assert(abs((double)(-3)) == 3, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Math/Main.hx"s, 25, "main"s));
	Main::assert(static_cast<int>(ceil(2.1)) == 3, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Math/Main.hx"s, 27, "main"s));
	Main::assert(static_cast<int>(ceil(0.9)) == 1, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Math/Main.hx"s, 28, "main"s));
	Main::assert(static_cast<int>(ceil(exp(1.0))) == 3, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Math/Main.hx"s, 30, "main"s));
	Main::assert(static_cast<int>(floor(exp(1.0))) == 2, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Math/Main.hx"s, 31, "main"s));
	Main::assert(static_cast<int>(floor(99.9)) == 99, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Math/Main.hx"s, 33, "main"s));
	Main::assert(std::isfinite((double)12), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Math/Main.hx"s, 35, "main"s));
	Main::assert(std::isnan(std::numeric_limits<double>::quiet_NaN()), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Math/Main.hx"s, 36, "main"s));
	Main::assert(!std::isfinite(std::numeric_limits<double>::infinity()), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Math/Main.hx"s, 37, "main"s));
	Main::assert(!std::isfinite(-std::numeric_limits<double>::infinity()), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Math/Main.hx"s, 38, "main"s));
	Main::assertFloat(sin(3.14159265358979323846), 0.0, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Math/Main.hx"s, 40, "main"s));
	Main::assertFloat(cos((double)(0)), (double)(1), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Math/Main.hx"s, 41, "main"s));
	Main::assertFloat(tan((double)(4)), 1.157821, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Math/Main.hx"s, 42, "main"s));
	Main::assertFloat(asin((double)(1)), 1.570796, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Math/Main.hx"s, 43, "main"s));
	Main::assert(std::isnan(acos((double)(100))), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Math/Main.hx"s, 44, "main"s));
	Main::assertFloat(atan((double)(12)), 1.4876, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Math/Main.hx"s, 45, "main"s));
	Main::assertFloat(atan2((double)(-3), (double)(3)), -0.78539, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Math/Main.hx"s, 46, "main"s));
	Main::assertFloat(log((double)(10)), 2.30258, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Math/Main.hx"s, 48, "main"s));
	Main::assert(sqrt((double)(25)) == 5, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Math/Main.hx"s, 50, "main"s));
	Main::assert(sqrt((double)(100)) == 10, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Math/Main.hx"s, 51, "main"s));
	
	if(Main::returnCode != 0) {
		exit(Main::returnCode);
	};
}
