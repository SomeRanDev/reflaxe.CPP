#pragma once

#include <optional>

// haxe::optional_info
// Returns information about std::optional<T> types.
namespace haxe {

template <typename T>
struct optional_info {
	using inner = T;
	static constexpr bool isopt = false;
};

template <typename T>
struct optional_info<std::optional<T>> {
	using inner = typename optional_info<T>::inner;
	static constexpr bool isopt = true;
};

}

// GEN_EXTRACTOR_FUNC
// Generates a function named extract_[fieldName].
//
// Given any object, it checks whether that object has a field of the same name
// and type as the class this function is a member of (using `haxe::optional_info`).
//
// If it does, it returns the object's field's value; otherwise, it returns `std::nullopt`.
//
// Useful for extracting values for optional parameters for anonymous structure
// classes since the input object may or may not have the field.

#define GEN_EXTRACTOR_FUNC(fieldName)\
template<typename T, typename Other = decltype(T().fieldName), typename U = typename haxe::optional_info<Other>::inner>\
static auto extract_##fieldName(T other) {\
	if constexpr(!haxe::optional_info<decltype(fieldName)>::isopt && haxe::optional_info<Other>::isopt) {\
		return other.customParam.get();\
	} else if constexpr(std::is_same<U,haxe::optional_info<decltype(fieldName)>::inner>::value) {\
		return other.customParam;\
	} else {\
		return std::nullopt;\
	}\
}

