#include "Main.h"

#include <chrono>
#include <cmath>
#include <cstdlib>
#include <deque>
#include <filesystem>
#include <iostream>
#include <memory>
#include <string>
#include <thread>
#include "_AnonStructs.h"
#include "haxe_Constraints.h"
#include "haxe_Log.h"
#include "Sys.h"

using namespace std::string_literals;

int Main::returnCode = 0;

Main::Main(): _order_id(generate_order_id()) {
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
		tempRight = floor((((float)rand()) / RAND_MAX) * 10);
	};
	
	std::string val = "test-value="s + std::to_string(tempRight);
	std::optional<std::string> tempLeft;
	
	{
		char* result = std::getenv(key.c_str());
		if(result == nullptr) {
			tempLeft = std::nullopt;
		} else {
			tempLeft = std::string(result);
		};
	};
	
	Main::assert(!tempLeft.has_value(), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 22, "main"s));
	
	{
		std::string tempRight1;
		{
			std::optional<std::string> tmp = val;
			if(tmp.has_value()) {
				tempRight1 = tmp.value();
			} else {
				tempRight1 = ""s;
			};
		};
		std::string inputAssign = key + "="s + tempRight1;
		putenv(inputAssign.data());
	};
	
	std::optional<std::string> tempLeft1;
	
	{
		char* result = std::getenv("Haxe2UC++ Test Value"s.c_str());
		if(result == nullptr) {
			tempLeft1 = std::nullopt;
		} else {
			tempLeft1 = std::string(result);
		};
	};
	
	Main::assert(tempLeft1 == val, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 24, "main"s));
	
	{
		std::string tempRight2;
		{
			std::optional<std::string> tmp = ""s;
			if(tmp.has_value()) {
				tempRight2 = tmp.value();
			} else {
				tempRight2 = ""s;
			};
		};
		std::string inputAssign = key + "="s + tempRight2;
		putenv(inputAssign.data());
	};
	
	std::optional<std::string> tempLeft2;
	
	{
		char* result = std::getenv(key.c_str());
		if(result == nullptr) {
			tempLeft2 = std::nullopt;
		} else {
			tempLeft2 = std::string(result);
		};
	};
	
	Main::assert(!tempLeft2.has_value(), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 26, "main"s));
	
	{
		std::string tempRight3;
		{
			std::optional<std::string> tmp = "123"s;
			if(tmp.has_value()) {
				tempRight3 = tmp.value();
			} else {
				tempRight3 = ""s;
			};
		};
		std::string inputAssign = key + "env_map"s + "="s + tempRight3;
		putenv(inputAssign.data());
	};
	
	std::shared_ptr<haxe::IMap<std::string, std::string>> this1 = Sys_Environment::environment();
	std::optional<std::string> tempLeft3 = this1->get(key + "env_map"s);
	
	Main::assert(tempLeft3 == "123"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 30, "main"s));
	
	std::shared_ptr<std::deque<std::string>> args = Sys_Args::args();
	
	Main::assert(args->size() == 1, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 33, "main"s));
	Main::assert((*args)[0].find("test_out"s) >= 0, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 34, "main"s));
	haxe::Log::trace(std::filesystem::current_path().string(), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 38, "main"s));
	std::filesystem::current_path("C:/"s);
	Main::assert(std::filesystem::current_path().string() == "C:\\"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 42, "main"s));
	haxe::Log::trace(std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count() / 1000.0, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 46, "main"s));
	
	double beforeSleep = Sys_CpuTime::cpuTime();
	
	std::this_thread::sleep_for(std::chrono::milliseconds(((int)(1.3 * 1000.0))));
	
	double sleepTime = Sys_CpuTime::cpuTime() - beforeSleep;
	
	Main::assert(sleepTime > 1.1 && sleepTime < 1.4, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 61, "main"s));
	haxe::Log::trace("sleepTime = "s + std::to_string(sleepTime), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Sys/Main.hx"s, 62, "main"s));
	
	if(Main::returnCode != 0) {
		exit(Main::returnCode);
	};
}
