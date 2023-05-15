package cxx.num;

@:cxxStd
@:numberType(32, false, false)
@:include("cstddef", true)
@:native("std::size_t")
@:notNull
@:runtimeValue
@:coreType
extern abstract SizeT from Int to Int {
}
