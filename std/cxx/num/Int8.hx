package cxx.num;

@:cxxStd
@:numberType(8, false, true)
#if cxx_imprecise_number_types
@:native("char")
#else
@:native("int8_t")
@:include("cstdint", true)
#end
@:coreType
@:notNull
@:runtimeValue
extern abstract Int8 to Int from Int {}
