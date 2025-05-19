#pragma once

#include <memory>
#include <optional>
#include <string>
#include "_HaxeUtils.h"
#include "haxe_io_BytesData.h"
#include "haxe_io_Encoding.h"

namespace haxe::io {

class Bytes {
public:
	std::shared_ptr<haxe::io::BytesData> b;
	int length;

	Bytes(int length2, std::shared_ptr<haxe::io::BytesData> b2);
	static std::shared_ptr<haxe::io::Bytes> ofString(std::string s, std::optional<std::shared_ptr<haxe::io::Encoding>> encoding = std::nullopt);

	HX_COMPARISON_OPERATORS(Bytes)
};

}


#include "dynamic/Dynamic_haxe_io_Bytes.h"


// Reflection info
#include "_TypeUtils.h"
namespace haxe {
	template<> struct _class<haxe::io::Bytes> {
		DEFINE_CLASS_TOSTRING
		using Dyn = haxe::Dynamic_haxe_io_Bytes;
		constexpr static _class_data<2, 1> data {"Bytes", { "length", "b" }, { "ofString" }, true};
	};
}
