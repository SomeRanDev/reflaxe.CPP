#include "Main.h"

#include "_AnonStructs.h"
#include <cstdlib>
#include <iostream>
#include <memory>
#include <string>
using namespace std::string_literals;

int Main::returnCode = 0;

void Main::assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(!b) {
		{
			auto temp = infos.value_or(haxe::shared_anon<haxe::PosInfos>("", "test/unit_testing/tests/OptionalArguments/Main.hx"s, 9, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed"s << std::endl;
		};
		Main::returnCode = 1;
	};
}

void Main::testFrontOpt(int first, std::string second) {
	Main::assert(first > 100, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/OptionalArguments/Main.hx"s, 15, "testFrontOpt"s));
	Main::assert(second == "test"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/OptionalArguments/Main.hx"s, 16, "testFrontOpt"s));
}

void Main::main() {
	Main::testFrontOpt(101, "test"s);
	Main::testFrontOpt(123, "test"s);
	
	std::shared_ptr<Base> a = std::static_pointer_cast<Base>(std::make_shared<Child>());
	
	a->doThing(100, "other"s);
	a->doThing2(std::nullopt, "other"s);
	
	if(Main::returnCode != 0) {
		exit(Main::returnCode);
	};
}
Base::Base(): _order_id(generate_order_id()) {
	
}

void Base::doThing(int num, std::string other) {
	Main::assert(other == "other"s, haxe::shared_anon<haxe::PosInfos>("Base"s, "test/unit_testing/tests/OptionalArguments/Main.hx"s, 38, "doThing"s));
	Main::assert(num == 100, haxe::shared_anon<haxe::PosInfos>("Base"s, "test/unit_testing/tests/OptionalArguments/Main.hx"s, 39, "doThing"s));
}

void Base::doThing2(std::optional<int> num, std::string other) {
	if(!num) num = 100;
	
	Main::assert(other == "other"s, haxe::shared_anon<haxe::PosInfos>("Base"s, "test/unit_testing/tests/OptionalArguments/Main.hx"s, 43, "doThing2"s));
	Main::assert(num == 100, haxe::shared_anon<haxe::PosInfos>("Base"s, "test/unit_testing/tests/OptionalArguments/Main.hx"s, 44, "doThing2"s));
}
Child::Child(): _order_id(generate_order_id()) {
	Base();
}

void Child::doThing(int num, std::string other) {
	Main::assert(other == "other"s, haxe::shared_anon<haxe::PosInfos>("Child"s, "test/unit_testing/tests/OptionalArguments/Main.hx"s, 50, "doThing"s));
	Main::assert(num == 100, haxe::shared_anon<haxe::PosInfos>("Child"s, "test/unit_testing/tests/OptionalArguments/Main.hx"s, 51, "doThing"s));
}

void Child::doThing2(std::optional<int> num, std::string other) {
	if(!num) num = 200;
	
	Main::assert(other == "other"s, haxe::shared_anon<haxe::PosInfos>("Child"s, "test/unit_testing/tests/OptionalArguments/Main.hx"s, 56, "doThing2"s));
	Main::assert(num == 200, haxe::shared_anon<haxe::PosInfos>("Child"s, "test/unit_testing/tests/OptionalArguments/Main.hx"s, 57, "doThing2"s));
}
