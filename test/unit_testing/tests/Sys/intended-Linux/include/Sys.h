#pragma once

#include <deque>
#include <memory>
#include <string>
#include "haxe_ds_StringMap.h"
#include "Map.h"

class SysImpl {
public:
	static std::deque<std::string> _args;

	static void setupArgs(int argCount, const char** args);
	
	static std::shared_ptr<std::deque<std::string>> args();
	
	static std::shared_ptr<haxe::ds::StringMap<std::string>> environment();
	
	static std::string systemName();
};

