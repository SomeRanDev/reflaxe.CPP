#include "Sys.h"

#include <memory>
#include <string>
#include "haxe_ds_StringMap.h"

using namespace std::string_literals;

std::shared_ptr<Map<std::string, std::string>> SysImpl::environment() {
	return std::make_shared<haxe::ds::StringMap<std::string>>();
}

std::string SysImpl::systemName() {
	#if defined(_WIN32)
	return "Windows";
	#elif defined(BSD)
	return "BSD";
	#elif defined(__linux__)
	return "Linux";
	#elif defined(__APPLE__) && defined(__MACH__)
	return "Mac";
	#endif
	;
	
	return ""s;
}
