#include "Main.h"

#include <cmath>
#include <cstdlib>
#include <deque>
#include <iostream>
#include <memory>
#include <stdlib.h>
#include <string>
#include "_AnonStructs.h"
#include "haxe_Constraints.h"
#include "Sys.h"

using namespace std::string_literals;

int Main::returnCode = 0;

Main::Main(): _order_id(generate_order_id()) {
	this->a = 123;
}

void Main::assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(!b) {
		{
			auto temp = infos.value_or(haxe::shared_anon<haxe::PosInfos>("", "test/unit_testing/tests/Sys/Main.hx"s, 11, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed"s << std::endl;
		};
		Main::returnCode = 1;
	};
}

void Main::main() {
	std::string key = "Haxe2UC++ Test Value"s;
	int tempRight;
	
	if(10 <= 1) {
		tempRight = 0;
	} else {
		tempRight = floor((((float)rand()) / RAND_MAX) * 10);
	};
	
	std::string val = "test-value="s + std::to_string(tempRight);
	std::optional<std::string> tempLeft;
	
	{
		char* result = std::getenv(key.c_str());
		if(result == nullptr) {
			tempLeft = std::nullopt;
		} else {
			tempLeft = std::string(result);
		};
	};
	
	Main::assert(!tempLeft.has_value(), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 22, "main"s));
	
	if(static_cast<int>(val.size()) == 0) {
		unsetenv(key.c_str());
	} else {
		setenv(key.c_str(), val.c_str(), 1);
	};
	
	std::optional<std::string> tempLeft1;
	
	{
		char* result = std::getenv("Haxe2UC++ Test Value"s.c_str());
		if(result == nullptr) {
			tempLeft1 = std::nullopt;
		} else {
			tempLeft1 = std::string(result);
		};
	};
	
	Main::assert(tempLeft1 == val, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 24, "main"s));
	
	if(static_cast<int>(""s.size()) == 0) {
		unsetenv(key.c_str());
	} else {
		setenv(key.c_str(), ""s.c_str(), 1);
	};
	
	std::optional<std::string> tempLeft2;
	
	{
		char* result = std::getenv(key.c_str());
		if(result == nullptr) {
			tempLeft2 = std::nullopt;
		} else {
			tempLeft2 = std::string(result);
		};
	};
	
	Main::assert(!tempLeft2.has_value(), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 26, "main"s));
	
	std::string s = key + "env_map"s;
	
	if(static_cast<int>("123"s.size()) == 0) {
		unsetenv(s.c_str());
	} else {
		setenv(s.c_str(), "123"s.c_str(), 1);
	};
	
	std::shared_ptr<haxe::IMap<std::string, std::string>> this1 = SysImpl::environment();
	std::optional<std::string> tempLeft3 = this1->get(key + "env_map"s);
	
	Main::assert(tempLeft3 == "123"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 30, "main"s));
	
	std::shared_ptr<std::deque<std::string>> args = SysImpl::args();
	
	Main::assert(args->size() == 1, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 33, "main"s));
	Main::assert((*args)[0].find("test_out"s) >= 0, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 34, "main"s));
	
	if(Main::returnCode != 0) {
		exit(Main::returnCode);
	};
}
