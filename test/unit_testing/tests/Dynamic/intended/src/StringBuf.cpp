#include "StringBuf.h"

#include <memory>
#include <string>
#include "haxe_NativeStackTrace.h"

using namespace std::string_literals;

StringBuf::StringBuf():
	_order_id(generate_order_id())
{
	HCXX_STACK_METHOD("Z:\\Haxe\\haxe\\std/StringBuf.hx"s, 44, 2, "StringBuf"s, "StringBuf"s);
	
	HCXX_LINE(45);
	this->b = ""s;
}
