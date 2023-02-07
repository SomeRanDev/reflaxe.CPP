package;

@:arrowAccess
@:overrideMemoryManagement
@:valueType
extern abstract Value<T>(T) from T to T {
	@:nativeFunctionCode("std::make_shared({this})")
	@:to public extern function toShared(): SharedPtr<T>;
}
