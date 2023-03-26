#pragma once

#include "_AnonUtils.h"

#include <optional>

namespace haxe {

// { len: Int, pos: Int }
struct AnonStruct0 {

	// default constructor
	AnonStruct0() {}
	
	// auto-construct from any object's fields
	template<typename T>
	AnonStruct0(T o):
		len(haxe::unwrap(o).len),
		pos(haxe::unwrap(o).pos)
	{}
	
	// construct fields directly
	static AnonStruct0 make(int len, int pos) {
		AnonStruct0 result;
		result.len = len;
		result.pos = pos;
		return result;
	}

	// fields
	int len;
	int pos;
};

}