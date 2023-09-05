package cxx;

@:cxxStd
@:cppStd
@:arrowAccess
@:overrideMemoryManagement
@:uniquePtrType
@:include("memory", true)
@:forward
extern abstract UniquePtr<T>(T) from T to T {
	@:nativeFunctionCode("({this}.get())")
	public function asPtr(): cxx.Ptr<T>;

	@:nativeFunctionCode("({this}.reset())")
	public overload function reset(): Void;

	@:nativeFunctionCode("({this}.reset({arg1}))")
	public overload function reset(other: cxx.Ptr<T>): Void;

	@:from
    @:nativeFunctionCode("{arg0}")
	static function fromSubType<T, U: T>(other: UniquePtr<U>) : UniquePtr<T>;
}
