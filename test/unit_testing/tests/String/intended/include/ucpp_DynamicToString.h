#pragma once

#include <memory>
#include <sstream>
#include <string>
#include <type_traits>
#include <utility>
#include "_AnonUtils.h"

namespace haxe {

template <typename T, typename = std::string>
struct HasToString : std::false_type { };

template <typename T>
struct HasToString <T, decltype(std::declval<T>().toString())> : std::true_type { };

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
		} else if constexpr(std::is_integral_v<T>) {
			return std::to_string(s);
		} else if constexpr(std::is_convertible<T, std::string>::value) {
			return std::string(s);
		} else if constexpr(HasToString<T>::value) {
			return s.toString();
		} else if constexpr(haxe::_unwrap_mm<T>::can_deref) {
			return ToString(*s);
		}
		
		// Print address if all else fails
		std::stringstream pointer_stream;
		pointer_stream << std::addressof(s);
		return "<unknown(address:" + pointer_stream.str() + ")>";
    }
};

}
