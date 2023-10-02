#pragma once

#include <deque>
#include <memory>
#include <optional>
#include <string>
#include "_AnonStructs.h"
#include "_AnonUtils.h"
#include "cxx_DynamicToString.h"

namespace haxe {

// { className: String, fileName: String, lineNumber: Int, methodName: String, customParams: Null<Array<cxx.DynamicToString>> }
struct PosInfos {

	// default constructor
	PosInfos() {}

	// auto-construct from any object's fields
	template<typename T>
	PosInfos(T o):
		className(haxe::unwrap(o).className),
		fileName(haxe::unwrap(o).fileName),
		lineNumber(haxe::unwrap(o).lineNumber),
		methodName(haxe::unwrap(o).methodName),
		customParams(extract_customParams(haxe::unwrap(o)))
	{}

	// construct fields directly
	static PosInfos make(std::string className, std::string fileName, int lineNumber, std::string methodName, std::optional<std::shared_ptr<std::deque<haxe::DynamicToString>>> customParams = std::nullopt) {
		PosInfos result;
		result.className = className;
		result.fileName = fileName;
		result.lineNumber = lineNumber;
		result.methodName = methodName;
		result.customParams = customParams;
		return result;
	}

	// fields
	std::string className;
	std::string fileName;
	int lineNumber;
	std::string methodName;
	std::optional<std::shared_ptr<std::deque<haxe::DynamicToString>>> customParams;

	GEN_EXTRACTOR_FUNC(customParams)
};

}