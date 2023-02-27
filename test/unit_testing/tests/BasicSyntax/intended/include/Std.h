#pragma once

#include <optional>
#include <string>

template <typename T, typename = std::string>
struct HasToString : std::false_type { };

template <typename T>
struct HasToString <T, decltype((void) T::toString, 0)> : std::true_type { };


class Std {
public:
	template<typename T>
	static std::string string(T s) {
		if constexpr(std::is_integral_v<T>) {
			return std::to_string(s);
		} else if constexpr(std::is_convertible<T, std::string>::value) {
			return std::string(s);
		} else if constexpr(HasToString<T>::value) {
			return s.toString();
		};
		
		return "<unknown(size:" + std::to_string(sizeof(s)) + ")>";
	}
	
	static std::optional<int> parseInt(std::string x) {
		try { return std::stoi(x); } catch(...) {};
		
		return std::nullopt;
	}
	
	static double parseFloat(std::string x) {
		try { return std::stof(x); } catch(...) {};
		
		return std::numeric_limits<double>::quiet_NaN();
	}
};

