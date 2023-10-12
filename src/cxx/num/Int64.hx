package cxx.num;

@:cxxStd
@:numberType(64, false, true)
#if cxx_imprecise_number_types
@:native("long")
#else
@:native("int64_t")
@:include("cstdint", true)
#end
@:coreType
@:notNull
@:runtimeValue
extern abstract Int64 to Int from Int {}
