#pragma once

#include "haxe_ds_StringMap.h"
#include "Map.h"
#include <chrono>
#include <deque>
#include <memory>
#include <optional>
#include <string>

class Sys_GetEnv {
public:
	static std::optional<std::string> getEnv(std::string s);
};



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



#include "dynamic/Dynamic_Sys.h"
#include "dynamic/Dynamic_Sys.h"
#include "dynamic/Dynamic_Sys.h"
#include "dynamic/Dynamic_Sys.h"


// Reflection info
#include "_TypeUtils.h"
namespace haxe {
	template<> struct _class<Sys_GetEnv> {
		DEFINE_CLASS_TOSTRING
	using Dyn = haxe::Dynamic_Sys_GetEnv;
		constexpr static _class_data<0, 1> data {"Sys_GetEnv", {}, { "getEnv" }, true};
	};
	template<> struct _class<Sys_Environment> {
		DEFINE_CLASS_TOSTRING
	using Dyn = haxe::Dynamic_Sys_Environment;
		constexpr static _class_data<0, 1> data {"Sys_Environment", {}, { "environment" }, true};
	};
	template<> struct _class<Sys_Args> {
		DEFINE_CLASS_TOSTRING
	using Dyn = haxe::Dynamic_Sys_Args;
		constexpr static _class_data<0, 3> data {"Sys_Args", {}, { "_args", "setupArgs", "args" }, true};
	};
	template<> struct _class<Sys_CpuTime> {
		DEFINE_CLASS_TOSTRING
	using Dyn = haxe::Dynamic_Sys_CpuTime;
		constexpr static _class_data<0, 3> data {"Sys_CpuTime", {}, { "_startTime", "setupStart", "cpuTime" }, true};
	};
}
