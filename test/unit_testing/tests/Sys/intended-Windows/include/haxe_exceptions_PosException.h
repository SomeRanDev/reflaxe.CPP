#pragma once

#include <memory>
#include <optional>
#include <string>
#include "_HaxeUtils.h"
#include "haxe_Exception.h"
#include "haxe_PosInfos.h"

namespace haxe::exceptions {

class PosException: public haxe::Exception {
public:
	std::shared_ptr<haxe::PosInfos> posInfos;

	PosException(std::string message, std::optional<haxe::Exception> previous = std::nullopt, std::optional<std::shared_ptr<haxe::PosInfos>> pos = std::nullopt);
	
	std::string toString();
	
	HX_COMPARISON_OPERATORS(PosException)
};

}


#include "dynamic/Dynamic_haxe_exceptions_PosException.h"


// Reflection info
#include "_TypeUtils.h"
namespace haxe {
	template<> struct _class<haxe::exceptions::PosException> {
		DEFINE_CLASS_TOSTRING
	using Dyn = haxe::Dynamic_haxe_exceptions_PosException;
		constexpr static _class_data<2, 0> data {"PosException", { "posInfos", "toString" }, {}, true};
	};
}
