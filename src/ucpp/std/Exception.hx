package ucpp.std;

@:native("std::exception")
@:include("exception", true)
@:valueType
extern class Exception {
	@:noexcept public function new();
	@:noexcept @:virtual public function what(): ConstCharPtr;
}
