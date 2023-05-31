package cxx.std.chrono;

import cxx.std.chrono.TimePoint;

@:cxxStd
@:cppStd
@:native("std::chrono::system_clock")
@:include("chrono", true)
@:valueType
extern class SystemClock {
	@:noExcept public static function now(): TimePoint<SystemClock>;
}
