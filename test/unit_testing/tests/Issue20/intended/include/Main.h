#pragma once

#include <optional>

namespace _Main {

class Main_Fields_ {
public:
	static void main();
};

}


namespace _Main {

class Flexible_Impl_ {
public:
	static int _new();
	template<typename T>
	static T toAny(int this1) {
		return nullptr;
	}
};

}
