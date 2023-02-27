package;

@:pseudoCoreApi
@:pure
extern class Math {
	public extern static var PI(get, never): Float;
	public extern static var POSITIVE_INFINITY(get, never): Float;
	public extern static var NEGATIVE_INFINITY(get, never): Float;
	public extern static var NaN(get, never): Float;

	@:include("math.h", true)
	@:nativeFunctionCode("3.14159265358979323846")
	static extern function get_PI(): Float;

	@:include("limits", true)
	@:nativeFunctionCode("std::numeric_limits<double>::infinity()")
	static extern function get_POSITIVE_INFINITY(): Float;

	@:include("limits", true)
	@:nativeFunctionCode("-std::numeric_limits<double>::infinity()")
	static extern function get_NEGATIVE_INFINITY(): Float;

	@:include("limits", true)
	@:nativeFunctionCode("std::numeric_limits<double>::quiet_NaN()")
	static extern function get_NaN(): Float;

	@:include("cstdlib", true)
	@:native("abs")
	public extern static function abs(v: Float): Float;

	@:include("cmath", true)
	@:native("fmin")
	public extern static function min(a: Float, b: Float): Float;

	@:include("cmath", true)
	@:native("fmax")
	public extern static function max(a: Float, b: Float): Float;

	@:include("cmath", true)
	@:native("sin")
	public extern static function sin(v: Float): Float;

	@:include("cmath", true)
	@:native("cos")
	public extern static function cos(v: Float): Float;

	@:include("cmath", true)
	@:native("tan")
	public extern static function tan(v: Float): Float;

	@:include("cmath", true)
	@:native("asin")
	public extern static function asin(v: Float): Float;

	@:include("cmath", true)
	@:native("acos")
	public extern static function acos(v: Float): Float;

	@:include("cmath", true)
	@:native("atan")
	public extern static function atan(v: Float): Float;

	@:include("cmath", true)
	@:native("atan2")
	public extern static function atan2(y: Float, x: Float): Float;

	@:include("cmath", true)
	@:native("exp")
	public extern static function exp(v: Float):Float;

	@:include("cmath", true)
	@:native("log")
	public extern static function log(v: Float):Float;

	@:include("cmath", true)
	@:native("pow")
	public extern static function pow(v: Float, exp: Float): Float;

	@:include("cmath", true)
	@:native("sqrt")
	public extern static function sqrt(v:Float):Float;

	@:include("cmath", true)
	@:native("round")
	public extern static function round(v:Float):Int;

	@:include("cmath", true)
	@:native("floor")
	public extern static function floor(v:Float):Int;

	@:include("cmath", true)
	@:native("ceil")
	public extern static function ceil(v:Float):Int;

	@:include("cstdlib", true)
	public extern inline static function random(): Float {
		return untyped __fcpp__("(((float)rand()) / RAND_MAX)");
	}

	public extern inline static function ffloor(v:Float): Float return floor(v);
	public extern inline static function fceil(v:Float): Float return ceil(v);
	public extern inline static function fround(v:Float): Float return round(v);

	@:include("cmath", true)
	@:native("std::isfinite")
	public extern overload static function isFinite(f: Float): Bool;

	@:include("cmath", true)
	@:nativeFunctionCode("std::isfinite((double){arg0})")
	public extern overload static function isFinite(f: Int): Bool;

	@:include("cmath", true)
	@:native("std::isnan")
	public extern static function isNaN(f: Float): Bool;
}