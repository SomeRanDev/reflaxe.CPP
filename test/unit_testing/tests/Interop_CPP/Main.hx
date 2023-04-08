package;

// An extern function to tell Haxe about the existence of a C++ function.
//
// @:include - Ensure the header file is included wherever this function is called
// @:topLevel - Ensure this function is treated as a top-level (outside of class) function.
@:include("CppCode.h")
@:topLevel
extern function cpp_func(input: Int): String;

// An extern class to tell Haxe about the existence of a C++ class.
@:include("CppCode.h")
extern class MyClass {
	public function new(value: Float);
	public function increment(amount: Float = 1.0): Void;
	public function getValue(): Float;
}

function main() {
	// Call the C++ function from Haxe.
	trace(cpp_func(123));

	// Use the C++ class in Haxe
	final cls = new MyClass(10);
	trace(cls.getValue());

	cls.increment();
	trace(cls.getValue());

	cls.increment(9);
	trace(cls.getValue());
}
