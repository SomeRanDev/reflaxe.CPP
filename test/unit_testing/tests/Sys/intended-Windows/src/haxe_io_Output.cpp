#include "haxe_io_Output.h"

#include <memory>
#include <string>
#include "_AnonStructs.h"
#include "haxe_exceptions_NotImplementedException.h"
#include "haxe_io_Bytes.h"
#include "haxe_io_BytesData.h"
#include "haxe_io_Error.h"

using namespace std::string_literals;

void haxe::io::Output::writeByte(int c) {
	throw std::make_shared<haxe::exceptions::NotImplementedException>("Not implemented"s, std::nullopt, haxe::shared_anon<haxe::PosInfos>("haxe.io.Output"s, "haxe/io/Output.hx"s, 47, "writeByte"s));
}

int haxe::io::Output::writeBytes(std::shared_ptr<haxe::io::Bytes> s, int pos, int len) {
	if(((pos < 0) || (len < 0)) || (pos + len > s->length)) {
		throw haxe::io::Error::OutsideBounds();
	};
	
	std::shared_ptr<haxe::io::BytesData> b = s->b;
	int k = len;
	
	while(k > 0) {
		this->writeByte((*b)[pos]);
		pos++;
		k--;
	};
	
	return len;
}

void haxe::io::Output::flush() {
	
}

void haxe::io::Output::writeFullBytes(std::shared_ptr<haxe::io::Bytes> s, int pos, int len) {
	while(len > 0) {
		int k = this->writeBytes(s, pos, len);
		
		pos += k;
		len -= k;
	};
}

void haxe::io::Output::writeString(std::string s, std::optional<std::shared_ptr<haxe::io::Encoding>> encoding) {
	std::shared_ptr<haxe::io::Bytes> b = haxe::io::Bytes::ofString(s, encoding);
	
	this->writeFullBytes(b, 0, b->length);
}
