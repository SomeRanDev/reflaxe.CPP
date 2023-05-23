#pragma once

#include "Dynamic.h"
namespace haxe {

template<typename T> class Dynamic_haxe_iterators_ArrayIterator;

template<typename T>
class Dynamic_haxe_iterators_ArrayIterator<haxe::iterators::ArrayIterator<T>> {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		if(name == "hasNext") {
			return Dynamic::makeFunc<haxe::iterators::ArrayIterator<T>>(d, [](haxe::iterators::ArrayIterator<T>* o, std::deque<Dynamic> args) {
				return makeDynamic(o->hasNext());
			});
		} else if(name == "next") {
			return Dynamic::makeFunc<haxe::iterators::ArrayIterator<T>>(d, [](haxe::iterators::ArrayIterator<T>* o, std::deque<Dynamic> args) {
				return makeDynamic(o->next());
			});
		}
		// call const version if none found here
		return getProp(static_cast<Dynamic const&>(d), name);
	}

	static Dynamic getProp(Dynamic const& d, std::string name) {
		if(name == "array") {
			return Dynamic::unwrap<haxe::iterators::ArrayIterator<T>>(d, [](haxe::iterators::ArrayIterator<T>* o) {
				return makeDynamic(o->array);
			});
		} else if(name == "current") {
			return Dynamic::unwrap<haxe::iterators::ArrayIterator<T>>(d, [](haxe::iterators::ArrayIterator<T>* o) {
				return makeDynamic(o->current);
			});
		} else if(name == "==") {
			return Dynamic::makeFunc<haxe::iterators::ArrayIterator<T>>(d, [](haxe::iterators::ArrayIterator<T>* o, std::deque<Dynamic> args) {
				return makeDynamic((*o) == (args[0].asType<haxe::iterators::ArrayIterator<T>>()));
			});
		}
		return Dynamic();
	}

	static Dynamic setProp(Dynamic& d, std::string name, Dynamic value) {
		if(name == "current") {
			return Dynamic::unwrap<haxe::iterators::ArrayIterator<T>>(d, [value](haxe::iterators::ArrayIterator<T>* o) {
				o->current = value.asType<int>();
				return value;
			});
		}
		return Dynamic();
	}
};

}