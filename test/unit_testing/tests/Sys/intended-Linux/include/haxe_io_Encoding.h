#pragma once

#include <string>
#include "memory"

namespace haxe::io {

class Encoding {
public:
	int index;

	Encoding() {
		index = -1;
	}

	static std::shared_ptr<haxe::io::Encoding> UTF8() {
		Encoding result;
		result.index = 0;
		return std::make_shared<haxe::io::Encoding>(result);
	}

	static std::shared_ptr<haxe::io::Encoding> RawNative() {
		Encoding result;
		result.index = 1;
		return std::make_shared<haxe::io::Encoding>(result);
	}

	std::string toString() {
		switch(index) {
			case 0: {
				return std::string("UTF8");
			}
			case 1: {
				return std::string("RawNative");
			}
			default: return "";
		}
		return "";
	}

	operator bool() const {
		return true;
	}
};
}
