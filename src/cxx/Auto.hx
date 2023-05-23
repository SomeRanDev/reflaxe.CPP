package cxx;

@:cxxStd
@:native("auto")
@:valueType
@:dontGenerateDynamic
@:unreflective
extern class IAuto {
}

@:cxxStd
@:noInclude
extern abstract Auto(IAuto) from Dynamic to Dynamic {
}
