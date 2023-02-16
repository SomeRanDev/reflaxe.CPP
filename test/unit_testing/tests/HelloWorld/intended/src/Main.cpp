#include "Main.h"

#include <memory>
#include "haxe_Log.h"


void _Main::Main_Fields_::main() {
	haxe::Log::trace("Hello world!", std::make_shared<haxe::PosInfos>("_Main.Main_Fields_", "test/unit_testing/tests/HelloWorld/Main.hx", 4, "main"));
}
