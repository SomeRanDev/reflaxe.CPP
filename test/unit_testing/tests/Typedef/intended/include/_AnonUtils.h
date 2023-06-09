#pragma once

#include <optional>
#include <memory>

// haxe::shared_anon | haxe::unique_anon
// Helper functions for generating "anonymous struct" smart pointers.
namespace haxe {

	template<typename Anon, class... Args>
	std::shared_ptr<Anon> shared_anon(Args... args) {
		return std::make_shared<Anon>(Anon::make(args...));
	}

	template<typename Anon, class... Args>
	std::unique_ptr<Anon> unique_anon(Args... args) {
		return std::make_unique<Anon>(Anon::make(args...));
	}

}

// ---------------------------------------------------------------------

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

// ---------------------------------------------------------------------


// haxe::_unwrap_mm
// Unwraps all the "memory management" types to get the underlying
// value type. Also provided whether or not that type is deref-able.
namespace haxe {

	template<typename T>
	struct _unwrap_mm {
		using inner = T;
		constexpr static bool can_deref = false;
		static inline inner& get(T& in) { return in; }
	};

	template<typename T>
	struct _unwrap_mm<T*> {
		using inner = typename _unwrap_mm<T>::inner;
		constexpr static bool can_deref = true;
		static inline inner& get(T* in) { return _unwrap_mm<T>::get(*in); }
	};

	template<typename T>
	struct _unwrap_mm<T&> {
		using inner = typename _unwrap_mm<T>::inner;
		constexpr static bool can_deref = false;
		static inline inner& get(T& in) { return _unwrap_mm<T>::get(in); }
	};

	template<typename T>
	struct _unwrap_mm<std::shared_ptr<T>> {
		using inner = typename _unwrap_mm<T>::inner;
		constexpr static bool can_deref = true;
		static inline inner& get(std::shared_ptr<T> in) { return _unwrap_mm<T>::get(*in); }
	};

	template<typename T>
	struct _unwrap_mm<std::unique_ptr<T>> {
		using inner = typename _unwrap_mm<T>::inner;
		constexpr static bool can_deref = true;
		static inline inner& get(std::unique_ptr<T> in) { return _unwrap_mm<T>::get(*in); }
	};

	template<typename T, typename U = typename _unwrap_mm<T>::inner>
	static inline U& unwrap(T in) { return _unwrap_mm<T>::get(in); }

}

// ---------------------------------------------------------------------

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


