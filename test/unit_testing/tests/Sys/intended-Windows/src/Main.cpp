#include "Main.h"

#include <array>
#include <chrono>
#include <cmath>
#include <cstdlib>
#include <deque>
#include <filesystem>
#include <iostream>
#include <memory>
#include <stdlib.h>
#include <string>
#include <thread>
#include <windows.h>
#include "_AnonStructs.h"
#include "cxx_DynamicToString.h"
#include "cxx_io_NativeOutput.h"
#include "haxe_Constraints.h"
#include "haxe_Log.h"
#include "Std.h"
#include "Sys.h"

using namespace std::string_literals;

int Main::returnCode = 0;

Main::Main():
	_order_id(generate_order_id())
{
	this->a = 123;
}

void Main::assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(!b) {
		{
			auto temp = infos.value_or(haxe::shared_anon<haxe::PosInfos>("", "test/unit_testing/tests/Sys/Main.hx"s, 11, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed"s << std::endl;
		};
		Main::returnCode = 1;
	};
}

void Main::main() {
	std::string key = "Haxe2UC++ Test Value"s;
	int tempRight;
	
	if(10 <= 1) {
		tempRight = 0;
	} else {
		tempRight = static_cast<int>(floor((((float)rand()) / RAND_MAX) * 10));
	};
	
	std::string val = "test-value="s + std::to_string(tempRight);
	
	Main::assert(!Sys_GetEnv::getEnv(key).has_value(), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 22, "main"s));
	
	std::string tempString;
	
	{
		std::optional<std::string> tmp = val;
		
		if(tmp.has_value()) {
			tempString = tmp.value();
		} else {
			tempString = ""s;
		};
	};
	
	_putenv_s(key.c_str(), tempString.c_str());
	Main::assert(Sys_GetEnv::getEnv("Haxe2UC++ Test Value"s) == val, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 24, "main"s));
	
	std::string tempString1;
	
	{
		std::optional<std::string> tmp = ""s;
		
		if(tmp.has_value()) {
			tempString1 = tmp.value();
		} else {
			tempString1 = ""s;
		};
	};
	
	_putenv_s(key.c_str(), tempString1.c_str());
	Main::assert(!Sys_GetEnv::getEnv(key).has_value(), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 26, "main"s));
	
	std::string tempString2;
	
	{
		std::optional<std::string> tmp = "123"s;
		
		if(tmp.has_value()) {
			tempString2 = tmp.value();
		} else {
			tempString2 = ""s;
		};
	};
	
	_putenv_s((key + "env_map"s).c_str(), tempString2.c_str());
	
	std::shared_ptr<haxe::IMap<std::string, std::string>> this1 = Sys_Environment::environment();
	std::optional<std::string> tempLeft = this1->get(key + "env_map"s);
	
	Main::assert(tempLeft == "123"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 30, "main"s));
	
	std::shared_ptr<std::deque<std::string>> args = Sys_Args::args();
	
	Main::assert((int)(args->size()) == 1, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 33, "main"s));
	Main::assert((int)((*args)[0].find("test_out"s)) >= 0, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 34, "main"s));
	haxe::Log::trace(std::filesystem::current_path().string(), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 38, "main"s));
	std::filesystem::current_path("C:/"s);
	Main::assert(std::filesystem::current_path().string() == "C:\\"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 42, "main"s));
	haxe::Log::trace(std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count() / 1000.0, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 46, "main"s));
	
	double beforeSleep = Sys_CpuTime::cpuTime();
	
	std::this_thread::sleep_for(std::chrono::milliseconds(((int)(1.3 * 1000.0))));
	
	double sleepTime = Sys_CpuTime::cpuTime() - beforeSleep;
	
	Main::assert((sleepTime > 1.1) && (sleepTime < 1.4), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 61, "main"s));
	haxe::Log::trace("sleepTime = "s + std::to_string(sleepTime), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 62, "main"s));
	cxx::io::NativeOutput(&std::cout).writeString("Written to stdout.\n"s, std::nullopt);
	cxx::io::NativeOutput(&std::cout).flush();
	cxx::io::NativeOutput(&std::cerr).writeString("Error output.\n"s, std::nullopt);
	cxx::io::NativeOutput(&std::cerr).flush();
	
	std::array<char, 256> path = std::array<char, 256>();
	
	GetModuleFileName(nullptr, path.data(), path.size());
	
	std::string tempString3 = std::string((((const char*)(path.data()))));
	haxe::DynamicToString v = tempString3;
	
	std::cout << Std::string(v) << std::endl;
	
	if(Main::returnCode != 0) {
		exit(Main::returnCode);
	};
}
