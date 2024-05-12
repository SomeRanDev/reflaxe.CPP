#pragma once

#include <deque>
#include <memory>
#include <sstream>
#include <string>
#include <type_traits>
#include <utility>
#include "_AnonUtils.h"

namespace haxe {

template<typename T, typename = std::string>
struct has_to_string : std::false_type { };

template<typename T>
struct has_to_string <T, decltype(std::declval<T>().toString())> : std::true_type { };

template<typename>
struct is_deque : std::false_type {};

template<typename T>
struct is_deque<std::deque<T>> : std::true_type {};

struct DynamicToString: public std::string {
    template<typename T>
    DynamicToString(T s): std::string(ToString(s)) {}

    template<typename T>
    static std::string ToString(T s) {
		if constexpr(std::is_pointer<T>::value) {
			if(s == nullptr) {
				return "nullptr";
			}
		}
        if constexpr(haxe::optional_info<T>::isopt) {
			if(s.has_value()) {
				return ToString(s.value());
			} else {
				return "null";
			}
		} else if constexpr(std::is_same_v<T, bool>) {
			return s ? "true" : "false";
		} else if constexpr(std::is_integral_v<T> || std::is_floating_point_v<T>) {
			return std::to_string(s);
		} else if constexpr(std::is_convertible<T, std::string>::value) {
			return std::string(s);
		} else if constexpr(has_to_string<T>::value) {
			return s.toString();
		} else if constexpr(haxe::_unwrap_mm<T>::can_deref) {
			if constexpr(std::is_trivially_copy_assignable_v<std::remove_reference_t<decltype(*std::declval<T>())>>) {
				return ToString(*s);
			}
		} else if constexpr(is_deque<T>::value) {
			std::string result = "[";
			auto len = s.size();
			for(decltype(len) i = 0; i < len; i++) {
				result += (i > 0 ? ", " : "") + ToString(s[i]);
			}
			return result + "]";
		}

		// Print address if all else fails
		std::stringstream pointer_stream;
		pointer_stream << std::addressof(s);
		return "<unknown(address:" + pointer_stream.str() + ")>";
    }
};

}
