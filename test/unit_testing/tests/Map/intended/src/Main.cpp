#include "Main.h"

#include <cstdlib>
#include <iostream>
#include <memory>
#include <string>
#include "_AnonStructs.h"
#include "haxe_Constraints.h"
#include "haxe_ds_IntMap.h"
#include "Map.h"
#include "StdTypes.h"

using namespace std::string_literals;

int Main::returnCode = 0;

void Main::assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(!b) {
		{
			auto temp = infos.value_or(haxe::shared_anon<haxe::PosInfos>("", "test/unit_testing/tests/Map/Main.hx"s, 10, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed"s << std::endl;
		};
		Main::returnCode = 1;
	};
}

void Main::main() {
	std::shared_ptr<haxe::ds::IntMap<int>> tempMap;
	
	{
		std::shared_ptr<haxe::ds::IntMap<int>> _g = std::make_shared<haxe::ds::IntMap<int>>();
		_g->set(1, 123);
		tempMap = _g;
	};
	
	std::shared_ptr<haxe::ds::IntMap<int>> intMap = tempMap;
	std::shared_ptr<haxe::ds::IntMap<int>> intMap2 = intMap->copyOG();
	
	intMap->set(2, 222);
	Main::assert(intMap->get(1) == 123, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Map/Main.hx"s, 22, "main"s));
	Main::assert(intMap->get(2) == 222, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Map/Main.hx"s, 23, "main"s));
	Main::assert(intMap->exists(1), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Map/Main.hx"s, 25, "main"s));
	Main::assert(intMap->exists(2), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Map/Main.hx"s, 26, "main"s));
	Main::assert(!intMap->exists(3), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Map/Main.hx"s, 27, "main"s));
	intMap->set(3, 333);
	Main::assert(intMap->exists(3), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Map/Main.hx"s, 30, "main"s));
	Main::assert(intMap->remove(3), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Map/Main.hx"s, 31, "main"s));
	Main::assert(!intMap->remove(3), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Map/Main.hx"s, 32, "main"s));
	
	int sum = 0;
	std::shared_ptr<Iterator<int>> k = intMap->keys();
	
	while(k->hasNext()) {
		int k2 = k->next();
		sum += k2;
	};
	
	Main::assert(sum == 3, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Map/Main.hx"s, 38, "main"s));
	
	std::shared_ptr<Iterator<int>> it = intMap->iterator();
	
	sum = 0;
	
	while(it->hasNext()) {
		sum += it->next();
	};
	
	Main::assert(sum == 123 + 222, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Map/Main.hx"s, 45, "main"s));
	
	int index = 0;
	
	{
		std::shared_ptr<haxe::IMap<int, int>> map = std::static_pointer_cast<haxe::IMap<int, int>>(intMap);
		std::shared_ptr<haxe::IMap<int, int>> test_map = map;
		std::shared_ptr<Iterator<int>> test_keys = map->keys();
		while(test_keys->hasNext()) {
			int test_value;
			int test_key;
			int key = test_keys->next();
			test_value = test_map->get(key).value();
			test_key = key;
			{
				int _g = index++;
				switch(_g) {
				
					case 0: {
						Main::assert(test_key == 1, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Map/Main.hx"s, 51, "main"s));
						Main::assert(test_value == 123, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Map/Main.hx"s, 52, "main"s));
						break;
					}
					case 1: {
						Main::assert(test_key == 2, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Map/Main.hx"s, 55, "main"s));
						Main::assert(test_value == 222, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Map/Main.hx"s, 56, "main"s));
						break;
					}
					default: {
						Main::assert(false, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Map/Main.hx"s, 58, "main"s));
						break;
					}
				};
			};
		};
	};
	
	Main::assert(intMap->toString() == "[1 => 123, 2 => 222]"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Map/Main.hx"s, 62, "main"s));
	Main::assert(intMap2->get(1) == 123, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Map/Main.hx"s, 64, "main"s));
	Main::assert(!intMap2->get(2).has_value(), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Map/Main.hx"s, 65, "main"s));
	intMap2->clear();
	Main::assert(intMap2->toString() == "[]"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Map/Main.hx"s, 69, "main"s));
	Main::assert(!intMap2->get(1).has_value(), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Map/Main.hx"s, 70, "main"s));
	
	std::shared_ptr<haxe::ds::IntMap<std::string>> tempMap1;
	
	{
		std::shared_ptr<haxe::ds::IntMap<std::string>> _g = std::make_shared<haxe::ds::IntMap<std::string>>();
		_g->set(1, "test"s);
		tempMap1 = _g;
	};
	
	std::shared_ptr<haxe::ds::IntMap<std::string>> _intmap = tempMap1;
	std::shared_ptr<haxe::ds::IntMap<std::string>> tempMap2;
	
	{
		std::shared_ptr<haxe::ds::IntMap<std::string>> map = _intmap->copyOG();
		tempMap2 = map;
	};
	
	std::shared_ptr<haxe::ds::IntMap<std::string>> _map = tempMap2;
	
	Main::assert(_map->get(1) == "test"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Map/Main.hx"s, 75, "main"s));
	
	std::shared_ptr<haxe::IMap<int, std::string>> _map2 = std::static_pointer_cast<haxe::IMap<int, std::string>>(_intmap->copyOG());
	
	Main::assert(_map2->get(1) == "test"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Map/Main.hx"s, 78, "main"s));
	
	if(Main::returnCode != 0) {
		exit(Main::returnCode);
	};
}
