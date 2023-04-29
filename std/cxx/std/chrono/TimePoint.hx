package cxx.std.chrono;

@:cxxStd
@:nativeTypeCode("std::chrono::time_point<{type0}>")
@:include("chrono", true)
@:valueType
extern class TimePoint<T> {
	@:nativeName("time_since_epoch")
	public function timeSinceEpoch(): Duration;
}
