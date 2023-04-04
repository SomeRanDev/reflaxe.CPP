#include <memory>
#include "Main.h"
#include "Sys.h"

int main(int argc, const char* argv[]) {
	SysImpl::setupArgs(argc, argv);
	Main::main();
	return 0;
}
