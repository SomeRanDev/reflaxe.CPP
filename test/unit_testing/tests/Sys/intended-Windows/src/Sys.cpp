#include "Sys.h"

#include "haxe_ds_StringMap.h"
#include "Map.h"
#include <chrono>
#include <cstddef>
#include <deque>
#include <memory>
#include <stdlib.h>
#include <string>
using namespace std::string_literals;

std::optional<std::string> Sys_GetEnv::getEnv(std::string s) {
	std::size_t requiredSize = 0;
	
	getenv_s(&requiredSize, nullptr, 0, s.c_str());
	
	if(requiredSize == 0) {
		return std::nullopt;
	};
	
	char* libvar = ((char*)(malloc(requiredSize * sizeof(char))));
	
	getenv_s(&requiredSize, libvar, requiredSize, s.c_str());
	
	std::string str = std::string(libvar);
	
	free(libvar);
	
	return str;
}
std::shared_ptr<haxe::ds::StringMap<std::string>> Sys_Environment::environment() {
	std::shared_ptr<std::deque<std::string>> strings = std::make_shared<std::deque<std::string>>(std::deque<std::string>{});
	
	char** env;
	#if defined(WIN) && (_MSC_VER >= 1900)
		env = *__p__environ();
	#else
		extern char** environ;
		env = environ;
	#endif
		for (; *env; ++env) {
			strings->push_back(*env);
		};
	
	std::shared_ptr<haxe::ds::StringMap<std::string>> result = std::make_shared<haxe::ds::StringMap<std::string>>();
	int _g = 0;
	
	while(_g < (int)(strings->size())) {
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
std::deque<std::string> Sys_Args::_args = (*std::make_shared<std::deque<std::string>>(std::deque<std::string>{}));

void Sys_Args::setupArgs(int argCount, const char** args) {
	int _g = 0;
	int _g1 = argCount;
	
	while(_g < _g1) {
		int i = _g++;
		
		Sys_Args::_args.push_back(std::string(args[i]));
	};
}

std::shared_ptr<std::deque<std::string>> Sys_Args::args() {
	return std::make_shared<std::deque<std::string>>(Sys_Args::_args);
}
std::chrono::time_point<std::chrono::system_clock> Sys_CpuTime::_startTime;

void Sys_CpuTime::setupStart() {
	Sys_CpuTime::_startTime = std::chrono::system_clock::now();
}

double Sys_CpuTime::cpuTime() {
	return std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count() / 1000.0 - std::chrono::duration_cast<std::chrono::milliseconds>(Sys_CpuTime::_startTime.time_since_epoch()).count() / 1000.0;
}
