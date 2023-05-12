#include "Main.h"

#include "_AnonStructs.h"
#include "_TypeUtils.h"
#include "Std.h"
#include "StringTools.h"
#include <cmath>
#include <cstdlib>
#include <iostream>
#include <memory>
#include <string>
using namespace std::string_literals;

int Main::returnCode = 0;

void Main::assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(!b) {
		{
			auto temp = infos.value_or(haxe::shared_anon<haxe::PosInfos>("", "test/unit_testing/tests/Std/Main.hx"s, 29, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed"s << std::endl;
		};
		Main::returnCode = 1;
	};
}

void Main::assertFloat(double a, double b, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(abs(a - b) >= 0.001) {
		{
			auto temp = infos.value_or(haxe::shared_anon<haxe::PosInfos>("", "test/unit_testing/tests/Std/Main.hx"s, 36, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed"s << std::endl;
		};
		Main::returnCode = 1;
	};
}

void Main::main() {
	std::shared_ptr<BaseClass> base = std::make_shared<BaseClass>();
	std::shared_ptr<ChildClass> child = std::make_shared<ChildClass>();
	std::shared_ptr<AnotherClass> another = std::make_shared<AnotherClass>();
	
	Main::assert(StdImpl::isOfType<std::shared_ptr<ChildClass>, haxe::_class<ChildClass>>(child, haxe::_class<ChildClass>()), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 47, "main"s));
	Main::assert(StdImpl::isOfType<std::shared_ptr<ChildClass>, haxe::_class<BaseClass>>(child, haxe::_class<BaseClass>()), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 48, "main"s));
	Main::assert(!StdImpl::isOfType<std::shared_ptr<ChildClass>, haxe::_class<AnotherClass>>(child, haxe::_class<AnotherClass>()), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 49, "main"s));
	Main::assert(!StdImpl::isOfType<std::shared_ptr<AnotherClass>, haxe::_class<ChildClass>>(another, haxe::_class<ChildClass>()), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 51, "main"s));
	Main::assert(!StdImpl::isOfType<std::shared_ptr<AnotherClass>, haxe::_class<BaseClass>>(another, haxe::_class<BaseClass>()), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 52, "main"s));
	Main::assert(StdImpl::isOfType<std::shared_ptr<AnotherClass>, haxe::_class<AnotherClass>>(another, haxe::_class<AnotherClass>()), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 53, "main"s));
	
	std::optional<int> a = std::nullopt;
	
	Main::assert(Std::string(a) == "null"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 57, "main"s));
	a = 123;
	Main::assert(Std::string(a) == "123"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 60, "main"s));
	Main::assert(Std::string(haxe::_class<Main>()) == "Class<Main>"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 62, "main"s));
	Main::assert(Std::string(haxe::_class<Std>()) == "Class<Std>"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 63, "main"s));
	Main::assert(Std::string(another) == "another class as string"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 65, "main"s));
	Main::assert(Std::string(another) == another->toString(), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 66, "main"s));
	
	AnotherClass anotherVal = AnotherClass();
	
	Main::assert(Std::string(anotherVal) == anotherVal.toString(), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 69, "main"s));
	Main::assert(StringTools::startsWith(Std::string(base), "<unknown(address:"s), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 71, "main"s));
	
	BaseClass baseVal = BaseClass();
	
	Main::assert(StringTools::startsWith(Std::string(baseVal), "<unknown(address:"s), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 74, "main"s));
	
	ClassWInt numVal = ClassWInt();
	
	Main::assert(StringTools::startsWith(Std::string(numVal), "<unknown(address:"s), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 77, "main"s));
	Main::assert(4 == 4, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 80, "main"s));
	Main::assert(0 == 0, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 81, "main"s));
	Main::assert(0 == 0, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 82, "main"s));
	Main::assert(1 == 1, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 83, "main"s));
	Main::assert(Std::parseInt("0"s) == 0, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 86, "main"s));
	Main::assert(Std::parseInt("123"s) == 123, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 87, "main"s));
	Main::assert(!Std::parseInt("number!"s).has_value(), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 88, "main"s));
	Main::assert(Std::parseInt("1"s).has_value(), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 89, "main"s));
	Main::assertFloat(Std::parseFloat("1.1"s), 1.1, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 92, "main"s));
	Main::assertFloat(Std::parseFloat("2.0"s), 2.0, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 93, "main"s));
	Main::assertFloat(Std::parseFloat("0.5"s), 0.5, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 94, "main"s));
	Main::assertFloat(Std::parseFloat("0.0001"s), 0.0001, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 95, "main"s));
	Main::assert(std::isnan(Std::parseFloat("another number!"s)), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 96, "main"s));
	Main::assert(!std::isnan(Std::parseFloat("0"s)), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 97, "main"s));
	
	int _g = 0;
	
	while(_g < 1000) {
		_g++;
		int tempNumber;
		
		if(10 <= 1) {
			tempNumber = 0;
		} else {
			tempNumber = static_cast<int>(floor((((float)rand()) / RAND_MAX) * 10));
		};
		
		int v = tempNumber;
		
		Main::assert((v >= 0) && (v < 10), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Std/Main.hx"s, 103, "main"s));
	};
	
	if(Main::returnCode != 0) {
		exit(Main::returnCode);
	};
}
BaseClass::BaseClass(): _order_id(generate_order_id()) {
	
}
ChildClass::ChildClass(): _order_id(generate_order_id()) {
	BaseClass();
}
AnotherClass::AnotherClass(): _order_id(generate_order_id()) {
	
}

std::string AnotherClass::toString() {
	return "another class as string"s;
}
ClassWInt::ClassWInt(): _order_id(generate_order_id()) {
	this->number = 123;
}
