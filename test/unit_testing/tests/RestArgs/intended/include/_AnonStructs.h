#pragma once

#include "_AnonUtils.h"

#include <any>
#include <optional>

namespace haxe {

// { data: Any }
struct AnonStruct0 {

	// default constructor
	AnonStruct0() {}
	
	// auto-construct from any object's fields
	template<typename T>
	AnonStruct0(T o):
		data(o.data)
	{}
	
	// construct fields directly
	static AnonStruct0 AnonStruct0::make(std::any data) {
		AnonStruct0 result;
		result.data = data;
		return result;
	}

	// fields
	std::any data;
};

}