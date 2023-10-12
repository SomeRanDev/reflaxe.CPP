package cxx.num;

@:cxxStd
@:numberType(32, false, true)
#if cxx_imprecise_number_types
@:native("int")
#else
@:native("int32_t")
@:include("cstdint", true)
#end
@:coreType
@:notNull
@:runtimeValue
extern abstract Int32 to Int from Int {}
