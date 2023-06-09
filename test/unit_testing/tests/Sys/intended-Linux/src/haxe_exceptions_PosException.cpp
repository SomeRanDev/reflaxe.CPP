#include "haxe_exceptions_PosException.h"

#include <string>
#include "_AnonStructs.h"
#include "HxString.h"

using namespace std::string_literals;

haxe::exceptions::PosException::PosException(std::string message, std::optional<haxe::Exception> previous, std::optional<std::shared_ptr<haxe::PosInfos>> pos):
	haxe::Exception(message, previous), _order_id(generate_order_id())
{

	if(!pos.has_value()) {
		this->posInfos = haxe::shared_anon<haxe::PosInfos>("(unknown)"s, "(unknown)"s, 0, "(unknown)"s);
	} else {
		this->posInfos = pos.value_or(nullptr);
	};
}

std::string haxe::exceptions::PosException::toString() {
	return ""s + haxe::Exception::toString() + " in "s + this->posInfos->className + "."s + this->posInfos->methodName + " at "s + this->posInfos->fileName + ":"s + std::to_string(this->posInfos->lineNumber);
}
