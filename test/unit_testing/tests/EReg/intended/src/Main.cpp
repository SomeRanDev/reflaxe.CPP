#include "Main.h"

#include <functional>
#include <iostream>
#include <string>
#include "_AnonStructs.h"
#include "EReg.h"

int Main::returnCode = 0;

void Main::assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(!b) {
		{
			auto temp = infos.value_or(haxe::shared_anon<haxe::PosInfos>("", "test/unit_testing/tests/EReg/Main.hx", 10, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed" << std::endl;
		};
		Main::returnCode = 1;
	};
}

void Main::main() {
	EReg reg = EReg("abc", "");
	bool result = reg.match("abcdef");
	
	Main::assert(result, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 20, "main"));
	Main::assert(reg.matched(0) == "abc", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 23, "main"));
	Main::assert(reg.matched(1) == "", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 24, "main"));
	
	std::shared_ptr<haxe::AnonStruct0> pos = reg.matchedPos();
	
	Main::assert(pos->pos == 0, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 28, "main"));
	Main::assert(pos->len == 3, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 29, "main"));
	
	EReg reg2 = EReg("abc", "");
	
	Main::assert(reg2.matchSub("abcabc", 1), haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 33, "main"));
	
	std::shared_ptr<haxe::AnonStruct0> pos2 = reg2.matchedPos();
	
	Main::assert(pos2->pos == 3, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 36, "main"));
	Main::assert(pos2->len == 3, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 37, "main"));
	Main::assert(reg2.matched(0) == "abc", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 38, "main"));
	Main::assert(reg2.matchedLeft() == "abc", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 39, "main"));
	Main::assert(reg2.matchedRight() == "", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 40, "main"));
	
	EReg capReg = EReg("(a)(.)b", "");
	
	Main::assert(capReg.match("Check this out: a#b and also this: a_b."), haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 44, "main"));
	Main::assert(capReg.matched(0) == "a#b", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 45, "main"));
	Main::assert(capReg.matched(1) == "a", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 46, "main"));
	Main::assert(capReg.matched(2) == "#", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 47, "main"));
	Main::assert(capReg.matched(3) == "", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 48, "main"));
	Main::assert(capReg.matched(-1) == "", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 49, "main"));
	Main::assert(capReg.matched(9999) == "", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 50, "main"));
	Main::assert(EReg("splitme", "").split("") == std::deque<std::string>{ "" }, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 53, "main"));
	Main::assert(EReg("splitme", "").split("Hello world!") == std::deque<std::string>{
		"Hello world!"
	}, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 54, "main"));
	Main::assert(EReg("\\s*,\\s*", "").split("one,two ,three, four") == std::deque<std::string>{
		"one",
		"two",
		"three",
		"four"
	}, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 55, "main"));
	Main::assert(reg.replace("123abc", "456") == "123456", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 58, "main"));
	Main::assert(EReg("\\|([a-z]+)\\|", "g").replace("|a| |b| fdsf tew |cdef|", "($1)") == "(a) (b) fdsf tew (cdef)", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 59, "main"));
	
	std::string newStr = reg.map("123abc", [&](EReg ereg) mutable {
		std::shared_ptr<haxe::AnonStruct0> p = ereg.matchedPos();
		return ereg.matched(0) + "_data:(" + std::to_string(p->len) + ", " + std::to_string(p->pos) + ")";
	});
	
	Main::assert(newStr == "123abc_data:(3, 3)", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 66, "main"));
	Main::assert(EReg::escape("...") == "\\.\\.\\.", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 69, "main"));
	
	if(Main::returnCode != 0) {
		exit(Main::returnCode);
	};
}
