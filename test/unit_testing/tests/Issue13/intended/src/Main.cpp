#include "Main.h"

#include <memory>
#include <string>
#include "_AnonStructs.h"
#include "haxe_Log.h"

using namespace std::string_literals;

void _Main::Main_Fields_::main() {
	int i = 0;

	haxe::Log::trace(i, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Issue13/Main.hx"s, 5, "main"s));
}
