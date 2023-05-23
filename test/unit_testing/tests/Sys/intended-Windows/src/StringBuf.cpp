#include "StringBuf.h"

#include <string>
#include "HxString.h"

using namespace std::string_literals;

StringBuf::StringBuf():
	_order_id(generate_order_id())
{
	this->b = ""s;
}
