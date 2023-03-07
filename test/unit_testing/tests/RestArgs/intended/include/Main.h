#pragma once

#include <memory>
#include <optional>
#include "haxe_PosInfos.h"
#include "haxe_Rest.h"

class Main {
public:
	static int returnCode;

	static void assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos = std::nullopt);
	
	static void oneTwoThree(std::shared_ptr<haxe::_Rest::NativeRest<int>> numbers);
};


int main();
