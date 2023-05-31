package;

@:cxxStd
@:haxeStd
@:pseudoCoreApi
@:headerInclude("algorithm", true)
@:headerInclude("cctype", true)
@:dontGenerateDynamic
@:unreflective
@:filename("HxString")
@:headerOnly
class HxString {
	public static function toLowerCase(s: String): String {
		untyped __cpp__("std::string temp = {0}", s);
		untyped __cpp__("std::transform(temp.begin(), temp.end(), temp.begin(), [](unsigned char c){\n\treturn std::tolower(c);\n})");
		return untyped temp;
	}

	public static function toUpperCase(s: String): String {
		untyped __cpp__("std::string temp = {0}", s);
		untyped __cpp__("std::transform(temp.begin(), temp.end(), temp.begin(), [](unsigned char c){\n\treturn std::toupper(c);\n})");
		return untyped temp;
	}

	public static function split(s: String, delimiter: String): Array<String> {
		if(delimiter.length <= 0) {
			var result = [];
			var pos = 0;
			for(i in 0...s.length) {
				result.push(s.substr(pos++, 1));
			}
			return result;
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
@:cxxStd
@:haxeStd
@:nativeName("std::string", "String")
@:include("string", true)
@:valueType
@:dynamicCompatible
@:dynamicEquality
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
	@:nativeName("size()")
	@:redirectType("length_type")
	@:dynamicAccessors("default", "never")
	@:noDiscard(true)
	public var length(default, null): Int;

	@:nativeName("find")
	@:redirectType("indexOf_type")
	public function indexOf(str: String, startIndex: Int = 0): Int;
	
	@:nativeName("substr")
	public function substr(pos: Int, len: Int = -1): String;

	@:nativeName("rfind")
	@:redirectType("lastIndexOf_type")
	public function lastIndexOf(str: String, startIndex: Int = -1): Int;

	// ----------
	// @:nativeFunctionCode
	@:nativeFunctionCode("std::string(1, {arg0})")
	public static function fromCharCode(code: Int): String;

	@:makeThisValue
	@:makeThisNotNull
	@:nativeFunctionCode("std::string(1, {this}[{arg0}])")
	public function charAt(index: Int): String;

	@:makeThisValue
	@:nativeFunctionCode("{this}")
	public function toString(): String;

	@:makeThisValue
	@:makeThisNotNull
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
	private function c_str(): cxx.ConstCharPtr;
	private function data(): cxx.Ptr<cxx.Char>;
	private function at(index: Int): Int;

	// ----------
	// API functions
	private extern inline function cca(index: Int): Int {
		return if(index < 0 || index >= length) -1;
		else at(index);
	}

	// ----------
	// Redirects
	@:unusable
	@:dontGenerateDynamic
	@:noCompletion
	private var length_type: cxx.num.UInt32;

	@:unusable
	@:dontGenerateDynamic
	@:noCompletion
	private function indexOf_type(str: String, startIndex: cxx.num.SizeT = 0): cxx.num.SizeT;

	@:unusable
	@:dontGenerateDynamic
	@:noCompletion
	private function lastIndexOf_type(str: String, startIndex: cxx.num.SizeT = -1): cxx.num.SizeT;
}
