#pragma once

#include <memory>
#include <string>
#include <variant>
#include "_AnonUtils.h"
#include "cxx_DynamicToString.h"



class EnumLoop1;

class EnumLoop2 {
public:
	int index;

	struct dThingImpl {
		std::shared_ptr<EnumLoop1> obj;
	};

	std::variant<dThingImpl> data;

	EnumLoop2() {
		index = -1;
	}

	static std::shared_ptr<EnumLoop2> None() {
		EnumLoop2 result;
		result.index = 0;
		return std::make_shared<EnumLoop2>(result);
	}

	static std::shared_ptr<EnumLoop2> Thing(std::shared_ptr<EnumLoop1> _obj) {
		EnumLoop2 result;
		result.index = 1;
		result.data = dThingImpl{ _obj };
		return std::make_shared<EnumLoop2>(result);
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
