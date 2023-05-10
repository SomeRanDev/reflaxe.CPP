package cxx;

@:cxxStd
@:arrowAccess
@:overrideMemoryManagement
@:sharedPtrType
@:include("memory", true)
@:forward
extern abstract SharedPtr<T>(T) from T to T {
	@:typeArgNotNullable
	@:nativeFunctionCode("std::make_shared<{type0}>({arg0})")
	public static extern function make<T>(obj: T): SharedPtr<T>;
}
