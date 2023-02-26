package;

@:native("std::type_info")
@:valueType
extern class StdTypeInfo {
	@:const public function name(): ConstCharPtr;
}
