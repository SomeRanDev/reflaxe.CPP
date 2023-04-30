#pragma once

#include <any>
#include <memory>
#include <optional>
#include <string>
#include "_HaxeUtils.h"
#include "haxe_PosInfos.h"

class Main {
public:
	int testField;
	
	static int returnCode;

	Main();
	
	static void assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos = std::nullopt);
	
	static void assertStringEq(std::string first, std::string second, std::optional<std::shared_ptr<haxe::PosInfos>> infos = std::nullopt);
	
	static void main();
	
	HX_COMPARISON_OPERATORS(Main)
};

