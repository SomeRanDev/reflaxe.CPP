package cxx;

@:cxxStd
@:arrowAccess
@:overrideMemoryManagement
@:unsafePtrType
@:forward
extern abstract Ptr<T>(T) from T to T from Value<T> {
	public static var Null(get, never): Ptr<Dynamic>;

	@:nativeFunctionCode("nullptr")
	public static function get_Null(): Ptr<Dynamic>;

	@:nativeFunctionCode("std::string({this})")
	@:include("string", true)
	public function toString(): String;

	@:nativeFunctionCode("({this} == nullptr)")
	public function isNull(): Bool;

	@:nativeFunctionCode("({this} == {arg1})")
	public function addrEquals<U>(other: cxx.Ptr<U>): Bool;

	@:nativeFunctionCode("({this} != {arg1})")
	public function addrNotEquals<U>(other: cxx.Ptr<U>): Bool;

	@:nativeFunctionCode("({this}++)")
	public function increment(): Void;

	@:nativeFunctionCode("({this}--)")
	public function decrement(): Void;

	@:nativeFunctionCode("(*{this})")
	public function toValue(): cxx.Value<T>;
}
