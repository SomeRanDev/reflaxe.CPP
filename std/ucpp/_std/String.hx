package;

@:pseudoCoreApi
@:headerInclude("algorithm", true)
@:headerInclude("cctype", true)
@:filename("HxString")
@:headerOnly
class HxString {
	public static function toLowerCase(s: String): String {
		untyped __ucpp__("std::string temp = {}", s);
		untyped __ucpp__("std::transform(temp.begin(), temp.end(), temp.begin(), [](unsigned char c){\n\treturn std::tolower(c);\n})");
		return untyped temp;
	}

	public static function toUpperCase(s: String): String {
		untyped __ucpp__("std::string temp = {}", s);
		untyped __ucpp__("std::transform(temp.begin(), temp.end(), temp.begin(), [](unsigned char c){\n\treturn std::toupper(c);\n})");
		return untyped temp;
	}

	public static function split(s: String, delimiter: String): Array<String> {
		if(delimiter.length <= 0) {
			return [];
		}

		var result = [];
		var pos = 0;
		while (true) {
			var newPos = s.indexOf(delimiter, pos);
			if(newPos == -1) {
				result.push(s.substring(pos));
				break;
			} else {
				result.push(s.substring(pos, newPos));
			}
			pos = newPos + delimiter.length;
		}
		return result;
	}
}

@:coreApi
@:nativeName("std::string")
@:include("string", true)
@:valueType
@:filename("HxString")
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
	@:runtime public inline function toUpperCase(): String {
		return HxString.toUpperCase(this);
	}

	@:runtime public inline function toLowerCase(): String {
		return HxString.toLowerCase(this);
	}

	@:runtime public inline function split(delimiter: String): Array<String> {
		return HxString.split(this, delimiter);
	}

	@:runtime public inline function substring(startIndex: Int, endIndex: Int = -1): String {
		return if(endIndex < 0) {
			substr(startIndex);
		} else {
			substr(startIndex, endIndex - startIndex);
		}
	}

	// ----------
	// Native string functions
	private function c_str(): ucpp.ConstCharPtr;
	private function data(): ucpp.Ptr<ucpp.Char>;
}
