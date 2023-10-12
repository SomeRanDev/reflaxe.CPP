#include "Main.h"

#include <memory>
#include <string>
#include "_AnonStructs.h"
#include "_TypeUtils.h"
#include "haxe_Log.h"
#include "MyClass.h"

using namespace std::string_literals;

void _Main::Main_Fields_::main() {
	haxe::Log::trace(haxe::_class<MyClass>(), haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/ClassObject/Main.hx"s, 4, "main"s));
}
