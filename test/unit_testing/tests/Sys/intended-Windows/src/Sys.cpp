#include "Sys.h"

#include <deque>
#include <memory>
#include <string>
#include "haxe_ds_StringMap.h"
#include "Map.h"

using namespace std::string_literals;

std::shared_ptr<haxe::ds::StringMap<std::string>> SysImpl::environment() {
	std::shared_ptr<std::deque<std::string>> strings = std::make_shared<std::deque<std::string>>(std::deque<std::string>{});
	
	char ** env;
	#if defined(WIN) && (_MSC_VER >= 1900)
		env = *__p__environ();
	#else
		extern char ** environ;
		env = environ;
	#endif
		for (; *env; ++env) {
			strings->push_back(*env);
		};
	
	std::shared_ptr<haxe::ds::StringMap<std::string>> result = std::make_shared<haxe::ds::StringMap<std::string>>();
	int _g = 0;
	
	while(_g < strings->size()) {
		std::string en = (*strings)[_g];
		++_g;
		int index = en.find("="s);
		if(index >= 0) {
			std::string key = en.substr(0, index);
			std::string value = en.substr(index + 1);
			result->set(key, value);
		};
	};
	
	return result;
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
