#pragma once

#include "haxe_ds_StringMap.h"
#include "Map.h"
#include <chrono>
#include <deque>
#include <memory>
#include <string>

class Sys_Args {
public:
	static std::deque<std::string> _args;

	static void setupArgs(int argCount, const char** args);
	
	static std::shared_ptr<std::deque<std::string>> args();
};



class Sys_CpuTime {
public:
	static std::chrono::time_point<std::chrono::system_clock> _startTime;

	static void setupStart();
	
	static double cpuTime();
};



class Sys_Environment {
public:
	static std::shared_ptr<haxe::ds::StringMap<std::string>> environment();
};

