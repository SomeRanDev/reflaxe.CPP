#include "StringBuf.h"

#include <string>

using namespace std::string_literals;

StringBuf::StringBuf(): _order_id(generate_order_id()) {
	this->b = ""s;
}
