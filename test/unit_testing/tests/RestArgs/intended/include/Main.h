#pragma once

#include <any>
#include <deque>
#include <memory>
#include <optional>
#include <string>
#include "_AnonStructs.h"
#include "haxe_PosInfos.h"
#include "haxe_Rest.h"

class Main {
public:
	static int returnCode;

	static void assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos = std::nullopt);
	
	static void oneTwoThree(haxe::_Rest::NativeRest<int> numbers);
	
	static void testRest(haxe::_Rest::NativeRest<std::string> strings);
	
	static void testRestAny(haxe::_Rest::NativeRest<std::shared_ptr<haxe::AnonStruct0>> anys);
	
	static void testRestAny2(haxe::_Rest::NativeRest<std::shared_ptr<haxe::AnonStruct1>> anys);
	
	static void main();
};

