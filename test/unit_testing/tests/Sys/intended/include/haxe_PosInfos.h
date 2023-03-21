#pragma once

#include <deque>
#include <optional>
#include <string>
#include "_AnonStructs.h"

namespace haxe {

// { className: String, fileName: String, lineNumber: Int, methodName: String, customParams: Null<Array<String>> }
struct PosInfos {

	// default constructor
	PosInfos() {}
	
	// auto-construct from any object's fields
	template<typename T>
	PosInfos(T o):
		className(o.className), fileName(o.fileName), lineNumber(o.lineNumber), methodName(o.methodName), customParams(extract_customParams(o))
	{}
	
	// construct fields directly
	static PosInfos make(std::string className, std::string fileName, int lineNumber, std::string methodName, std::optional<std::deque<std::string>> customParams = std::nullopt) {
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
	std::optional<std::deque<std::string>> customParams;

	GEN_EXTRACTOR_FUNC(customParams)
};

}
