#pragma once

#include <functional>
#include <iostream>
#include <memory>
#include <optional>
#include <string>
#include "_AnonUtils.h"
#include "cxx_DynamicToString.h"
#include "haxe_PosInfos.h"

namespace haxe {

class Log {
public:
	static std::function<void(haxe::DynamicToString, std::optional<std::shared_ptr<haxe::PosInfos>>)> trace;

	static std::string formatOutput(std::string v, std::optional<std::shared_ptr<haxe::PosInfos>> infos = std::nullopt);
};

}
