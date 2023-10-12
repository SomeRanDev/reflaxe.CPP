#include "Main.h"

#include <memory>
#include "baz_Baz.h"
#include "foo_Baz.h"

void _Main::Main_Fields_::main() {
	static_cast<void>(std::make_shared<foo::Baz>());
	static_cast<void>(std::make_shared<baz::Baz>());
}
