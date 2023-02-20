package;

@:coreApi
@:native("std::string")
@:include("string", true)
@:valueType
@:coreApi
extern class String {
	// ----------------------------
	// Haxe String Functions
	// ----------------------------

	// ----------
	// constructor
	@:nativeFunctionCode("{arg0}")
	public function new(string: String);

	// ----------
	// @:nativeName
	@:nativeName("length()")
	public var length(default, null): Int;

	@:runtime public inline function toUpperCase(): String throw "String.toUpperCase not implemented";
	@:runtime public inline function toLowerCase(): String throw "String.toLowerCase not implemented";

	@:nativeName("find")
	public function indexOf(str: String, startIndex: Int = 0): Int;
	
	@:nativeName("substr")
	public function substr(pos: Int, len: Int = -1): String;

	@:nativeName("rfind")
	public function lastIndexOf(str: String, startIndex: Int = -1): Int;

	// ----------
	// @:nativeFunctionCode
	@:nativeFunctionCode("std::string(1, {arg0})")
	public static function fromCharCode(code: Int): String;

	@:nativeFunctionCode("std::string(1, {this}[{arg0}])")
	public function charAt(index: Int): String;

	@:nativeFunctionCode("{this}")
	public function toString(): String;

	@:nativeFunctionCode("{this}[{arg0}]")
	public function charCodeAt(index: Int): Null<Int>;

	// ----------
	// @:runtime inline
	@:runtime public inline function split(delimiter: String): Array<String> throw "String.split not implemented";

	@:runtime public inline function substring(startIndex: Int, endIndex: Int = -1): String {
		return if(endIndex < 0) {
			substr(startIndex);
		} else {
			substr(startIndex, endIndex - startIndex);
		}
	}
}
