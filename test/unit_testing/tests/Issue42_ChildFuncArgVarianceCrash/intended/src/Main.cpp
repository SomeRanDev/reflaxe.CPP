#include "Main.h"

#include <cstdlib>
#include <iostream>
#include <memory>
#include <string>
#include "_AnonStructs.h"

using namespace std::string_literals;

int _Main::Main_Fields_::returnCode = 0;

void _Main::Main_Fields_::assert(bool v, bool v2, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(v != v2) {
		{
			auto temp = infos.value_or(haxe::shared_anon<haxe::PosInfos>("", "test/unit_testing/tests/Issue42_ChildFuncArgVarianceCrash/Main.hx"s, 6, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed"s << std::endl;
		};
		_Main::Main_Fields_::returnCode = 1;
	};
}

void _Main::Main_Fields_::main() {
	_Main::Main_Fields_::assert(std::make_shared<Foo>()->validateComponent(), true, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Issue42_ChildFuncArgVarianceCrash/Main.hx"s, 40, "main"s));
	_Main::Main_Fields_::assert(std::make_shared<Foo2>()->validateComponent(), false, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Issue42_ChildFuncArgVarianceCrash/Main.hx"s, 41, "main"s));
	_Main::Main_Fields_::assert(std::make_shared<Bar>()->validateComponent(), false, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Issue42_ChildFuncArgVarianceCrash/Main.hx"s, 42, "main"s));
	exit(_Main::Main_Fields_::returnCode);
}
Foo::Foo():
	_order_id(generate_order_id())
{

}

bool Foo::validateComponent(bool nextFrame) {
	return nextFrame;
}
Foo2::Foo2():
	Foo(), _order_id(generate_order_id())
{

}

bool Foo2::validateComponent(bool nextFrame) {
	return nextFrame;
}
Bar::Bar():
	_order_id(generate_order_id())
{

}

bool Bar::validateComponent(bool nextFrame) {
	return nextFrame;
}
