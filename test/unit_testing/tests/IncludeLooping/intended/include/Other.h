#pragma once

#include <memory>
#include <optional>
#include "_HaxeUtils.h"

 class Main ;

class Other {
public:
	std::shared_ptr<Main> main;

	Other(std::optional<std::shared_ptr<Main>> main = std::nullopt);
	
	HX_COMPARISON_OPERATORS(Other)
};

