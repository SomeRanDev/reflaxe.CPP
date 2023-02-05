package std;

@:native("std::exception")
@:include("exception", true)
extern class Exception {
	@:noexcept public function new();
	@:noexcept @:virtual public function what(): ConstCharPtr;
}
