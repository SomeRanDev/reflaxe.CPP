#pragma once

#include "_AnonUtils.h"
#include "cxx_DynamicToString.h"
#include "StringBuf.h"
#include <deque>
#include <memory>
#include <optional>
#include <string>
#include <variant>

namespace haxe {

class StackItem {
public:
	int index;

	struct dModuleImpl {
		std::string m;
	};

	struct dFilePosImpl {
		std::optional<std::shared_ptr<haxe::StackItem>> s;
		std::string file;
		int line;
		std::optional<int> column;
	};

	struct dMethodImpl {
		std::optional<std::string> classname;
		std::string method;
	};

	struct dLocalFunctionImpl {
		std::optional<int> v;
	};

	std::variant<dModuleImpl, dFilePosImpl, dMethodImpl, dLocalFunctionImpl> data;

	StackItem() {
		index = -1;
	}

	static std::shared_ptr<haxe::StackItem> CFunction() {
		StackItem result;
		result.index = 0;
		return std::make_shared<haxe::StackItem>(result);
	}

	static std::shared_ptr<haxe::StackItem> Module(std::string _m) {
		StackItem result;
		result.index = 1;
		result.data = dModuleImpl{ _m };
		return std::make_shared<haxe::StackItem>(result);
	}

	static std::shared_ptr<haxe::StackItem> FilePos(std::optional<std::shared_ptr<haxe::StackItem>> _s, std::string _file, int _line, std::optional<int> _column = std::nullopt) {
		StackItem result;
		result.index = 2;
		result.data = dFilePosImpl{ _s, _file, _line, _column };
		return std::make_shared<haxe::StackItem>(result);
	}

	static std::shared_ptr<haxe::StackItem> Method(std::optional<std::string> _classname, std::string _method) {
		StackItem result;
		result.index = 3;
		result.data = dMethodImpl{ _classname, _method };
		return std::make_shared<haxe::StackItem>(result);
	}

	static std::shared_ptr<haxe::StackItem> LocalFunction(std::optional<int> _v = std::nullopt) {
		StackItem result;
		result.index = 4;
		result.data = dLocalFunctionImpl{ _v };
		return std::make_shared<haxe::StackItem>(result);
	}

	dModuleImpl getModule() {
		return std::get<0>(data);
	}

	dFilePosImpl getFilePos() {
		return std::get<1>(data);
	}

	dMethodImpl getMethod() {
		return std::get<2>(data);
	}

	dLocalFunctionImpl getLocalFunction() {
		return std::get<3>(data);
	}

	std::string toString() {
		switch(index) {
			case 0: {
				return std::string("CFunction");
			}
			case 1: {
				auto temp = getModule();
				return std::string("Module") + "(" + haxe::DynamicToString(temp.m) + ")";
			}
			case 2: {
				auto temp = getFilePos();
				return std::string("FilePos") + "(" + haxe::DynamicToString(temp.s) + ", " + haxe::DynamicToString(temp.file) + ", " + haxe::DynamicToString(temp.line) + ", " + haxe::DynamicToString(temp.column) + ")";
			}
			case 3: {
				auto temp = getMethod();
				return std::string("Method") + "(" + haxe::DynamicToString(temp.classname) + ", " + haxe::DynamicToString(temp.method) + ")";
			}
			case 4: {
				auto temp = getLocalFunction();
				return std::string("LocalFunction") + "(" + haxe::DynamicToString(temp.v) + ")";
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


namespace haxe::_CallStack {

class CallStack_Impl_ {
public:
	static std::string toString(std::shared_ptr<std::deque<std::shared_ptr<haxe::StackItem>>> stack);
	static void itemToString(std::shared_ptr<StringBuf> b, std::shared_ptr<haxe::StackItem> s);
};

}
