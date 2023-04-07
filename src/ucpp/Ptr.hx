package ucpp;

@:arrowAccess
@:overrideMemoryManagement
@:unsafePtrType
@:forward
extern abstract Ptr<T>(T) from T to T {
	@:nativeFunctionCode("{this} == nullptr")
	public function isNull(): Bool;

	@:nativeFunctionCode("({this}++)")
	public function increment(): Void;

	@:nativeFunctionCode("({this}--)")
	public function decrement(): Void;

	@:nativeFunctionCode("(*{this})")
	public function toValue(): ucpp.Value<T>;
}
