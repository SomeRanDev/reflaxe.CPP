#pragma once

#include <memory>
#include <string>
#include <variant>
#include "_AnonUtils.h"
#include "cxx_DynamicToString.h"
#include "EnumLoop2.h"

class EnumLoop1 {
public:
	int index;

	struct dThingImpl {
		std::shared_ptr<EnumLoop2> obj;
	};

	std::variant<dThingImpl> data;

	EnumLoop1() {
		index = -1;
	}

	static std::shared_ptr<EnumLoop1> None() {
		EnumLoop1 result;
		result.index = 0;
		return std::make_shared<EnumLoop1>(result);
	}

	static std::shared_ptr<EnumLoop1> Thing(std::shared_ptr<EnumLoop2> _obj) {
		EnumLoop1 result;
		result.index = 1;
		result.data = dThingImpl{ _obj };
		return std::make_shared<EnumLoop1>(result);
	}

	dThingImpl getThing() {
		return std::get<0>(data);
	}

	std::string toString() {
		switch(index) {
			case 0: {
				return std::string("None");
			}
			case 1: {
				auto temp = getThing();
				return std::string("Thing") + "(" + haxe::DynamicToString(temp.obj) + ")";
			}
		}
		return "";
	}
};
