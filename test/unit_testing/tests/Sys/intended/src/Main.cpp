#include "Main.h"

#include <cmath>
#include <cstdlib>
#include <filesystem>
#include <iostream>
#include <memory>
#include <stdlib.h>
#include <string>
#include "_AnonStructs.h"
#include "haxe_Log.h"

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
	std::optional<std::string> tempMaybeString;
	
	{
		char* result = std::getenv("ANDROID_NDK_VERSION"s.c_str());
		if(result == nullptr) {
			tempMaybeString = std::nullopt;
		} else {
			tempMaybeString = std::string(result);
		};
	};
	
	haxe::Log::trace(tempMaybeString, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 18, "main"s));
	haxe::Log::trace(std::filesystem::current_path(), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 20, "main"s));
	
	int tempRight;
	
	if(10 <= 1) {
		tempRight = 0;
	} else {
		tempRight = floor((((float)rand()) / RAND_MAX) * 10);
	};
	
	std::string testStr = "test-value="s + std::to_string(tempRight);
	
	putenv(("Haxe2UC++ Test Value"s + "="s + testStr).c_str());
	
	std::optional<std::string> tempLeft;
	
	{
		char* result = std::getenv("Haxe2UC++ Test Value"s.c_str());
		if(result == nullptr) {
			tempLeft = std::nullopt;
		} else {
			tempLeft = std::string(result);
		};
	};
	
	Main::assert(tempLeft == testStr, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 25, "main"s));
	putenv(("Haxe2UC++ Test Value"s + "="s + ""s).c_str());
	
	std::optional<std::string> tempLeft1;
	
	{
		char* result = std::getenv("Haxe2UC++ Test Value"s.c_str());
		if(result == nullptr) {
			tempLeft1 = std::nullopt;
		} else {
			tempLeft1 = std::string(result);
		};
	};
	
	Main::assert(!tempLeft1.has_value(), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 29, "main"s));
	
	if(Main::returnCode != 0) {
		exit(Main::returnCode);
	};
}
