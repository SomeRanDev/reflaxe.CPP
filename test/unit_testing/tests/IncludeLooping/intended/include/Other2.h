#pragma once

#include <memory>
#include <optional>
#include "_HaxeUtils.h"
#include "Main.h"

class Other2 {
public:
	Main main;

	Other2(std::optional<std::shared_ptr<Main>> main2 = std::nullopt);

	HX_COMPARISON_OPERATORS(Other2)
};

