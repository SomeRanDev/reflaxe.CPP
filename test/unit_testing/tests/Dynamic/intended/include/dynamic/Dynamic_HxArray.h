#pragma once

#include "Dynamic.h"
#include <algorithm>
#include <dynamic/Dynamic.h>
#include <functional>
#include <memory>
#include <optional>
#include <string>
#include "_TypeUtils.h"
#include "haxe_iterators_ArrayIterator.h"
#include "haxe_iterators_ArrayKeyValueIterator.h"

namespace haxe {

template<typename T> class Dynamic_std_deque;

template<typename T>
class Dynamic_std_deque<std::deque<T>> {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		if(name == "unshift") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				o->push_front(args[0].asType<T>());
				return Dynamic();
			});
		} else if(name == "resize") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				o->resize(args[0].asType<int>());
				return Dynamic();
			});
		} else if(name == "push") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					auto x = args[0].asType<T>();
					{
						o->push_back(x);
						
						return o->size();
					}
				};
				return makeDynamic(result());
			});
		} else if(name == "pop") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					std::optional<T> result = o->back();
					
					o->pop_back();
					
					return result;
				};
				return makeDynamic(result());
			});
		} else if(name == "reverse") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					std::reverse(o->begin(), o->end());
				};
				result();
				return Dynamic();
			});
		} else if(name == "shift") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					std::optional<T> result = o->front();
					
					o->pop_front();
					
					return result;
				};
				return makeDynamic(result());
			});
		} else if(name == "sort") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					auto f = args[0].asType<std::function<int(T, T)>>();
					{
						std::sort(o->begin(), o->end(), [&](T a, T b) mutable {
							return f(a, b) < 0;
						});
					}
				};
				result();
				return Dynamic();
			});
		} else if(name == "remove") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					auto x = args[0].asType<T>();
					{
						int tempNumber;
						
						{
							int fromIndex = 0;
							
							tempNumber = HxArray::indexOf<T>(o, x, fromIndex);
						};
						
						int index = tempNumber;
						
						if(index < 0) {
							return false;
						};
						
						o->erase(o->begin() + index);
						
						return true;
					}
				};
				return makeDynamic(result());
			});
		} else if(name == "contains") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					auto x = args[0].asType<T>();
					{
						
						return (std::find(o->begin(), o->end(), x) != o->end());
					}
				};
				return makeDynamic(result());
			});
		} else if(name == "copy") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					std::shared_ptr<std::deque<T>> result = std::make_shared<std::deque<T>>(std::deque<T>{});
					
					{
						int _g = 0;
						std::deque<T>* _g1 = o;
						
						while(_g < (int)(_g1->size())) {
							T obj = (*_g1)[_g];
							
							++_g;
							
							{
								result->push_back(obj);
							};
						};
					};
					
					return result;
				};
				return makeDynamic(result());
			});
		} else if(name == "iterator") {
			return Dynamic::makeFuncShared<std::deque<T>>(d, [](std::shared_ptr<std::deque<T>> o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					return std::make_shared<haxe::iterators::ArrayIterator<T>>(o);
				};
				return makeDynamic(result());
			});
		} else if(name == "concat") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					auto a = args[0].asType<std::shared_ptr<std::deque<T>>>();
					{
						return HxArray::concat<T>(o, a.get());
					}
				};
				return makeDynamic(result());
			});
		} else if(name == "join") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					auto sep = args[0].asType<std::string>();
					{
						return HxArray::join<T>(o, sep);
					}
				};
				return makeDynamic(result());
			});
		} else if(name == "slice") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					auto pos = args[0].asType<int>();
					auto end = args[1].asType<std::optional<int>>();
					{
						return HxArray::slice<T>(o, pos, end);
					}
				};
				return makeDynamic(result());
			});
		} else if(name == "splice") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					auto pos = args[0].asType<int>();
					auto len = args[1].asType<int>();
					{
						return HxArray::splice<T>(o, pos, len);
					}
				};
				return makeDynamic(result());
			});
		} else if(name == "toString") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					return HxArray::toString<T>(o);
				};
				return makeDynamic(result());
			});
		} else if(name == "insert") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					auto pos = args[0].asType<int>();
					auto x = args[1].asType<T>();
					{
						HxArray::insert<T>(o, pos, x);
					}
				};
				result();
				return Dynamic();
			});
		} else if(name == "indexOf") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					auto x = args[0].asType<T>();
					auto fromIndex = args[1].asType<int>();
					{
						return HxArray::indexOf<T>(o, x, fromIndex);
					}
				};
				return makeDynamic(result());
			});
		} else if(name == "lastIndexOf") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					auto x = args[0].asType<T>();
					auto fromIndex = args[1].asType<int>();
					{
						return HxArray::lastIndexOf<T>(o, x, fromIndex);
					}
				};
				return makeDynamic(result());
			});
		} else if(name == "map") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					auto f = args[0].asType<std::function<haxe::Dynamic(T)>>();
					{
						return HxArray::map<T, haxe::Dynamic>(o, f);
					}
				};
				return makeDynamic(result());
			});
		} else if(name == "filter") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					auto f = args[0].asType<std::function<bool(T)>>();
					{
						return HxArray::filter<T>(o, f);
					}
				};
				return makeDynamic(result());
			});
		}
		// call const version if none found here
		return getProp(static_cast<Dynamic const&>(d), name);
	}

	static Dynamic getProp(Dynamic const& d, std::string name) {
		if(name == "length") {
			return Dynamic::unwrap<std::deque<T>>(d, [](std::deque<T>* o) {
				return makeDynamic(o->size());
			});
		} else if(name == "[]") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				return makeDynamic(o->operator[](args[0].asType<long>()));
			});
		} else if(name == "==") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				return makeDynamic((*o) == (args[0].asType<std::deque<T>>()));
			});
		}
		return Dynamic();
	}

	static Dynamic setProp(Dynamic& d, std::string name, Dynamic value) {
		if(name == "[]") {
			return Dynamic::makeFunc<std::deque<T>>(d, [value](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = args[0].asType<T>();
				o->operator[](value.asType<long>()) = result;
				return makeDynamic(result);
			});
		}
		return Dynamic();
	}
};

}