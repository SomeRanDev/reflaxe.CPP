package cxx.num;

@:cxxStd
@:numberType(32, false, false)
#if cxx_imprecise_number_types
@:native("unsigned int")
#else
@:native("uint32_t")
@:include("cstdint", true)
#end
@:coreType
@:notNull
@:runtimeValue
extern abstract UInt32 to Int from Int {}
