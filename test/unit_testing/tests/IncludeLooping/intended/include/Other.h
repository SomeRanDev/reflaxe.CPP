#pragma once

#include <memory>
#include <optional>
#include "_HaxeUtils.h"

class Other2;

class Other {
public:
	std::shared_ptr<Other2> main;

	Other(std::optional<std::shared_ptr<Other2>> main = std::nullopt);

	HX_COMPARISON_OPERATORS(Other)
};

