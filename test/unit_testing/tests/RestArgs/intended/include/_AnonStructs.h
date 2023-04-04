#pragma once

#include "_AnonUtils.h"

#include <any>
#include <optional>

namespace haxe {

// { data: Null<Int> }
struct AnonStruct1 {

	// default constructor
	AnonStruct1() {}
	
	// auto-construct from any object's fields
	template<typename T>
	AnonStruct1(T o):
		data(extract_data(haxe::unwrap(o)))
	{}
	
	// construct fields directly
	static AnonStruct1 make(std::optional<int> data = std::nullopt) {
		AnonStruct1 result;
		result.data = data;
		return result;
	}

	// fields
	std::optional<int> data;

	GEN_EXTRACTOR_FUNC(data)
};


// { data: Any }
struct AnonStruct0 {

	// default constructor
	AnonStruct0() {}
	
	// auto-construct from any object's fields
	template<typename T>
	AnonStruct0(T o):
		data(haxe::unwrap(o).data)
	{}
	
	// construct fields directly
	static AnonStruct0 make(std::any data) {
		AnonStruct0 result;
		result.data = data;
		return result;
	}

	// fields
	std::any data;
};

}