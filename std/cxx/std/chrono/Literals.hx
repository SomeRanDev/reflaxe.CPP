package cxx.std.chrono;

@:cxxStd
extern class Literals {
	@:include("chrono", true)
	@:nativeFunctionCode("std::chrono::milliseconds({arg0})")
	public static overload function toMilliseconds(num: Int): cxx.std.chrono.Duration;

	@:include("chrono", true)
	@:nativeFunctionCode("std::chrono::milliseconds({arg0})")
	public static overload function toMilliseconds(num: Float): cxx.std.chrono.Duration;

	@:include("chrono", true)
	@:nativeFunctionCode("std::chrono::seconds({arg0})")
	public static overload function toSeconds(num: Int): cxx.std.chrono.Duration;

	@:include("chrono", true)
	@:nativeFunctionCode("std::chrono::seconds({arg0})")
	public static overload function toSeconds(num: Float): cxx.std.chrono.Duration;

	@:include("chrono", true)
	@:nativeFunctionCode("std::chrono::minutes({arg0})")
	public static overload function toMinutes(num: Int): cxx.std.chrono.Duration;

	@:include("chrono", true)
	@:nativeFunctionCode("std::chrono::minutes({arg0})")
	public static overload function toMinutes(num: Float): cxx.std.chrono.Duration;
}
