package;

@:arrowAccess
@:overrideMemoryManagement
@:uniquePtrType
@:include("memory", true)
extern abstract UniquePtr<T>(T) from T to T {
}
