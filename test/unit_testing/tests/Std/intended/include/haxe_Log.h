#pragma once

#include <functional>
#include <iostream>
#include <memory>
#include <optional>
#include <string>
#include "haxe_PosInfos.h"

namespace haxe {

class Log {
public:
	static std::function<void(std::string, std::optional<std::shared_ptr<haxe::PosInfos>>)> trace;

	static std::string formatOutput(std::string v, std::optional<std::shared_ptr<haxe::PosInfos>> infos = std::nullopt);
};

}
