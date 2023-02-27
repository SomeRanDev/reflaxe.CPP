#pragma once

#include <any>
#include <memory>
#include <optional>
#include "haxe_PosInfos.h"

class Main {
public:
	int testField;
	
	static int returnCode;

	Main();
	
	static void assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos = std::nullopt);
};


int main();
