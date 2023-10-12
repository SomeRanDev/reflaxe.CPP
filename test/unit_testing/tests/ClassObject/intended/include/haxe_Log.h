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


// Reflection info
#include "_TypeUtils.h"
namespace haxe {
	template<> struct _class<haxe::Log> {
		DEFINE_CLASS_TOSTRING
		constexpr static _class_data<0, 2> data {"Log", {}, { "formatOutput", "trace" }, false};
	};
}
