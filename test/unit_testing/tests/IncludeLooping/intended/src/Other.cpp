#include "Other.h"

#include <memory>
#include "Other2.h"

Other::Other(std::optional<std::shared_ptr<Other2>> main):
	_order_id(generate_order_id())
{
	this->main = main.value_or(nullptr);
}
