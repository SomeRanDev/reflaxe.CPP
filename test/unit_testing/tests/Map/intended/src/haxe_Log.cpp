#include "haxe_Log.h"

#include <functional>
#include <string>

using namespace std::string_literals;

std::function<void(haxe::DynamicToString, std::optional<std::shared_ptr<haxe::PosInfos>>)> haxe::Log::trace = [](haxe::DynamicToString v, std::optional<std::shared_ptr<haxe::PosInfos>> infos = std::nullopt) mutable {
	std::string str = haxe::Log::formatOutput(v, infos);
	std::cout << str << std::endl;
};

std::string haxe::Log::formatOutput(std::string v, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(!infos.has_value()) {
		return v;
	};
	
	std::string pstr = infos.value()->fileName + ":"s + std::to_string(infos.value()->lineNumber);
	
	return pstr + ": "s + v;
}
