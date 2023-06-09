#include "Main.h"

#include <deque>
#include <iostream>
#include <memory>
#include <string>
#include "_AnonStructs.h"
#include "EReg.h"
#include "haxe_Constraints.h"
#include "haxe_ds_IntMap.h"
#include "haxe_Log.h"
#include "Std.h"

using namespace std::string_literals;

void _Main::Main_Fields_::main() {
	std::shared_ptr<std::deque<int>> arr = std::make_shared<std::deque<int>>(std::deque<int>{ 1, 2, 3 });
	std::shared_ptr<haxe::ds::IntMap<int>> _g = std::make_shared<haxe::ds::IntMap<int>>();

	_g->set(1, 1);
	_g->set(2, 2);

	EReg regex = EReg("[a-zA-Z]+"s, ""s);

	haxe::Log::trace(arr, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/TraceAndPrint/Main.hx"s, 8, "main"s));

	std::string tempString = _g->toString();

	haxe::Log::trace(tempString, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/TraceAndPrint/Main.hx"s, 9, "main"s));
	haxe::Log::trace(regex, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/TraceAndPrint/Main.hx"s, 10, "main"s));
	std::cout << Std::string(arr) << std::endl;
	std::cout << Std::string(_g) << std::endl;
	std::cout << Std::string(regex) << std::endl;
}
