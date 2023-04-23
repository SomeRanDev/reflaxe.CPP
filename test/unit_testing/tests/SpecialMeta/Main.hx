package;

@:headerCode("#define SOME_API_THING")
@:headerClassCode("// Inside the class")
@:classNamePrefix("SOME_API_THING")
@:prependContent("// This class was generated from Haxe.\n")
@:appendContent("\n// End of Main class")
class Main {
	@:prependContent("// Returns an int of value 123\n")
	@:prependContent("[[nodiscard]] ")
	@:appendContent("\n// Comment after the function")
	public static function getValue(): Int {
		return 123;
	}

	@:meta(nodiscard)
	public static function getValue2(): String {
		return "String";
	}

	public static function main() {
		trace(getValue());
		trace(getValue2());
	}
}
