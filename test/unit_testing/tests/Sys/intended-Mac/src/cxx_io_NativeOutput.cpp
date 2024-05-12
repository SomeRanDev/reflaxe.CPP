#include "cxx_io_NativeOutput.h"

#include <memory>
#include <ostream>

cxx::io::NativeOutput::NativeOutput(std::ostream* stream):
	_order_id(generate_order_id())
{
	this->stream = stream;
}

void cxx::io::NativeOutput::writeByte(int c) {
	if(this->stream.has_value()) {
		this->stream.value_or(nullptr)->put((char)(c));
	};
}

void cxx::io::NativeOutput::close() {
	this->stream = std::nullopt;
}

void cxx::io::NativeOutput::flush() {
	if(this->stream.has_value()) {
		this->stream.value_or(nullptr)->flush();
	};
}

void cxx::io::NativeOutput::prepare(int nbytes) {

}
