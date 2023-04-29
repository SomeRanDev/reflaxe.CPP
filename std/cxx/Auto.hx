package cxx;

@:cxxStd
@:native("auto")
@:valueType
extern class IAuto {
}

@:cxxStd
@:noInclude
extern abstract Auto(IAuto) from Dynamic to Dynamic {
}
