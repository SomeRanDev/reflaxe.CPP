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

	#if !cxx_disable_ptr_to_string
	@:nativeFunctionCode("std::string({this})")
	@:include("string", true)
	public function toString(): String;
	#end

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

	@:from
    @:nativeFunctionCode("{arg0}")
	static function fromSubType<T, U: T>(other: Ptr<U>) : Ptr<T>;
}
