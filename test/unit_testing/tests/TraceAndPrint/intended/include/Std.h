#pragma once

#include <limits>
#include <memory>
#include <optional>
#include <string>
#include "_AnonUtils.h"
#include "cxx_DynamicToString.h"

class Std {
public:
	static std::string string(haxe::DynamicToString s) {
		return s;
	}
	static std::optional<int> parseInt(std::string x) {
		try { return std::stoi(x); } catch(...) {};

		return std::nullopt;
	}
	static double parseFloat(std::string x) {
		try { return std::stof(x); } catch(...) {};

		return std::numeric_limits<double>::quiet_NaN();
	}
};

