package ucpp;

@:headerCode("namespace haxe {

template <typename T, typename = std::string>
struct HasToString : std::false_type { };

template <typename T>
struct HasToString <T, decltype(std::declval<T>().toString())> : std::true_type { };

struct DynamicToString: public std::string {
    template<typename T>
    DynamicToString(T s): std::string(ToString(s)) {}

    template<typename T>
    static std::string ToString(T s) {
        if constexpr(haxe::optional_info<T>::isopt) {
			if(s.has_value()) {
				return ToString(s.value());
			} else {
				return \"null\";
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
		
		return \"<unknown(size:\" + std::to_string(sizeof(s)) + \")>\";
    }
};

}")
@:headerInclude("type_traits", true)
@:headerInclude("utility", true)
@:headerInclude("string", true)
@:includeAnonUtils(true)
@:native("haxe::DynamicToString")
extern abstract DynamicToString(String) from Dynamic to String {
}
