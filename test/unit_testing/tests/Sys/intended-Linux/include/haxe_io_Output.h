#pragma once

#include <memory>
#include <optional>
#include <string>
#include "haxe_io_Bytes.h"
#include "haxe_io_Encoding.h"

namespace haxe::io {

class Output {
public:
	virtual ~Output() {}

	virtual void writeByte(int c);
	
	int writeBytes(std::shared_ptr<haxe::io::Bytes> s, int pos, int len);
	
	virtual void flush();
	
	void writeFullBytes(std::shared_ptr<haxe::io::Bytes> s, int pos, int len);
	
	void writeString(std::string s, std::optional<std::shared_ptr<haxe::io::Encoding>> encoding = std::nullopt);
};

}


#include "dynamic/Dynamic_haxe_io_Output.h"


// Reflection info
#include "_TypeUtils.h"
namespace haxe {
	template<> struct _class<haxe::io::Output> {
		DEFINE_CLASS_TOSTRING
		using Dyn = haxe::Dynamic_haxe_io_Output;
		constexpr static _class_data<5, 0> data {"Output", { "writeByte", "writeBytes", "flush", "writeFullBytes", "writeString" }, {}, true};
	};
}
