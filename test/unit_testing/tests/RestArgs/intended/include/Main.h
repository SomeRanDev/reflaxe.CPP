#pragma once

#include <any>
#include <deque>
#include <memory>
#include <optional>
#include <string>
#include "_AnonStructs.h"
#include "haxe_PosInfos.h"
#include "haxe_Rest.h"
#include "ucpp_DynamicToString.h"

class Main {
public:
	static int returnCode;

	static void assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos = std::nullopt);
	
	static void oneTwoThree(std::shared_ptr<haxe::_Rest::NativeRest<int>> numbers);
	
	static void testRest(std::shared_ptr<haxe::_Rest::NativeRest<std::string>> strings);
	
	static void testRestAny(std::shared_ptr<haxe::_Rest::NativeRest<std::shared_ptr<haxe::AnonStruct0>>> anys);
	
	static void testRestAny2(std::shared_ptr<haxe::_Rest::NativeRest<std::shared_ptr<haxe::AnonStruct1>>> anys);
	
	static void main();
	
	// ----------
	// Auto-generated additions from Haxe
	
	// Generate unique id for each instance
	unsigned long _order_id = 0;
	static unsigned long generate_order_id() { static unsigned long i = 0; return i++; }
	
	// Automatic comparison operators
	bool operator==(const Main& other) const {
		return _order_id == other._order_id;
	}
	
	bool operator<(const Main& other) const {
		return _order_id < other._order_id;
	}
};

