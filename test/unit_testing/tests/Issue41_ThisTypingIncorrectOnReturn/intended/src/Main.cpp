#include "Main.h"

#include <memory>

void _Main::Main_Fields_::main() {
	std::make_shared<FooBuilder>()->withBar();
}
FooBuilder::FooBuilder():
	_order_id(generate_order_id())
{

}

FooBuilder* FooBuilder::withBar() {
	FooBuilder* r = this;

	return r;
}
