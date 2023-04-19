#include "haxe_Log.h"

#include <deque>
#include <functional>
#include <memory>
#include <string>
#include "Std.h"
#include "ucpp_DynamicToString.h"

using namespace std::string_literals;

std::function<void(haxe::DynamicToString, std::optional<std::shared_ptr<haxe::PosInfos>>)> haxe::Log::trace = [](haxe::DynamicToString v, std::optional<std::shared_ptr<haxe::PosInfos>> infos = std::nullopt) mutable {
	std::string str = haxe::Log::formatOutput(v, infos);
	std::cout << Std::string(str) << std::endl;
};

std::string haxe::Log::formatOutput(std::string v, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(!infos.has_value()) {
		return v;
	};
	
	std::string pstr = infos.value()->fileName + ":"s + std::to_string(infos.value()->lineNumber);
	std::string extra = ""s;
	
	if(infos.value()->customParams.has_value()) {
		int _g = 0;
		std::optional<std::shared_ptr<std::deque<haxe::DynamicToString>>> _g1 = infos.value()->customParams;
		while(_g < _g1.value()->size()) {
			haxe::DynamicToString v2 = (*_g1.value())[_g];
			++_g;
			extra += ", "s + v2;
		};
	};
	
	return pstr + ": "s + v + extra;
}