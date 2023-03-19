#pragma once

#include <array>
#include <memory>
#include <optional>
#include <string>

// ---------------------------------------------------------------------
// haxe::_class<T>
//
// A class used to access reflection information regarding Haxe types.
// ---------------------------------------------------------------------

namespace haxe {

template<typename T>
struct _class;

template<std::size_t sf_size, std::size_t if_size, typename Super = void>
struct _class_data {
	using super_class = _class<Super>;
	constexpr static bool has_super_class = std::is_same<Super, void>::value;

	const char* name = "<unknown>";
	const std::array<const char*, sf_size> static_fields;
	const std::array<const char*, if_size> instance_fields;
};

#define DEFINE_CLASS_TOSTRING\
	std::string toString() {\
		return std::string("Class<") + data.name + ">";\
	}

template<typename T> struct _class {
	constexpr static _class_data<0, 0> data {"unknown type", {}, {}};
};

}

// ---------------------------------------------------------------------
// haxe::_unwrap_class
//
// Unwraps Class<T> to T.
// ---------------------------------------------------------------------

namespace haxe {

template<typename T>
struct _unwrap_class {
	using inner = T;
	constexpr static bool iscls = false;
};

template<typename T>
struct _unwrap_class<_class<T>> {
	using inner = typename _unwrap_class<T>::inner;
	constexpr static bool iscls = true;
};

}

// ---------------------------------------------------------------------
// haxe::_unwrap_mm
//
// Unwraps all the "memory management" types to get the underlying
// value type. Requires the type to be known at compile-time.
// ---------------------------------------------------------------------

namespace haxe {

template<typename T>
struct _unwrap_mm { using inner = T; };

template<typename T>
struct _unwrap_mm<T*> { using inner = typename _unwrap_mm<T>::inner; };

template<typename T>
struct _unwrap_mm<T&> { using inner = typename _unwrap_mm<T>::inner; };

template<typename T>
struct _unwrap_mm<std::shared_ptr<T>> { using inner = typename _unwrap_mm<T>::inner; };

template<typename T>
struct _unwrap_mm<std::unique_ptr<T>> { using inner = typename _unwrap_mm<T>::inner; };

}

