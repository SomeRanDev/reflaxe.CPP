#include "Main.h"

#include <memory>
#include <string>
#include "_AnonStructs.h"
#include "haxe_Log.h"

using namespace std::string_literals;

void _Main::Main_Fields_::main() {
	std::string r = _Main::Flexible_Impl_::toAny<std::string>(_Main::Flexible_Impl_::_new());

	haxe::Log::trace(r, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Issue20/Main.hx"s, 13, "main"s));
}
int _Main::Flexible_Impl_::_new() {
	int this1 = 1;

	return this1;
}
