#pragma once

#include <memory>
#include <optional>
#include <ostream>
#include "_HaxeUtils.h"
#include "haxe_io_Output.h"

namespace cxx::io {

class NativeOutput: public haxe::io::Output {
public:
	std::optional<std::ostream*> stream;

	NativeOutput(std::ostream* stream);
	
	void writeByte(int c);
	
	void close();
	
	void flush();
	
	void prepare(int nbytes);
	
	HX_COMPARISON_OPERATORS(NativeOutput)
};

}


#include "dynamic/Dynamic_cxx_io_NativeOutput.h"


// Reflection info
#include "_TypeUtils.h"
namespace haxe {
	template<> struct _class<cxx::io::NativeOutput> {
		DEFINE_CLASS_TOSTRING
		using Dyn = haxe::Dynamic_cxx_io_NativeOutput;
		constexpr static _class_data<5, 0> data {"NativeOutput", { "stream", "writeByte", "close", "flush", "prepare" }, {}, true};
	};
}
