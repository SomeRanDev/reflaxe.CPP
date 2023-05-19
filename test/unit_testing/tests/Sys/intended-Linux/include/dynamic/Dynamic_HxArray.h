#pragma once

#include "Dynamic.h"
namespace haxe {

template<typename T> class Dynamic_std_deque;

template<typename T>
class Dynamic_std_deque<std::deque<T>> {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		if(name == "length") {
			return Dynamic::unwrap<std::deque<T>>(d, [](std::deque<T>* o) {
				return makeDynamic(o->size());
			});
		} else if(name == "push") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				
				return makeDynamic(o->push_back(args[0].asType<T>()));
			});
		} else if(name == "unshift") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				
				o->push_front(args[0].asType<T>());
				return Dynamic();
			});
		} else if(name == "cppInsert") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				
				o->insert(args[0].asType<int>(), args[1].asType<T>());
				return Dynamic();
			});
		} else if(name == "resize") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				
				o->resize(args[0].asType<int>());
				return Dynamic();
			});
		} else if(name == "lastIndexOf") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				
				return makeDynamic(o->lastIndexOf(args[0].asType<T>(), args[1].asType<std::optional<int>>()));
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
					std::sort(o->begin(), o->end(), [&](T a, T b) mutable {
						return f(a, b) < 0;
					});
				};
				result();
				return Dynamic();
			});
		} else if(name == "remove") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
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
				};
				return makeDynamic(result());
			});
		} else if(name == "contains") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					
					return (std::find(o->begin(), o->end(), x) != o->end());
				};
				return makeDynamic(result());
			});
		} else if(name == "copy") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					std::shared_ptr<std::deque<T>> result = std::make_shared<std::deque<T>>(std::deque<T>{});
					
					{
						int _g = 0;
						std::shared_ptr<std::deque<T>> _g1 = o;
						
						while(_g < (int)(_g1->size())) {
							T obj = (*_g1)[_g];
							
							++_g;
							result->push_back(obj);
						};
					};
					
					return result;
				};
				return makeDynamic(result());
			});
		} else if(name == "iterator") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					return std::make_shared<haxe::iterators::ArrayIterator<T>>(o);
				};
				return makeDynamic(result());
			});
		} else if(name == "keyValueIterator") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					return std::make_shared<haxe::iterators::ArrayKeyValueIterator<T>>(o);
				};
				return makeDynamic(result());
			});
		} else if(name == "concat") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					return HxArray::concat<T>(o, a);
				};
				return makeDynamic(result());
			});
		} else if(name == "join") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					return HxArray::join<T>(o, sep);
				};
				return makeDynamic(result());
			});
		} else if(name == "slice") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					return HxArray::slice<T>(o, pos, end);
				};
				return makeDynamic(result());
			});
		} else if(name == "splice") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					return HxArray::splice<T>(o, pos, len);
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
					HxArray::insert<T>(o, pos, x);
				};
				result();
				return Dynamic();
			});
		} else if(name == "indexOf") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					return HxArray::indexOf<T>(o, x, fromIndex);
				};
				return makeDynamic(result());
			});
		} else if(name == "map") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					return HxArray::map<T, S>(o, f);
				};
				return makeDynamic(result());
			});
		} else if(name == "filter") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					return HxArray::filter<T>(o, f);
				};
				return makeDynamic(result());
			});
		}
		return Dynamic();
	}

	static Dynamic setProp(Dynamic&, std::string, Dynamic) {
		
		return Dynamic();
	}
};

}
namespace haxe {

template<typename T> class Dynamic_std_deque;

template<typename T>
class Dynamic_std_deque<std::deque<T>> {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		if(name == "length") {
			return Dynamic::unwrap<std::deque<T>>(d, [](std::deque<T>* o) {
				return makeDynamic(o->size());
			});
		} else if(name == "push") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				
				return makeDynamic(o->push_back(args[0].asType<T>()));
			});
		} else if(name == "unshift") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				
				o->push_front(args[0].asType<T>());
				return Dynamic();
			});
		} else if(name == "cppInsert") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				
				o->insert(args[0].asType<int>(), args[1].asType<T>());
				return Dynamic();
			});
		} else if(name == "resize") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				
				o->resize(args[0].asType<int>());
				return Dynamic();
			});
		} else if(name == "lastIndexOf") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				
				return makeDynamic(o->lastIndexOf(args[0].asType<T>(), args[1].asType<std::optional<int>>()));
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
					std::sort(o->begin(), o->end(), [&](T a, T b) mutable {
						return f(a, b) < 0;
					});
				};
				result();
				return Dynamic();
			});
		} else if(name == "remove") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
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
				};
				return makeDynamic(result());
			});
		} else if(name == "contains") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					
					return (std::find(o->begin(), o->end(), x) != o->end());
				};
				return makeDynamic(result());
			});
		} else if(name == "copy") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					std::shared_ptr<std::deque<T>> result = std::make_shared<std::deque<T>>(std::deque<T>{});
					
					{
						int _g = 0;
						std::shared_ptr<std::deque<T>> _g1 = o;
						
						while(_g < (int)(_g1->size())) {
							T obj = (*_g1)[_g];
							
							++_g;
							result->push_back(obj);
						};
					};
					
					return result;
				};
				return makeDynamic(result());
			});
		} else if(name == "iterator") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					return std::make_shared<haxe::iterators::ArrayIterator<T>>(o);
				};
				return makeDynamic(result());
			});
		} else if(name == "keyValueIterator") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					return std::make_shared<haxe::iterators::ArrayKeyValueIterator<T>>(o);
				};
				return makeDynamic(result());
			});
		} else if(name == "concat") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					return HxArray::concat<T>(o, a);
				};
				return makeDynamic(result());
			});
		} else if(name == "join") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					return HxArray::join<T>(o, sep);
				};
				return makeDynamic(result());
			});
		} else if(name == "slice") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					return HxArray::slice<T>(o, pos, end);
				};
				return makeDynamic(result());
			});
		} else if(name == "splice") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					return HxArray::splice<T>(o, pos, len);
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
					HxArray::insert<T>(o, pos, x);
				};
				result();
				return Dynamic();
			});
		} else if(name == "indexOf") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					return HxArray::indexOf<T>(o, x, fromIndex);
				};
				return makeDynamic(result());
			});
		} else if(name == "map") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					return HxArray::map<T, S>(o, f);
				};
				return makeDynamic(result());
			});
		} else if(name == "filter") {
			return Dynamic::makeFunc<std::deque<T>>(d, [](std::deque<T>* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					return HxArray::filter<T>(o, f);
				};
				return makeDynamic(result());
			});
		}
		return Dynamic();
	}

	static Dynamic setProp(Dynamic&, std::string, Dynamic) {
		
		return Dynamic();
	}
};

}