#pragma once

#include <memory>
#include <optional>
#include <string>
#include "_HaxeUtils.h"
#include "haxe_ds_StringMap.h"
#include "Map.h"

class Main {
public:
	std::shared_ptr<haxe::ds::StringMap<int>> testMap;

	Main();
	
	void bla();
	
	static void main();
	
	HX_COMPARISON_OPERATORS(Main)
};

