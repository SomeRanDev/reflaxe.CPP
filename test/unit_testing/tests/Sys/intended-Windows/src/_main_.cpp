#include <memory>
#include "Main.h"
#include "Sys.h"

int main(int argc, const char* argv[]) {
	Sys_Args::setupArgs(argc, argv);
	Sys_CpuTime::setupStart();
	Main::main();
	return 0;
}
