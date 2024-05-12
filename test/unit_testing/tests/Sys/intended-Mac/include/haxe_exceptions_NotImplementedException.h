#pragma once

#include <memory>
#include <optional>
#include <string>
#include "_HaxeUtils.h"
#include "haxe_Exception.h"
#include "haxe_exceptions_PosException.h"
#include "haxe_PosInfos.h"

namespace haxe::exceptions {

class NotImplementedException: public haxe::exceptions::PosException {
public:
	NotImplementedException(std::string message = std::string("Not implemented"), std::optional<haxe::Exception> previous = std::nullopt, std::optional<std::shared_ptr<haxe::PosInfos>> pos = std::nullopt);

	HX_COMPARISON_OPERATORS(NotImplementedException)
};

}


#include "dynamic/Dynamic_haxe_exceptions_NotImplementedException.h"


// Reflection info
#include "_TypeUtils.h"
namespace haxe {
	template<> struct _class<haxe::exceptions::NotImplementedException> {
		DEFINE_CLASS_TOSTRING
		using Dyn = haxe::Dynamic_haxe_exceptions_NotImplementedException;
		constexpr static _class_data<0, 0> data {"NotImplementedException", {}, {}, true};
	};
}
