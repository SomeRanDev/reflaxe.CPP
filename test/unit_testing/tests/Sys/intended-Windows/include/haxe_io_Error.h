#pragma once

#include <algorithm>
#include <deque>
#include <dynamic/Dynamic.h>
#include <functional>
#include <memory>
#include <optional>
#include <string>
#include <variant>
#include "_AnonUtils.h"
#include "_TypeUtils.h"
#include "cxx_DynamicToString.h"
#include "haxe_iterators_ArrayIterator.h"
#include "haxe_iterators_ArrayKeyValueIterator.h"

namespace haxe::io {

class Error {
public:
	int index;

	struct dCustomImpl {
		haxe::Dynamic e;
	};

	std::variant<dCustomImpl> data;

	Error() {
		index = -1;
	}

	static std::shared_ptr<haxe::io::Error> Blocked() {
		Error result;
		result.index = 0;
		return std::make_shared<haxe::io::Error>(result);
	}

	static std::shared_ptr<haxe::io::Error> Overflow() {
		Error result;
		result.index = 1;
		return std::make_shared<haxe::io::Error>(result);
	}

	static std::shared_ptr<haxe::io::Error> OutsideBounds() {
		Error result;
		result.index = 2;
		return std::make_shared<haxe::io::Error>(result);
	}

	static std::shared_ptr<haxe::io::Error> Custom(haxe::Dynamic _e) {
		Error result;
		result.index = 3;
		result.data = dCustomImpl{ _e };
		return std::make_shared<haxe::io::Error>(result);
	}

	dCustomImpl getCustom() {
		return std::get<0>(data);
	}

	std::string toString() {
		switch(index) {
			case 0: {
				return std::string("Blocked");
			}
			case 1: {
				return std::string("Overflow");
			}
			case 2: {
				return std::string("OutsideBounds");
			}
			case 3: {
				auto temp = getCustom();
				return std::string("Custom") + "(" + haxe::DynamicToString(temp.e) + ")";
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
