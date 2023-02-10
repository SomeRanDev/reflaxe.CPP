package;

@:arrowAccess
@:overrideMemoryManagement
@:sharedPtrType
@:include("memory", true)
@:forward
extern abstract SharedPtr<T>(T) from T to T {
}
