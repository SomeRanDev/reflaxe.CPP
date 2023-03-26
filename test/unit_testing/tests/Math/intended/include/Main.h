#pragma once

#include <deque>
#include <memory>
#include <optional>
#include <string>
#include "haxe_PosInfos.h"
#include "ucpp_DynamicToString.h"

class Main {
public:
	static int returnCode;

	static void assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos = std::nullopt);
	
	static void assertFloat(double a, double b, std::optional<std::shared_ptr<haxe::PosInfos>> infos = std::nullopt);
	
	static void main();
};

