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

int main() {
	EReg reg = EReg("abc", "");
	bool result = reg.match("abcdef");
	
	Main::assert(result, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 22, "main"));
	Main::assert(reg.matched(0) == "abc", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 25, "main"));
	Main::assert(reg.matched(1) == "", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 26, "main"));
	
	std::shared_ptr<haxe::AnonStruct0> pos = reg.matchedPos();
	
	Main::assert(pos->pos == 0, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 30, "main"));
	Main::assert(pos->len == 3, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 31, "main"));
	
	EReg reg2 = EReg("abc", "");
	
	Main::assert(reg2.matchSub("abcabc", 1), haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 35, "main"));
	
	std::shared_ptr<haxe::AnonStruct0> pos2 = reg2.matchedPos();
	
	Main::assert(pos2->pos == 3, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 38, "main"));
	Main::assert(pos2->len == 3, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 39, "main"));
	Main::assert(reg2.matched(0) == "abc", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 40, "main"));
	Main::assert(reg2.matchedLeft() == "abc", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 41, "main"));
	Main::assert(reg2.matchedRight() == "", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 42, "main"));
	
	EReg capReg = EReg("(a)(.)b", "");
	
	Main::assert(capReg.match("Check this out: a#b and also this: a_b."), haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 46, "main"));
	Main::assert(capReg.matched(0) == "a#b", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 47, "main"));
	Main::assert(capReg.matched(1) == "a", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 48, "main"));
	Main::assert(capReg.matched(2) == "#", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 49, "main"));
	Main::assert(capReg.matched(3) == "", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 50, "main"));
	Main::assert(capReg.matched(-1) == "", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 51, "main"));
	Main::assert(capReg.matched(9999) == "", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 52, "main"));
	Main::assert(EReg("splitme", "").split("") == std::deque<std::string>{ "" }, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 55, "main"));
	Main::assert(EReg("splitme", "").split("Hello world!") == std::deque<std::string>{
		"Hello world!"
	}, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 56, "main"));
	Main::assert(EReg("\\s*,\\s*", "").split("one,two ,three, four") == std::deque<std::string>{
		"one",
		"two",
		"three",
		"four"
	}, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 57, "main"));
	Main::assert(reg.replace("123abc", "456") == "123456", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 60, "main"));
	Main::assert(EReg("\\|([a-z]+)\\|", "g").replace("|a| |b| fdsf tew |cdef|", "($1)") == "(a) (b) fdsf tew (cdef)", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 61, "main"));
	
	std::string newStr = reg.map("123abc", [&](EReg ereg) mutable {
		std::shared_ptr<haxe::AnonStruct0> p = ereg.matchedPos();
		return ereg.matched(0) + "_data:(" + std::to_string(p->len) + ", " + std::to_string(p->pos) + ")";
	});
	
	Main::assert(newStr == "123abc_data:(3, 3)", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 68, "main"));
	Main::assert(EReg::escape("...") == "\\.\\.\\.", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/EReg/Main.hx", 71, "main"));
	
	return Main::returnCode;
}
