#include "Main.h"

#include <iostream>
#include <memory>
#include <string>
#include "_AnonStructs.h"
#include "_TypeUtils.h"
#include "haxe_Log.h"
#include "Std.h"

int Main::returnCode = 0;

void Main::assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(!b) {
		{
			auto temp = infos.value_or(haxe::shared_anon<haxe::PosInfos>("", "test/unit_testing/tests/Std/Main.hx", 10, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed" << std::endl;
		};
		Main::returnCode = 1;
	};
}

void Main::main() {
	std::optional<int> a = std::nullopt;
	
	haxe::Log::trace(Std::string<std::optional<int>>(a), haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 17, "main"));
	a = 123;
	haxe::Log::trace(Std::string<std::optional<int>>(a), haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 20, "main"));
	haxe::Log::trace(Std::string<haxe::_class<Std>>(haxe::_class<Std>()), haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 22, "main"));
	
	if(Main::returnCode != 0) {
		exit(Main::returnCode);
	};
}
