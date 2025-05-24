#include "Main.h"

#include <cstdlib>
#include <functional>
#include <iostream>
#include <string>
#include "_AnonStructs.h"

using namespace std::string_literals;

int Main::thing = 0;

int Main::returnCode = 0;

void Main::assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(!b) {
		{
			auto temp = infos.value_or(haxe::shared_anon<haxe::PosInfos>("", "test/unit_testing/tests/FunctionObjects/Main.hx"s, 9, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed"s << std::endl;
		};
		Main::returnCode = 1;
	};
}

void Main::bla() {
	Main::thing++;
}

void Main::main() {
	std::function<void()> func = Main::bla;

	func();
	Main::assert(Main::thing == 1, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/FunctionObjects/Main.hx"s, 22, "main"s));

	std::optional<std::function<void()>> func2 = std::nullopt;

	if(!func2.has_value()) {
		func2 = Main::bla;
	};

	func2.value_or(nullptr)();
	Main::assert(Main::thing == 2, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/FunctionObjects/Main.hx"s, 29, "main"s));

	if(Main::returnCode != 0) {
		exit(Main::returnCode);
	};
}
