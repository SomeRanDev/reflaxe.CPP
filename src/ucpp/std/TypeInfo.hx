package ucpp.std;

@:native("std::type_info")
@:valueType
extern class TypeInfo {
	@:const public function name(): ConstCharPtr;
}
