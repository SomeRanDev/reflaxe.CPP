package cxx;

@:cxxStd
@:nativeTypeCode("{type0}*")
@:valueType
@:overrideMemoryManagement
extern abstract CArray<T>(T) {
	@:arrayAccess
	@:nativeFunctionCode("({this}[{arg0}])")
	public function get(index: Int): T;

	@:arrayAccess
	@:nativeFunctionCode("{this}[{arg0}] = {arg1}")
	public function set(index: Int, val: T): Void;
}
