#include "Main.h"

#include <cstdlib>
#include <iostream>
#include <memory>
#include <string>
#include "_AnonStructs.h"
#include "HxString.h"
#include "StringTools.h"

using namespace std::string_literals;

int Main::returnCode = 0;

void Main::assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(!b) {
		{
			auto temp = infos.value_or(haxe::shared_anon<haxe::PosInfos>("", "test/unit_testing/tests/String/Main.hx"s, 10, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed"s << std::endl;
		};
		Main::returnCode = 1;
	};
}

void Main::main() {
	std::string str = "Test"s;
	
	Main::assert(str == "Test"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 17, "main"s));
	Main::assert(static_cast<int>(str.size()) == 4, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 18, "main"s));
	Main::assert(str == "Test"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 19, "main"s));
	Main::assert(std::string(1, 65) == "A"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 21, "main"s));
	Main::assert(std::string(1, 70) == "F"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 22, "main"s));
	Main::assert(str[1] == 101, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 24, "main"s));
	Main::assert(str.find("es"s) == 1, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 26, "main"s));
	Main::assert(str.find("Hey"s) == -1, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 27, "main"s));
	Main::assert(str.find("Te"s, 2) == -1, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 28, "main"s));
	Main::assert(str.rfind("Te"s) == 0, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 30, "main"s));
	Main::assert((*HxString::split(str, "s"s))[0] == "Te"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 32, "main"s));
	Main::assert(HxString::split(str, "e"s)->size() == 2, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 33, "main"s));
	Main::assert((*HxString::split("Hello"s, ""s)) == (*std::make_shared<std::deque<std::string>>(std::deque<std::string>{ "H"s, "e"s, "l"s, "l"s, "o"s })), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 34, "main"s));
	Main::assert((*HxString::split(""s, ""s)) == (*std::make_shared<std::deque<std::string>>(std::deque<std::string>{})), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 35, "main"s));
	Main::assert((*HxString::split("Hello BLAworld BLA how areBLAyou?"s, "BLA"s)) == (*std::make_shared<std::deque<std::string>>(std::deque<std::string>{
		"Hello "s,
		"world "s,
		" how are"s,
		"you?"s
	})), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 36, "main"s));
	
	std::string str2 = "Hello, World!"s;
	
	Main::assert(str2.substr(7, 5) == "World"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 39, "main"s));
	
	std::string tempLeft;
	
	if(12 < 0) {
		tempLeft = str2.substr(7);
	} else {
		tempLeft = str2.substr(7, 12 - 7);
	};
	
	Main::assert(tempLeft == "World"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 40, "main"s));
	Main::assert(HxString::toLowerCase(str2) == "hello, world!"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 42, "main"s));
	Main::assert(HxString::toUpperCase(str2) == "HELLO, WORLD!"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 43, "main"s));
	
	std::string toolsStr = "Hello world!"s;
	
	Main::assert(toolsStr.find("world"s) != -1, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 48, "main"s));
	Main::assert(StringTools::endsWith(toolsStr, "world!"s), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 49, "main"s));
	
	int tempLeft1;
	
	if(0 < 0 || 0 >= static_cast<int>(toolsStr.size())) {
		tempLeft1 = -1;
	} else {
		tempLeft1 = toolsStr.at(0);
	};
	
	Main::assert(tempLeft1 == 72, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 51, "main"s));
	
	int tempLeft2;
	
	if(99 < 0 || 99 >= static_cast<int>(toolsStr.size())) {
		tempLeft2 = -1;
	} else {
		tempLeft2 = toolsStr.at(99);
	};
	
	Main::assert(tempLeft2 == -1, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 52, "main"s));
	Main::assert(StringTools::hex(0, std::nullopt) == "0"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 54, "main"s));
	Main::assert(StringTools::hex(12, std::nullopt) == "C"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 55, "main"s));
	Main::assert(StringTools::hex(-24, std::nullopt) == "FFFFFFE8"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 56, "main"s));
	Main::assert(StringTools::hex(12, 4) == "000C"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 57, "main"s));
	Main::assert(StringTools::hex(100, 4) == "0064"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 58, "main"s));
	
	std::string html = "<button onclick=\"doThing()\">My Button ✨</button>"s;
	
	Main::assert(StringTools::htmlEscape(html, std::nullopt) == "&lt;button onclick=\"doThing()\"&gt;My Button ✨&lt;/button&gt;"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 61, "main"s));
	Main::assert(StringTools::htmlEscape(html, true) == "&lt;button onclick=&quot;doThing()&quot;&gt;My Button ✨&lt;/button&gt;"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 62, "main"s));
	Main::assert(StringTools::htmlUnescape("&amp;"s) == "&"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 64, "main"s));
	Main::assert(StringTools::htmlUnescape(StringTools::htmlEscape(html, std::nullopt)) == html, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 65, "main"s));
	Main::assert(StringTools::startsWith(toolsStr, "Hello"s), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 67, "main"s));
	Main::assert(0 == 0, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 69, "main"s));
	Main::assert(!(65 == 0), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 70, "main"s));
	Main::assert(StringTools::isSpace(" "s, 0), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 72, "main"s));
	Main::assert(StringTools::isSpace("\t"s, 0), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 73, "main"s));
	Main::assert(StringTools::isSpace("\n"s, 0), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 74, "main"s));
	Main::assert(StringTools::isSpace("\r"s, 0), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 75, "main"s));
	Main::assert(StringTools::isSpace("Hello world!"s, 5), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 76, "main"s));
	
	{
		int it_offset = 0;
		std::string it_s = "Hello"s;
		std::string result = ""s;
		while(it_offset < static_cast<int>(it_s.size())) {
			int tempRight;
			
			{
				std::string s = it_s;
				int index = it_offset++;
				if(index < 0 || index >= static_cast<int>(s.size())) {
					tempRight = -1;
				} else {
					tempRight = s.at(index);
				};
			};
			
			result += tempRight;
		};
		Main::assert(result == "Hello"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 84, "main"s));
	};
	{
		int it_offset = 0;
		std::string it_s = "Hello"s;
		int count = 0;
		std::string result = ""s;
		while(it_offset < static_cast<int>(it_s.size())) {
			int n_value;
			int n_key;
			
			n_key = it_offset;
			
			int tempRight1;
			
			{
				std::string s = it_s;
				int index = it_offset++;
				if(index < 0 || index >= static_cast<int>(s.size())) {
					tempRight1 = -1;
				} else {
					tempRight1 = s.at(index);
				};
			};
			
			n_value = tempRight1;
			count += n_key;
			result += n_value;
		};
		Main::assert(count == 10, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 96, "main"s));
		Main::assert(result == "Hello"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 97, "main"s));
	};
	
	Main::assert(StringTools::lpad("Hello"s, "-"s, 10) == "-----Hello"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 100, "main"s));
	Main::assert(StringTools::lpad("Hello"s, "-="s, 10) == "-=-=-=Hello"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 101, "main"s));
	Main::assert(StringTools::lpad("Hello"s, ""s, 100) == "Hello"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 102, "main"s));
	Main::assert(StringTools::lpad("Hello"s, "123456789"s, 1) == "Hello"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 103, "main"s));
	Main::assert(StringTools::rpad("Hello"s, "-"s, 10) == "Hello-----"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 105, "main"s));
	Main::assert(StringTools::rpad("Hello"s, "-="s, 10) == "Hello-=-=-="s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 106, "main"s));
	Main::assert(StringTools::rpad("Hello"s, ""s, 100) == "Hello"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 107, "main"s));
	Main::assert(StringTools::rpad("Hello"s, "123456789"s, 1) == "Hello"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 108, "main"s));
	Main::assert(StringTools::ltrim("    Hello"s) == "Hello"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 110, "main"s));
	Main::assert(StringTools::ltrim("Hello"s) == "Hello"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 111, "main"s));
	Main::assert(StringTools::rtrim("Hello        "s) == "Hello"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 112, "main"s));
	Main::assert(StringTools::rtrim("Hello"s) == "Hello"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 113, "main"s));
	Main::assert(StringTools::replace("Hello world!"s, "Hello"s, "Goodbye"s) == "Goodbye world!"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 115, "main"s));
	Main::assert(StringTools::replace("Hello world!"s, "Greetings"s, "Goodbye"s) == "Hello world!"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 116, "main"s));
	Main::assert(true, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 124, "main"s));
	Main::assert(true, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 125, "main"s));
	
	if(Main::returnCode != 0) {
		exit(Main::returnCode);
	};
}
