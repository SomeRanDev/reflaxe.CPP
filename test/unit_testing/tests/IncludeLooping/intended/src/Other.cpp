#include "Other.h"

#include <memory>
#include "Main.h"

Other::Other(std::optional<std::shared_ptr<Main>> main):
	_order_id(generate_order_id())
{
	this->main = main.value_or(nullptr);
}
