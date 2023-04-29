package cxx;

@:cxxStd
@:arrowAccess
@:overrideMemoryManagement
@:uniquePtrType
@:include("memory", true)
@:forward
extern abstract UniquePtr<T>(T) from T to T {
}
