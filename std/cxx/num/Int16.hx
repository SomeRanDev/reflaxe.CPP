package cxx.num;

@:cxxStd
@:numberType(16, false, true)
#if cxx_imprecise_number_types
@:native("short")
#else
@:native("int16_t")
@:include("cstdint", true)
#end
@:coreType
@:notNull
@:runtimeValue
extern abstract Int16 to Int from Int {}
