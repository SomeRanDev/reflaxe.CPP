#include "Main.h"

#include <memory>
#include <string>
#include "_AnonStructs.h"
#include "CppCode.h"
#include "haxe_Log.h"

using namespace std::string_literals;

void _Main::Main_Fields_::main() {
	haxe::Log::trace(cpp_func(123), haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Interop_CPP/Main.hx"s, 21, "main"s));

	std::shared_ptr<MyClass> cls = std::make_shared<MyClass>((double)(10));

	haxe::Log::trace(cls->getValue(), haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Interop_CPP/Main.hx"s, 25, "main"s));
	cls->increment();
	haxe::Log::trace(cls->getValue(), haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Interop_CPP/Main.hx"s, 28, "main"s));
	cls->increment((double)(9));
	haxe::Log::trace(cls->getValue(), haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Interop_CPP/Main.hx"s, 31, "main"s));
}
