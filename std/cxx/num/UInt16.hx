package cxx.num;

@:cxxStd
@:numberType(16, false, false)
#if cxx_imprecise_number_types
@:native("unsigned short")
#else
@:native("uint16_t")
@:include("cstdint", true)
#end
@:coreType
@:notNull
@:runtimeValue
extern abstract UInt16 to Int from Int {}
