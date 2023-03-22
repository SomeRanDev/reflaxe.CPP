#pragma once

#include <any>
#include <deque>
#include <memory>
#include <optional>
#include <string>
#include "haxe_PosInfos.h"

class Main {
public:
	int testField;
	
	static int returnCode;

	Main();
	
	static void assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos = std::nullopt);
	
	static void assertStringEq(std::string first, std::string second, std::optional<std::shared_ptr<haxe::PosInfos>> infos = std::nullopt);
	
	static void main();
};

