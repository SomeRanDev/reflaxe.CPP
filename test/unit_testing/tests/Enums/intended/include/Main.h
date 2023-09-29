#pragma once

#include "_AnonUtils.h"
#include "cxx_DynamicToString.h"
#include "haxe_PosInfos.h"
#include "memory"
#include <memory>
#include <optional>
#include <string>
#include <variant>

class MyEnum {
public:
	int index;

	struct dEntry2Impl {
		int i;
	};

	struct dEntry3Impl {
		std::string s;
	};

	std::variant<dEntry2Impl, dEntry3Impl> data;

	MyEnum() {
		index = -1;
	}

	static std::shared_ptr<MyEnum> Entry1() {
		MyEnum result;
		result.index = 0;
		return std::make_shared<MyEnum>(result);
	}

	static std::shared_ptr<MyEnum> Entry2(int _i) {
		MyEnum result;
		result.index = 1;
		result.data = dEntry2Impl{ _i };
		return std::make_shared<MyEnum>(result);
	}

	static std::shared_ptr<MyEnum> Entry3(std::string _s) {
		MyEnum result;
		result.index = 2;
		result.data = dEntry3Impl{ _s };
		return std::make_shared<MyEnum>(result);
	}

	dEntry2Impl getEntry2() {
		return std::get<0>(data);
	}

	dEntry3Impl getEntry3() {
		return std::get<1>(data);
	}

	std::string toString() {
		switch(index) {
			case 0: {
				return std::string("Entry1");
			}
			case 1: {
				auto temp = getEntry2();
				return std::string("Entry2") + "(" + haxe::DynamicToString(temp.i) + ")";
			}
			case 2: {
				auto temp = getEntry3();
				return std::string("Entry3") + "(" + haxe::DynamicToString(temp.s) + ")";
			}
			default: return "";
		}
		return "";
	}

	operator bool() const {
		return true;
	}
};


class Main {
public:
	static int returnCode;

	static void assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos = std::nullopt);
	static void main();
};

