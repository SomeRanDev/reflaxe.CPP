#include "Main.h"

#include "_AnonStructs.h"
#include "StringTools.h"
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

void Main::testBackOpt(int first, std::string second) {
	Main::assert(first < 0, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/OptionalArguments/Main.hx"s, 15, "testBackOpt"s));
	Main::assert(StringTools::startsWith(second, "test"s), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/OptionalArguments/Main.hx"s, 16, "testBackOpt"s));
}

void Main::testFrontOpt(int first, std::string second) {
	Main::assert(first > 100, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/OptionalArguments/Main.hx"s, 20, "testFrontOpt"s));
	Main::assert(second == "test"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/OptionalArguments/Main.hx"s, 21, "testFrontOpt"s));
}

void Main::testQuestionOpt(std::optional<int> maybeInt, std::optional<std::string> maybeString) {
	if(!maybeInt.has_value()) {
		Main::assert(!maybeInt.has_value(), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/OptionalArguments/Main.hx"s, 25, "testQuestionOpt"s));
	} else {
		Main::assert(maybeInt == 111, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/OptionalArguments/Main.hx"s, 26, "testQuestionOpt"s));
	};
	if(!maybeString.has_value()) {
		Main::assert(!maybeString.has_value(), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/OptionalArguments/Main.hx"s, 28, "testQuestionOpt"s));
	} else {
		Main::assert(maybeString == "111"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/OptionalArguments/Main.hx"s, 29, "testQuestionOpt"s));
	};
}

void Main::testMixedOpt(int first, std::string second, bool third, int fourth) {
	Main::assert(first >= 100, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/OptionalArguments/Main.hx"s, 33, "testMixedOpt"s));
	Main::assert(StringTools::startsWith(second, "test"s), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/OptionalArguments/Main.hx"s, 34, "testMixedOpt"s));
	Main::assert(third, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/OptionalArguments/Main.hx"s, 35, "testMixedOpt"s));
	Main::assert(fourth < 0, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/OptionalArguments/Main.hx"s, 36, "testMixedOpt"s));
}

void Main::main() {
	Main::testBackOpt(-1, "test"s);
	Main::testBackOpt(-100, "testthing"s);
	Main::testFrontOpt(101, "test"s);
	Main::testFrontOpt(123, "test"s);
	Main::testQuestionOpt(111, std::nullopt);
	Main::testQuestionOpt(std::nullopt, "111"s);
	Main::testQuestionOpt(std::nullopt, std::nullopt);
	Main::testQuestionOpt(std::nullopt, "111"s);
	Main::testQuestionOpt(111, std::nullopt);
	Main::testMixedOpt(100, "test"s, true, -1);
	Main::testMixedOpt(101, "test"s, true, -1);
	Main::testMixedOpt(100, "test"s, true, -1);
	Main::testMixedOpt(102, "test"s, true, -1);
	
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
	Main::assert(other == "other"s, haxe::shared_anon<haxe::PosInfos>("Base"s, "test/unit_testing/tests/OptionalArguments/Main.hx"s, 75, "doThing"s));
	Main::assert(num == 100, haxe::shared_anon<haxe::PosInfos>("Base"s, "test/unit_testing/tests/OptionalArguments/Main.hx"s, 76, "doThing"s));
}

void Base::doThing2(std::optional<int> num, std::string other) {
	if(!num) num = 100;
	
	Main::assert(other == "other"s, haxe::shared_anon<haxe::PosInfos>("Base"s, "test/unit_testing/tests/OptionalArguments/Main.hx"s, 80, "doThing2"s));
	Main::assert(num == 100, haxe::shared_anon<haxe::PosInfos>("Base"s, "test/unit_testing/tests/OptionalArguments/Main.hx"s, 81, "doThing2"s));
}
Child::Child(): _order_id(generate_order_id()) {
	Base();
}

void Child::doThing(int num, std::string other) {
	Main::assert(other == "other"s, haxe::shared_anon<haxe::PosInfos>("Child"s, "test/unit_testing/tests/OptionalArguments/Main.hx"s, 87, "doThing"s));
	Main::assert(num == 100, haxe::shared_anon<haxe::PosInfos>("Child"s, "test/unit_testing/tests/OptionalArguments/Main.hx"s, 88, "doThing"s));
}

void Child::doThing2(std::optional<int> num, std::string other) {
	if(!num) num = 200;
	
	Main::assert(other == "other"s, haxe::shared_anon<haxe::PosInfos>("Child"s, "test/unit_testing/tests/OptionalArguments/Main.hx"s, 93, "doThing2"s));
	Main::assert(num == 200, haxe::shared_anon<haxe::PosInfos>("Child"s, "test/unit_testing/tests/OptionalArguments/Main.hx"s, 94, "doThing2"s));
}
