package ucpp;

@:arrowAccess
@:overrideMemoryManagement
@:unsafePtrType
@:forward
extern abstract Ptr<T>(T) from T to T {
	@:nativeFunctionCode("{this} == nullptr")
	public function isNull(): Bool;
}
