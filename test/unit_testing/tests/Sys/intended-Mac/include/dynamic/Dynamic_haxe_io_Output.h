#pragma once

#include "Dynamic.h"
namespace haxe {

class Dynamic_haxe_io_Output {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		if(name == "writeByte") {
			return Dynamic::makeFunc<haxe::io::Output>(d, [](haxe::io::Output* o, std::deque<Dynamic> args) {
				o->writeByte(args[0].asType<int>());
				return Dynamic();
			});
		} else if(name == "writeBytes") {
			return Dynamic::makeFunc<haxe::io::Output>(d, [](haxe::io::Output* o, std::deque<Dynamic> args) {
				return makeDynamic(o->writeBytes(args[0].asType<std::shared_ptr<haxe::io::Bytes>>(), args[1].asType<int>(), args[2].asType<int>()));
			});
		} else if(name == "flush") {
			return Dynamic::makeFunc<haxe::io::Output>(d, [](haxe::io::Output* o, std::deque<Dynamic> args) {
				o->flush();
				return Dynamic();
			});
		} else if(name == "writeFullBytes") {
			return Dynamic::makeFunc<haxe::io::Output>(d, [](haxe::io::Output* o, std::deque<Dynamic> args) {
				o->writeFullBytes(args[0].asType<std::shared_ptr<haxe::io::Bytes>>(), args[1].asType<int>(), args[2].asType<int>());
				return Dynamic();
			});
		} else if(name == "writeString") {
			return Dynamic::makeFunc<haxe::io::Output>(d, [](haxe::io::Output* o, std::deque<Dynamic> args) {
				o->writeString(args[0].asType<std::string>(), args[1].asType<std::optional<std::shared_ptr<haxe::io::Encoding>>>());
				return Dynamic();
			});
		}
		// call const version if none found here
		return getProp(static_cast<Dynamic const&>(d), name);
	}

	static Dynamic getProp(Dynamic const&, std::string) {
		return Dynamic();
	}

	static Dynamic setProp(Dynamic&, std::string, Dynamic) {
		return Dynamic();
	}
};

}