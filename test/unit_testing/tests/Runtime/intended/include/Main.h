#pragma once

#include <memory>
#include <optional>
#include <string>
#include "_AnonUtils.h"
#include "haxe_Constraints.h"
#include "haxe_ds_StringMap.h"

namespace _Main {

class Main_Fields_ {
public:
	static void main();
	
	static std::shared_ptr<haxe::ds::StringMap<std::string>> bla();
};

}
