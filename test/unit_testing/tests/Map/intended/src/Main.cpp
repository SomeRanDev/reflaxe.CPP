#include "Main.h"

#include <iostream>
#include <map>
#include <memory>
#include <string>
#include <utility>
#include "_AnonStructs.h"
#include "haxe_Constraints.h"
#include "haxe_ds_IntMap.h"
#include "haxe_Log.h"

using namespace std::string_literals;

int Main::returnCode = 0;

void Main::assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(!b) {
		{
			auto temp = infos.value_or(haxe::shared_anon<haxe::PosInfos>("", "test/unit_testing/tests/Map/Main.hx"s, 11, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed"s << std::endl;
		};
		Main::returnCode = 1;
	};
}

void Main::main() {
	std::shared_ptr<haxe::ds::IntMap<int>> _g = std::make_shared<haxe::ds::IntMap<int>>();
	
	_g->set(1, 123);
	
	std::shared_ptr<haxe::ds::IntMap<int>> tempMap = _g;
	std::shared_ptr<haxe::ds::IntMap<int>> bla = tempMap;
	
	haxe::Log::trace(bla->get(1), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Map/Main.hx"s, 18, "main"s));
	
	std::map<int, int> a = std::map<int, int>();
	
	a.insert(std::pair<int, int>(12, 24));
	haxe::Log::trace(a.at(12), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Map/Main.hx"s, 24, "main"s));
	
	auto it = a.begin();
	
	haxe::Log::trace(it->first, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Map/Main.hx"s, 28, "main"s));
	(it++);
	haxe::Log::trace(it == a.end(), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Map/Main.hx"s, 32, "main"s));
	
	if(Main::returnCode != 0) {
		exit(Main::returnCode);
	};
}
