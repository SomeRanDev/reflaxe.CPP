package;

@:native("{arg0}*")
@:arrowAccess
abstract Ptr<T>(T) from T to T {
	@:nativeFunctionCode("(*{this})")
	@:to public extern function toValue(): T;
}
