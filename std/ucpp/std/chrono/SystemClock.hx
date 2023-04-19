package ucpp.std.chrono;

import ucpp.std.chrono.TimePoint;

@:ucppStd
@:native("std::chrono::system_clock")
@:include("chrono", true)
@:valueType
extern class SystemClock {
	@:noExcept public static function now(): TimePoint<SystemClock>;
}
