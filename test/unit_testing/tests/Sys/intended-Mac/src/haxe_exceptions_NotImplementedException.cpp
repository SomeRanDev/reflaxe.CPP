#include "haxe_exceptions_NotImplementedException.h"

haxe::exceptions::NotImplementedException::NotImplementedException(std::string message, std::optional<haxe::Exception> previous, std::optional<std::shared_ptr<haxe::PosInfos>> pos):
	haxe::exceptions::PosException(message, previous, pos), _order_id(generate_order_id())
{

}
