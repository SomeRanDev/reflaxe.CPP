package cxx.std;

@:cxxStd
@:cppStd
@:native("std::type_info")
@:valueType
extern class TypeInfo {
	@:const public function name(): ConstCharPtr;
}
