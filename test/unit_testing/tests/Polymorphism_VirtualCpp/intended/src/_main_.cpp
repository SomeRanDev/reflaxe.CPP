#include <memory>
#include "Main.h"
#include "Sys.h"

int main(int argc, const char* argv[]) {
	SysImpl::setupArgs(argc, argv);
	_Main::Main_Fields_::main();
	return 0;
}
