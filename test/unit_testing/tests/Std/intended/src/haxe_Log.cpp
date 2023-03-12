#include "haxe_Log.h"

#include <functional>

std::function<void(std::string, std::optional<std::shared_ptr<haxe::PosInfos>>)> haxe::Log::trace = [](std::string v, std::optional<std::shared_ptr<haxe::PosInfos>> infos = std::nullopt) mutable {
	std::string str = haxe::Log::formatOutput(v, infos);
	std::cout << str << std::endl;
};

std::string haxe::Log::formatOutput(std::string v, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(!infos.has_value()) {
		return v;
	};
	
	std::string pstr = infos.value()->fileName + ":" + std::to_string(infos.value()->lineNumber);
	
	return pstr + ": " + v;
}
