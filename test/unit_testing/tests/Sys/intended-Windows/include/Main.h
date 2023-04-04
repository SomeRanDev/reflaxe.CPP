#pragma once

#include <memory>
#include <optional>
#include "haxe_PosInfos.h"

class Main {
public:
	int a;
	
	static int returnCode;

	Main();
	
	static void assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos = std::nullopt);
	
	static void main();
	
	// ----------
	// Auto-generated additions from Haxe
	
	// Generate unique id for each instance
	unsigned long _order_id = 0;
	static unsigned long generate_order_id() { static unsigned long i = 0; return i++; }
	
	// Automatic comparison operators
	bool operator==(const Main& other) const {
		return _order_id == other._order_id;
	}
	
	bool operator<(const Main& other) const {
		return _order_id < other._order_id;
	}
};

