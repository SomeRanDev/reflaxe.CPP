package cxx.num;

@:cxxStd
@:numberType(64, false, false)
#if cxx_imprecise_number_types
@:native("unsigned long")
#else
@:native("uint64_t")
@:include("cstdint", true)
#end
@:coreType
@:notNull
@:runtimeValue
extern abstract UInt64 to Int from Int {}
