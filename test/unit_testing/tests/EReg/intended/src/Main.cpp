#include "Main.h"

#include <functional>
#include <iostream>
#include <memory>
#include <string>
#include "_AnonStructs.h"
#include "EReg.h"

using namespace std::string_literals;

int Main::returnCode = 0;

void Main::assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(!b) {
		{
			auto temp = infos.value_or(haxe::shared_anon<haxe::PosInfos>("", "test/unit_testing/tests/EReg/Main.hx"s, 10, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed"s << std::endl;
		};
		Main::returnCode = 1;
	};
}

void Main::main() {
	EReg reg = EReg("abc"s, ""s);
	bool result = reg.match("abcdef"s);
	
	Main::assert(result, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/EReg/Main.hx"s, 20, "main"s));
	Main::assert(reg.matched(0) == "abc"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/EReg/Main.hx"s, 23, "main"s));
	Main::assert(reg.matched(1) == ""s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/EReg/Main.hx"s, 24, "main"s));
	
	std::shared_ptr<haxe::AnonStruct0> pos = reg.matchedPos();
	
	Main::assert(pos->pos == 0, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/EReg/Main.hx"s, 28, "main"s));
	Main::assert(pos->len == 3, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/EReg/Main.hx"s, 29, "main"s));
	
	EReg reg2 = EReg("abc"s, ""s);
	
	Main::assert(reg2.matchSub("abcabc"s, 1), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/EReg/Main.hx"s, 33, "main"s));
	
	std::shared_ptr<haxe::AnonStruct0> pos2 = reg2.matchedPos();
	
	Main::assert(pos2->pos == 3, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/EReg/Main.hx"s, 36, "main"s));
	Main::assert(pos2->len == 3, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/EReg/Main.hx"s, 37, "main"s));
	Main::assert(reg2.matched(0) == "abc"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/EReg/Main.hx"s, 38, "main"s));
	Main::assert(reg2.matchedLeft() == "abc"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/EReg/Main.hx"s, 39, "main"s));
	Main::assert(reg2.matchedRight() == ""s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/EReg/Main.hx"s, 40, "main"s));
	
	EReg capReg = EReg("(a)(.)b"s, ""s);
	
	Main::assert(capReg.match("Check this out: a#b and also this: a_b."s), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/EReg/Main.hx"s, 44, "main"s));
	Main::assert(capReg.matched(0) == "a#b"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/EReg/Main.hx"s, 45, "main"s));
	Main::assert(capReg.matched(1) == "a"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/EReg/Main.hx"s, 46, "main"s));
	Main::assert(capReg.matched(2) == "#"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/EReg/Main.hx"s, 47, "main"s));
	Main::assert(capReg.matched(3) == ""s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/EReg/Main.hx"s, 48, "main"s));
	Main::assert(capReg.matched(-1) == ""s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/EReg/Main.hx"s, 49, "main"s));
	Main::assert(capReg.matched(9999) == ""s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/EReg/Main.hx"s, 50, "main"s));
	Main::assert((*EReg("splitme"s, ""s).split(""s)) == (*std::make_shared<std::deque<std::string>>(std::deque<std::string>{ ""s })), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/EReg/Main.hx"s, 53, "main"s));
	Main::assert((*EReg("splitme"s, ""s).split("Hello world!"s)) == (*std::make_shared<std::deque<std::string>>(std::deque<std::string>{
		"Hello world!"s
	})), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/EReg/Main.hx"s, 54, "main"s));
	Main::assert((*EReg("\\s*,\\s*"s, ""s).split("one,two ,three, four"s)) == (*std::make_shared<std::deque<std::string>>(std::deque<std::string>{
		"one"s,
		"two"s,
		"three"s,
		"four"s
	})), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/EReg/Main.hx"s, 55, "main"s));
	Main::assert(reg.replace("123abc"s, "456"s) == "123456"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/EReg/Main.hx"s, 58, "main"s));
	Main::assert(EReg("\\|([a-z]+)\\|"s, "g"s).replace("|a| |b| fdsf tew |cdef|"s, "($1)"s) == "(a) (b) fdsf tew (cdef)"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/EReg/Main.hx"s, 59, "main"s));
	
	std::string newStr = reg.map("123abc"s, [&](EReg ereg) mutable {
		std::shared_ptr<haxe::AnonStruct0> p = ereg.matchedPos();
		return ereg.matched(0) + "_data:("s + std::to_string(p->len) + ", "s + std::to_string(p->pos) + ")"s;
	});
	
	Main::assert(newStr == "123abc_data:(3, 3)"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/EReg/Main.hx"s, 66, "main"s));
	Main::assert(EReg::escape("..."s) == "\\.\\.\\."s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/EReg/Main.hx"s, 69, "main"s));
	
	if(Main::returnCode != 0) {
		exit(Main::returnCode);
	};
}
