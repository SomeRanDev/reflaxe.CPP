#include "Other2.h"

Other2::Other2(std::optional<std::shared_ptr<Main>> main2):
	_order_id(generate_order_id())
{
	this->main = (*main2.value_or(nullptr));
}
