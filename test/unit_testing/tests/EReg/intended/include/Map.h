#pragma once

#include <memory>
#include "haxe_Constraints.h"

template<typename K, typename V>
using Map = std::shared_ptr<haxe::IMap<K, V>>;

