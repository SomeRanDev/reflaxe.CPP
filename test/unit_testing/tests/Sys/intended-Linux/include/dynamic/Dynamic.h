#pragma once

#include <any>
#include <deque>
#include <functional>
#include <memory>
#include <optional>
#include <string>
#include <typeindex>

namespace haxe {

[[noreturn]]
void makeError(const char* msg);

// Forward declare just in case
template<typename T> struct _class;

// The different types of Dynamic values
enum DynamicType {
	Empty, Null, Function, Value, Pointer, Reference, UniquePtr, SharedPtr
};

// ---

// A helper class for extracting certain info from types
template<typename T>
struct _mm_type { using inner = T; constexpr static DynamicType type = Value; };

template<typename T>
struct _mm_type<T*> { using inner = T; constexpr static DynamicType type = Pointer; };

template<typename T>
struct _mm_type<std::shared_ptr<T>> { using inner = T; constexpr static DynamicType type = SharedPtr; };

// Unwrap references as they're incompatible with `std::any`.
template<typename T>
struct _mm_type<T&> { using inner = typename _mm_type<T>::inner; constexpr static DynamicType type = _mm_type<T>::type; };

// Due to their nature, `unique_ptr` cannot be stored in `Dynamic`.
// But let's track anyway for error reporting.
template<typename T>
struct _mm_type<std::unique_ptr<T>> { using inner = T; constexpr static DynamicType type = UniquePtr; };

// ---

// Use within the Dynamic to extract a pointer type
// from a Dynamic into a local variable `p`.
#define DYN_GETPTR(name, t) \
	std::optional<t> v;\
	if(name._dynType == Value) v = std::any_cast<t>(name._anyObj);\
	else v = std::nullopt;\
	t* p = nullptr;\
	if(name._dynType == Value) {\
		p = v.operator->();\
	} else {\
		p = name.asType<t*>();\
	}

// ---

// The class used for Haxe's `Dynamic` type.
class Dynamic {
public:
	DynamicType _dynType;

	long id;
	static long getId() { static long maxId = 0; return maxId++; }

	std::optional<std::type_index> _innerType;
	std::any _anyObj;

	std::function<Dynamic(std::deque<Dynamic>)> func;
	std::function<Dynamic(Dynamic&,std::string)> getFunc;
	std::function<Dynamic(Dynamic const&,std::string)> getFuncConst;
	std::function<Dynamic(Dynamic&,std::string,Dynamic)> setFunc;

	Dynamic(): id(getId()) {
		_dynType = Empty;
	}

	template<typename T>
	Dynamic(T obj): id(getId()) {
		using inner = typename _mm_type<T>::inner;

		if constexpr(std::is_same_v<inner, bool>) {
			_anyObj = static_cast<bool>(obj);
			_innerType = std::type_index(typeid(bool));
		} else if constexpr(std::is_integral_v<T>) {
			long l = static_cast<long>(obj);
			_anyObj = l;
			_innerType = std::type_index(typeid(long));
		} else if constexpr(std::is_floating_point_v<T>) {
			double d = static_cast<double>(obj);
			_anyObj = d;
			_innerType = std::type_index(typeid(double));
		} else {
			_anyObj = obj;
			_innerType = std::type_index(typeid(inner));
		}

		_dynType = _mm_type<T>::type;

		// We cannot copy or move `std::unique_ptr`s
		if(_dynType == UniquePtr) {
			makeError("Cannot assign std::unique_ptr to haxe::Dynamic");
		}

		// Supply properties if possible.
		// Otherwise, Dynamic works as a simple `std::any` wrapper.
		if constexpr(haxe::_class<inner>::data.has_dyn) {
			using Dyn = typename haxe::_class<inner>::Dyn;
			getFunc = [](Dynamic& d, std::string name) { return Dyn::getProp(d, name); };
			getFuncConst = [](Dynamic const& d, std::string name) { return Dyn::getProp(d, name); };
			setFunc = [](Dynamic& d, std::string name, Dynamic value) { return Dyn::setProp(d, name, value); };
		}
	}

	static Dynamic null() {
		Dynamic result;
		result._dynType = Null;
		return result;
	}

	bool isNull() const {
		return _dynType == Null;
	}

	bool isEmpty() const {
		return _dynType == Empty;
	}

	bool isFunction() const {
		return _dynType == Function;
	}

	template<typename T>
	bool isType() const {
		if(isEmpty()) return false;
		if(!_innerType) return false;
		return _innerType.value() == std::type_index(typeid(T));
	}

	bool isBool() const {
		return isType<bool>();
	}

	bool isInt() const {
		return isType<long>();
	}

	bool isFloat() const {
		return isType<double>();
	}

	bool isNumber() const {
		return isInt() || isFloat();
	}

	bool isString() const {
		return isType<std::string>();
	}

	template<typename T>
	T asType() const {
		using In = typename _mm_type<T>::inner;

		// as Dynamic
		if constexpr(std::is_same_v<In, Dynamic>) {
			return (*this);
		}

		// Check number types
		if constexpr(std::is_same_v<T, bool>) {
			return std::any_cast<bool>(_anyObj);
		} else if constexpr(std::is_arithmetic_v<T>) {
			if(isInt()) {
				return static_cast<T>(std::any_cast<long>(_anyObj));
			} else if(isFloat()) {
				return static_cast<T>(std::any_cast<double>(_anyObj));
			}
		}

		// Check objects
		if constexpr(_mm_type<T>::type == Value) {
			switch(_dynType) {
				case Value: return std::any_cast<T>(_anyObj);
				case Pointer: return *std::any_cast<T*>(_anyObj);

				// Cannot store references in `std::any`.
				// case Reference: return std::any_cast<T&>(_anyObj);

				case UniquePtr: return **std::any_cast<std::unique_ptr<T>>(&_anyObj);
				case SharedPtr: return *std::any_cast<std::shared_ptr<T>>(_anyObj);
				default: break;
			}
		} else if constexpr(_mm_type<T>::type == Pointer) {
			switch(_dynType) {
				// Cannot do this in "const" version of function.
				// case Value: return std::any_cast<In>(&_anyObj);

				case Pointer: return std::any_cast<In*>(_anyObj);
				case UniquePtr: return std::any_cast<std::unique_ptr<In>>(&_anyObj)->get();
				case SharedPtr: return std::any_cast<std::shared_ptr<In>>(_anyObj).get();
				default: break;
			}
		} else if constexpr(_mm_type<T>::type == Reference) {
			makeError("Cannot cast Dynamic to reference (&)");
		} else if constexpr(_mm_type<T>::type == UniquePtr) {
			makeError("Cannot cast Dynamic to std::unique_ptr");
		} else if constexpr(_mm_type<T>::type == SharedPtr) {
			if(_dynType == SharedPtr) {
				return std::any_cast<std::shared_ptr<In>>(_anyObj);
			}
		}
		
		makeError("Bad Dynamic cast");
	}

	template<typename T>
	T asType() {
		using In = typename _mm_type<T>::inner;

		// Perform conversions that can only occur outside of "const" function.
		if constexpr(_mm_type<T>::type == Pointer) {
			if(_dynType == Value) {
				return std::any_cast<In>(&_anyObj);
			}
		}

		return static_cast<Dynamic const*>(this)->asType<T>();
	}

	std::string toString() {
		return _toStringImpl<Dynamic&>(*this);
	}

	std::string toString() const {
		return _toStringImpl<Dynamic const&>(*this);
	}

	// Implementation for both "toString()" and "toString() const"
	// T should only be "Dynamic&" or "Dynamic const&"
	template<typename T>
	static std::string _toStringImpl(T self) {
		using remove_c_T = std::remove_cv_t<T>;
		constexpr bool isDyn = std::is_same_v<Dynamic&, remove_c_T> || std::is_same_v<const Dynamic&, remove_c_T>;
		static_assert(isDyn, "T must be Dynamic& or Dynamic const&");

		if(self.hasCustomProps()) {
			Dynamic toString = self.getPropSafe("toString");
			if(toString.isFunction()) {
				Dynamic result = toString();
				if(result.isString()) {
					return result.asType<std::string>();
				}
			}
		}
		switch(self._dynType) {
			case Empty: return std::string("Dynamic(Undefined)");
			case Null: return std::string("Dynamic(null)");
			case Function: return std::string("Dynamic(Function)");
			default: break;
		}
		if(self.isInt()) {
			return std::to_string(self.template asType<long>());
		} else if(self.isFloat()) {
			return std::to_string(self.template asType<double>());
		} else if(self.isBool()) {
			return self.template asType<bool>() ? std::string("true") : std::string("false");
		}
		return std::string("Dynamic");
	}

	// If "getFunc" is defined, both "getFuncConst" and "setFunc" are also guaranteed.
	bool hasCustomProps() const {
		return getFunc != nullptr;
	}

	Dynamic getPropSafe(std::string name) {
		if(hasCustomProps()) {
			return getFunc(*this, name);
		}
		return Dynamic();
	}

	Dynamic getPropSafe(std::string name) const {
		if(hasCustomProps()) {
			return getFuncConst(*this, name);
		}
		return Dynamic();
	}

	Dynamic setPropSafe(std::string name, Dynamic value) {
		if(hasCustomProps()) {
			return setFunc(*this, name, value);
		}
		return Dynamic();
	}

	Dynamic getProp(std::string name) {
		Dynamic result = getPropSafe(name);
		if(!result.isEmpty()) return result;
		makeError("Property does not exist");
	}

	Dynamic setProp(std::string name, Dynamic value) {
		Dynamic result = setPropSafe(name, value);
		if(!result.isEmpty()) return result;
		makeError("Property does not exist");
	}

	// operators

	Dynamic operator()() {
		if(_dynType == Function) {
			return func({});
		}
		makeError("Cannot call this Dynamic");
	}

	template<typename... Types>
	Dynamic operator()(Types... args) {
		std::deque<Dynamic> dynArgs = { args... };
		return operator()(dynArgs);
	}

	Dynamic operator()(std::deque<Dynamic> args) {
		if(_dynType == Function) {
			return func(args);
		}
		makeError("Cannot call this Dynamic");
	}

	bool operator==(Dynamic const& other) const {
		Dynamic equalsOp = getPropSafe("==");
		if(equalsOp.isFunction()) {
			auto result = equalsOp(other);
			if(result.isBool()) {
				return result.asType<bool>();
			}
		}

		if(isInt() && other.isInt()) {
			return asType<long>() == other.asType<long>();
		} else if(isNumber() && other.isNumber()) {
			return asType<double>() == other.asType<double>();
		}

		return id == other.id;
	}

	Dynamic operator[](int index) {
		if(getFunc != nullptr) {
			Dynamic arrayAccess = getFunc(*this, "[]");
			if(arrayAccess.isFunction()) {
				return arrayAccess(index);
			}
		}

		try {
			DYN_GETPTR((*this), std::deque<Dynamic>)
			if(p != nullptr) {
				return p->operator[](index);
			}
		} catch(...) {
		}
		return Dynamic();
	}

	// helpers

	template<typename T>
	static Dynamic unwrap(Dynamic& d, std::function<Dynamic(T*)> callback) {
		DYN_GETPTR(d, T)
		return callback(p);
	}

	template<typename T>
	static Dynamic unwrap(Dynamic const& d, std::function<Dynamic(T*)> callback) {
		DYN_GETPTR(d, T)
		return callback(p);
	}

	template<typename T>
	static Dynamic makeFunc(Dynamic const& d, std::function<Dynamic(T*, std::deque<Dynamic>)> callback) {
		Dynamic result;
		result._dynType = Function;
		result.func = [callback, d](std::deque<Dynamic> args) {
			std::optional<T> v;
			if(d._dynType == Value) v = std::any_cast<T>(d._anyObj);
			else v = std::nullopt;
			T* p = nullptr;
			if(d._dynType == Value) {
				p = v.operator->();
			} else {
				p = d.asType<T*>();
			}
			return callback(p, args);
		};
		return result;
	}

	template<typename T>
	static Dynamic makeFuncShared(Dynamic& d, std::function<Dynamic(std::shared_ptr<T>, std::deque<Dynamic>)> callback) {
		Dynamic result;
		result._dynType = Function;
		result.func = [callback, d](std::deque<Dynamic> args) {
			std::shared_ptr<T> p = nullptr;
			if(d._dynType == Value || d._dynType == Pointer) {
				p = std::make_shared<T>(d.asType<T>());
			} else if(d._dynType == SharedPtr) {
				p = std::any_cast<std::shared_ptr<T>>(d._anyObj);
			} else {
				makeError("Cannot use unique pointer for this property");
			}
			return callback(p, args);
		};
		return result;
	}

	// ---
	// Operators
	// ---

	// String + Dynamic
	Dynamic operator+(std::string second) const { return toString() + second; }
	friend Dynamic operator+(std::string first, Dynamic second) { return first + second.toString(); }

	// Number - Dynamic | Number * Dynamic | Number / Dynamic
	#define OP_FUN(arg, op) Dynamic operator op(arg num) const { return asType<arg>() op num; }\
	friend Dynamic operator op(arg first, Dynamic second) { return first op second.asType<arg>(); }

	// Number + Dynamic
	#define OP_FUN_ADD(arg) Dynamic operator+(arg num) const {\
		if(isString()) return toString() + std::to_string(num);\
		return asType<double>() + static_cast<double>(num);\
	}\
	\
	friend Dynamic operator+(arg first, Dynamic second) {\
		if(second.isString()) return std::to_string(first) + second.toString();\
		return first + static_cast<arg>(second.asType<double>());\
	}

	// Dynamic -= *= /=
	#define OP_ASSIGN_FUN(arg, op, op2) Dynamic& operator op2(arg second) {\
		(*this) = asType<double>() op static_cast<double>(second);\
		return (*this);\
	}

	// Dynamic +=
	#define OP_ASSIGN_FUN_ADD(arg) Dynamic& operator+=(arg second) {\
		if(isString()) (*this) = toString() + std::to_string(second);\
		else (*this) = asType<double>() + static_cast<double>(second);\
		return (*this);\
	}

	// Implement all operators for a type
	#define OP_NUM(arg)\
		OP_FUN_ADD(arg)\
		OP_FUN(arg, -)\
		OP_FUN(arg, *)\
		OP_FUN(arg, /)\
		OP_ASSIGN_FUN_ADD(arg)\
		OP_ASSIGN_FUN(arg, -, -=)\
		OP_ASSIGN_FUN(arg, *, *=)\
		OP_ASSIGN_FUN(arg, /, /=)

	// Implement for every number type
	OP_NUM(char)
	OP_NUM(unsigned char)
	OP_NUM(short)
	OP_NUM(unsigned short)
	OP_NUM(int)
	OP_NUM(unsigned int)
	OP_NUM(long)
	OP_NUM(unsigned long)
	OP_NUM(float)
	OP_NUM(double)

	// Clean up all macros
	#undef OP_FUN
	#undef OP_FUN_ADD
	#undef OP_ASSIGN_FUN
	#undef OP_ASSIGN_FUN_ADD
	#undef OP_NUM
};


// ---
// makeDynamic
// ---

template<typename T>
Dynamic makeDynamic(T obj) {
	return Dynamic(obj);
}

}

