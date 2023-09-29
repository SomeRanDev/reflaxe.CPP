#include "Main.h"

#include <array>
#include <chrono>
#include <cmath>
#include <cstddef>
#include <cstdlib>
#include <deque>
#include <filesystem>
#include <iostream>
#include <libgen.h>
#include <memory>
#include <stdlib.h>
#include <string>
#include <thread>
#include <unistd.h>
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
	int tempRight = 0;

	if(10 <= 1) {
		tempRight = 0;
	} else {
		tempRight = static_cast<int>(floor((((float)rand()) / RAND_MAX) * 10));
	};

	std::string val = "test-value="s + std::to_string(tempRight);

	Main::assert(!Sys_GetEnv::getEnv(key).has_value(), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 22, "main"s));

	if(false || ((int)(val.size()) == 0)) {
		unsetenv(key.c_str());
	} else {
		setenv(key.c_str(), val.c_str(), 1);
	};

	Main::assert(Sys_GetEnv::getEnv("Haxe2UC++ Test Value"s) == val, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 24, "main"s));

	if(false || ((int)(""s.size()) == 0)) {
		unsetenv(key.c_str());
	} else {
		setenv(key.c_str(), ""s.c_str(), 1);
	};

	Main::assert(!Sys_GetEnv::getEnv(key).has_value(), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 26, "main"s));

	std::string s = key + "env_map"s;

	if(false || ((int)("123"s.size()) == 0)) {
		unsetenv(s.c_str());
	} else {
		setenv(s.c_str(), "123"s.c_str(), 1);
	};

	std::shared_ptr<haxe::IMap<std::string, std::string>> this1 = Sys_Environment::environment();
	std::optional<std::string> tempLeft = this1->get(key + "env_map"s);

	Main::assert(tempLeft == "123"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 30, "main"s));

	std::shared_ptr<std::deque<std::string>> args = Sys_Args::args();

	Main::assert((int)(args->size()) == 1, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 33, "main"s));
	Main::assert((int)((*args)[0].find("test_out"s)) >= 0, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 34, "main"s));
	haxe::Log::trace(std::filesystem::current_path().string(), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 38, "main"s));
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

	std::string tempString;


	std::array<char, 256> path = std::array<char, 256>();
	std::size_t count = readlink("/proc/self/exe", path.data(), path.size());

	if((int)(count) != -1) {
		const char* tempConstCharPtr;

		{
			char* p = path.data();

			tempConstCharPtr = p;
		};

		tempString = std::string(tempConstCharPtr);
	} else {
		tempString = ""s;
	};

	haxe::DynamicToString v = tempString;

	std::cout << Std::string(v) << std::endl;

	if(Main::returnCode != 0) {
		exit(Main::returnCode);
	};
}
