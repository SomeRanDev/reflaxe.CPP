#include "Main.h"

#include <iostream>
#include <memory>
#include <string>
#include "_AnonStructs.h"

using namespace std::string_literals;

ValueClass::ValueClass(): _order_id(generate_order_id()) {
	this->val = 100;
}
NormalClass::NormalClass(): _order_id(generate_order_id()) {
	
}
int _Main::Main_Fields_::exitCode = 0;

void _Main::Main_Fields_::assert(bool cond, std::optional<std::shared_ptr<haxe::PosInfos>> pos) {
	if(!cond) {
		{
			auto temp = pos.value_or(haxe::shared_anon<haxe::PosInfos>("", "test/unit_testing/tests/Typedef/Main.hx"s, 31, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed!"s << std::endl;
		};
		_Main::Main_Fields_::exitCode = 1;
	};
}

void _Main::Main_Fields_::main() {
	MyInt tdInt = 123;
	int realInt = 123;
	
	_Main::Main_Fields_::assert(tdInt == realInt, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Typedef/Main.hx"s, 40, "main"s));
	
	MyIntInt td2Int = 123;
	
	_Main::Main_Fields_::assert(td2Int == tdInt, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Typedef/Main.hx"s, 43, "main"s));
	
	ValueClass a = ValueClass();
	ValueClassPtr b = &a;
	ValueClassPtr2 c = b;
	ValueClassPtr2Value d = (*c);
	ValueClassPtr2ValueSharedPtr e = std::make_shared<ValueClassPtr2Value>(d);
	
	_Main::Main_Fields_::assert(a.val == 100, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Typedef/Main.hx"s, 51, "main"s));
	_Main::Main_Fields_::assert(b->val == 100, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Typedef/Main.hx"s, 52, "main"s));
	_Main::Main_Fields_::assert(c->val == 100, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Typedef/Main.hx"s, 53, "main"s));
	_Main::Main_Fields_::assert(d.val == 100, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Typedef/Main.hx"s, 54, "main"s));
	_Main::Main_Fields_::assert(e->val == 100, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Typedef/Main.hx"s, 55, "main"s));
	_Main::Main_Fields_::assert(a == (*e), haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Typedef/Main.hx"s, 57, "main"s));
	
	NormalClass f = NormalClass();
	
	_Main::Main_Fields_::assert(f == f, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Typedef/Main.hx"s, 60, "main"s));
	
	if(_Main::Main_Fields_::exitCode != 0) {
		exit(_Main::Main_Fields_::exitCode);
	};
}
