#include "Other2.h"

Other2::Other2(std::optional<std::shared_ptr<Main>> main):
	_order_id(generate_order_id())
{
	this->main = (*main.value_or(nullptr));
}
