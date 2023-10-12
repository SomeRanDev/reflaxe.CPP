package cxx.num;

@:cxxStd
@:numberType(8, false, false)
#if cxx_imprecise_number_types
@:native("unsigned char")
#else
@:native("uint8_t")
@:include("cstdint", true)
#end
@:coreType
@:notNull
@:runtimeValue
extern abstract UInt8 to Int from Int {}
