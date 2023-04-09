package ucpp.std.chrono;

extern class Literals {
	@:include("chrono", true)
	@:nativeFunctionCode("std::chrono::milliseconds({arg0})")
	public static overload function toMilliseconds(num: Int): ucpp.std.chrono.Duration;

	@:include("chrono", true)
	@:nativeFunctionCode("std::chrono::milliseconds({arg0})")
	public static overload function toMilliseconds(num: Float): ucpp.std.chrono.Duration;

	@:include("chrono", true)
	@:nativeFunctionCode("std::chrono::seconds({arg0})")
	public static overload function toSeconds(num: Int): ucpp.std.chrono.Duration;

	@:include("chrono", true)
	@:nativeFunctionCode("std::chrono::seconds({arg0})")
	public static overload function toSeconds(num: Float): ucpp.std.chrono.Duration;

	@:include("chrono", true)
	@:nativeFunctionCode("std::chrono::minutes({arg0})")
	public static overload function toMinutes(num: Int): ucpp.std.chrono.Duration;

	@:include("chrono", true)
	@:nativeFunctionCode("std::chrono::minutes({arg0})")
	public static overload function toMinutes(num: Float): ucpp.std.chrono.Duration;
}
