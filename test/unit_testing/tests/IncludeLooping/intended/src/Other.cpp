#include "Other.h"

#include <memory>
#include "Other2.h"

Other::Other(std::optional<std::shared_ptr<Other2>> main2):
	_order_id(generate_order_id())
{
	this->main = main2.value_or(nullptr);
}
