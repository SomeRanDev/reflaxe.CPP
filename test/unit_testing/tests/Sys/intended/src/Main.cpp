#include "Main.h"

#include <cstdlib>
#include <iostream>
#include <memory>
#include <string>
#include "_AnonStructs.h"
#include "haxe_Log.h"

using namespace std::string_literals;

int Main::returnCode = 0;

Main::Main() {
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
	char* result = std::getenv("ANDROID_NDK_VERSION"s.c_str());
	
	if(result == nullptr) {
		tempMaybeString = std::nullopt;
	} else {
		tempMaybeString = std::string(result);
	};
	
	haxe::Log::trace(tempMaybeString, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 18, "main"s));
	
	if(Main::returnCode != 0) {
		exit(Main::returnCode);
	};
}
