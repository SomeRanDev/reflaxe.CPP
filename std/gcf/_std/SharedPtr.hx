package;

@:arrowAccess
@:overrideMemoryManagement
@:sharedPtrType
@:include("memory", true)
extern abstract SharedPtr<T>(T) from T to T {
	@:nativeFunctionCode("(*{this})")
	@:to public extern function toValue(): T;
}
