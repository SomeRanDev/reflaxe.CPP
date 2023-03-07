#pragma once

#include <deque>
#include <optional>
#include <string>
#include "_AnonStructs.h"

namespace haxe {

struct PosInfos {	
	PosInfos(std::string className, std::string fileName, int lineNumber, std::string methodName, std::optional<std::deque<std::string>> customParams = std::nullopt):
		className(className), fileName(fileName), lineNumber(lineNumber), methodName(methodName), customParams(customParams)
	{}
	
	template<typename T>
	PosInfos(T o):
		className(o.className), fileName(o.fileName), lineNumber(o.lineNumber), methodName(o.methodName), customParams(extract_customParams(o))
	{}

	std::string className;
	std::string fileName;
	int lineNumber;
	std::string methodName;
	std::optional<std::deque<std::string>> customParams;

	GEN_EXTRACTOR_FUNC(customParams)
};

}
