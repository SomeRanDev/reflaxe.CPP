#include "haxe_Log.h"

#include <deque>
#include <functional>
#include <iostream>
#include <memory>
#include <string>
#include "cxx_DynamicToString.h"
#include "haxe_NativeStackTrace.h"
#include "Std.h"

using namespace std::string_literals;

std::function<void(haxe::DynamicToString, std::optional<std::shared_ptr<haxe::PosInfos>>)> haxe::Log::trace = [](haxe::DynamicToString v, std::optional<std::shared_ptr<haxe::PosInfos>> infos = std::nullopt) mutable {
	HCXX_STACK_METHOD("std/cxx/_std/haxe/Log.hx"s, 24, 99, "haxe.Log"s, "trace.<unnamed>"s);
	std::string str = haxe::Log::formatOutput(v, infos);
	
	std::cout << Std::string(str) << std::endl;
};

std::string haxe::Log::formatOutput(std::string v, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	HCXX_STACK_METHOD("std/cxx/_std/haxe/Log.hx"s, 7, 2, "haxe.Log"s, "formatOutput"s);
	
	HCXX_LINE(8);
	if(!infos.has_value()) {
		HCXX_LINE(9);
		return v;
	};
	
	HCXX_LINE(12);
	std::string pstr = infos.value()->fileName + ":"s + std::to_string(infos.value()->lineNumber);
	HCXX_LINE(14);
	std::string extra = ""s;
	
	HCXX_LINE(15);
	if(infos.value()->customParams.has_value()) {
		HCXX_LINE(16);
		int _g = 0;
		HCXX_LINE(16);
		std::optional<std::shared_ptr<std::deque<haxe::DynamicToString>>> _g1 = infos.value()->customParams;
		
		HCXX_LINE(16);
		while(_g < (int)(_g1.value()->size())) {
			HCXX_LINE(16);
			haxe::DynamicToString v2 = (*_g1.value())[_g];
			
			HCXX_LINE(16);
			++_g;
			HCXX_LINE(17);
			extra += ", "s + v2;
		};
	};
	
	HCXX_LINE(21);
	return pstr + ": "s + v + extra;
}
