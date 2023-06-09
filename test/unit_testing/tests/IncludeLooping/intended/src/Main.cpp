#include "Main.h"

#include <iostream>
#include <memory>
#include <string>
#include "_AnonStructs.h"
#include "EnumLoop1.h"
#include "EnumLoop2.h"
#include "haxe_Log.h"
#include "Other2.h"

using namespace std::string_literals;

void _Main::Main_Fields_::main() {
	std::cout << "test/unit_testing/tests/IncludeLooping/Main.hx:10: Hello world!"s << std::endl;

	std::shared_ptr<Main> m = std::make_shared<Main>();
	static_cast<void>(std::make_shared<Other2>(m));
	std::shared_ptr<EnumLoop1> e = EnumLoop1::None();
	std::shared_ptr<EnumLoop2> e2 = EnumLoop2::Thing(e);
	std::shared_ptr<EnumLoop1> e3 = EnumLoop1::Thing(e2);

	haxe::Log::trace(e3, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/IncludeLooping/Main.hx"s, 19, "main"s));
}
Main::Main():
	_order_id(generate_order_id())
{

}
