#pragma once

#include <functional>
#include <iostream>
#include <memory>
#include <optional>
#include <string>
#include "haxe_PosInfos.h"
#include "ucpp_DynamicToString.h"

namespace haxe {

class Log {
public:
	static std::function<void(haxe::DynamicToString, std::optional<std::shared_ptr<haxe::PosInfos>>)> trace;

	static std::string formatOutput(std::string v, std::optional<std::shared_ptr<haxe::PosInfos>> infos = std::nullopt);
	
	// ----------
	// Auto-generated additions from Haxe
	
	// Generate unique id for each instance
	unsigned long _order_id = 0;
	static unsigned long generate_order_id() { static unsigned long i = 0; return i++; }
	
	// Automatic comparison operators
	bool operator==(const Log& other) const {
		return _order_id == other._order_id;
	}
	
	bool operator<(const Log& other) const {
		return _order_id < other._order_id;
	}
};

}
