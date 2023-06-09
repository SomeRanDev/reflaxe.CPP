#pragma once

#include "Dynamic.h"
namespace haxe {

class Dynamic_haxe_io_Bytes {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		// call const version if none found here
		return getProp(static_cast<Dynamic const&>(d), name);
	}

	static Dynamic getProp(Dynamic const& d, std::string name) {
		if(name == "b") {
			return Dynamic::unwrap<haxe::io::Bytes>(d, [](haxe::io::Bytes* o) {
				return makeDynamic(o->b);
			});
		} else if(name == "length") {
			return Dynamic::unwrap<haxe::io::Bytes>(d, [](haxe::io::Bytes* o) {
				return makeDynamic(o->length);
			});
		} else if(name == "==") {
			return Dynamic::makeFunc<haxe::io::Bytes>(d, [](haxe::io::Bytes* o, std::deque<Dynamic> args) {
				return makeDynamic((*o) == (args[0].asType<haxe::io::Bytes>()));
			});
		}
		return Dynamic();
	}

	static Dynamic setProp(Dynamic& d, std::string name, Dynamic value) {
		if(name == "b") {
			return Dynamic::unwrap<haxe::io::Bytes>(d, [value](haxe::io::Bytes* o) {
				o->b = value.asType<std::shared_ptr<haxe::io::BytesData>>();
				return value;
			});
		} else if(name == "length") {
			return Dynamic::unwrap<haxe::io::Bytes>(d, [value](haxe::io::Bytes* o) {
				o->length = value.asType<int>();
				return value;
			});
		}
		return Dynamic();
	}
};

}