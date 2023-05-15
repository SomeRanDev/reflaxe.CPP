#pragma once

#include "Dynamic.h"
namespace haxe {

class Dynamic_haxe_io_Bytes {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		if(name == "length") {
			return Dynamic::unwrap<haxe::io::Bytes>(d, [](haxe::io::Bytes* o) {
				return makeDynamic(o->length);
			});
		} else 		if(name == "b") {
			return Dynamic::unwrap<haxe::io::Bytes>(d, [](haxe::io::Bytes* o) {
				return makeDynamic(o->b);
			});
		} else 		if(name == "ofString") {
			return Dynamic::makeFunc<haxe::io::Bytes>(d, [](haxe::io::Bytes* o, std::deque<Dynamic> args) {
				return makeDynamic(o->ofString(args[0].asType<std::string>(), args[1].asType<std::optional<std::shared_ptr<haxe::io::Encoding>>>()));
			});
		}
		throw "Property does not exist";
	}

	static Dynamic setProp(Dynamic& d, std::string name, Dynamic value) {
		if(name == "length") {
			return Dynamic::unwrap<haxe::io::Bytes>(d, [value](haxe::io::Bytes* o) {
				o->length = value.asType<int>();
				return value;
			});
		} else 		if(name == "b") {
			return Dynamic::unwrap<haxe::io::Bytes>(d, [value](haxe::io::Bytes* o) {
				o->b = value.asType<std::shared_ptr<haxe::io::BytesData>>();
				return value;
			});
		}
		throw "Property does not exist";
	}
};

}