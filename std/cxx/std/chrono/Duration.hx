package cxx.std.chrono;

@:cxxStd
@:nativeName("std::chrono::duration")
@:valueType
extern class Duration {
	public function count(): Int;

	public static function zero(): Duration;
	public static function min(): Duration;
	public static function max(): Duration;

	@:nativeFunctionCode("std::chrono::duration_cast<std::chrono::seconds>({this})")
	public function toSeconds(): Duration;

	@:nativeFunctionCode("std::chrono::duration_cast<std::chrono::milliseconds>({this})")
	public function toMilliseconds(): Duration;
}
