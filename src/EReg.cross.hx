package;

@:cxxStd
@:native("std::regex")
@:include("regex", true)
@:valueType
extern enum abstract SyntaxOptionType(Int) to Int {
	@:nativeName("icase") var ICase;
	@:nativeName("nosubs") var NoSubs;
	@:nativeName("optimized") var Optimize;
	var ECMAScript;
}

@:cxxStd
@:native("std::regex")
@:include("regex", true)
@:valueType
extern class StdRegex {
	public function new(r: String, options: Int);
}

@:cxxStd
@:valueType
@:native("std::smatch")
extern class StringMatch {
	public function new();
	public function str(n: Int): String;
	public function prefix(): String;
	public function suffix(): String;
	public function length(): Int;
	public function position(): Int;
	public function size(): Int;
}

@:cxxStd
@:coreApi
@:valueType
class EReg {
	var regex: StdRegex;
	var smatch: StringMatch;

	var originalString: String;
	var originalOptions: String;

	var matches: Null<Array<String>>;
	var left: Null<String>;
	var right: Null<String>;
	var matchPos: Int;
	var matchLen: Int;

	var isGlobal: Bool;

	public function new(r: String, opt: String) {
		regex = new StdRegex(r, SyntaxOptionType.ECMAScript | SyntaxOptionType.ICase);
		smatch = new StringMatch();

		originalString = r;
		originalOptions = opt;

		matches = null;
		left = null;
		right = null;
		matchPos = 0;
		matchLen = 0;

		isGlobal = StringTools.contains(opt, "g");
	}

	function toString(): String {
		return "~/" + originalString + "/" + originalOptions;
	}

	public function match(s: String): Bool {
		final result: Bool = untyped __cpp__("std::regex_search({}, {}, {})", s, smatch, regex);

		// Note: std::regex_search and smatch use references to the original string.
		//
		// So all the "std::smatch" information must be stored before the "s: String" argument
		// goes out of scope. Otherwise, you're left with hanging references.
		if(result) {
			left = smatch.prefix();
			right = smatch.suffix();
			matchPos = smatch.position();
			matchLen = smatch.length();
			matches = [];
			for(i in 0...smatch.size()) {
				matches.push(smatch.str(i));
			}
		}

		return result;
	}

	public function matched(n: Int): String {
		if(matches == null) return "";
		if(n < 0 || n >= matches.length) return "";
		return matches[n];
	}

	public function matchedLeft(): String {
		if(left == null) return "";
		return left;
	}

	public function matchedRight(): String {
		if(right == null) return "";
		return right;
	}

	public function matchedPos(): { pos:Int, len:Int } {
		return { pos: matchPos, len: matchLen };
	}

	public function matchSub(s: String, pos: Int, len: Int = -1): Bool {
		final result = match(s.substr(pos, len));

		if(result) {
			matchPos += pos;
			left = s.substr(0, matchPos);
			right = s.substr(matchPos + matchLen);
		}

		return result;
	}

	public function split(s: String): Array<String> {
		if(s.length <= 0) {
			return [s];
		}

		final result = [];
		var index = 0;
		while(true) {
			if(matchSub(s, index)) {
				final pos = matchedPos();
				result.push(s.substring(index, pos.pos));

				// prevent infinite loop
				if((pos.pos + pos.len) <= index) {
					break;
				}

				index = pos.pos + pos.len;

				if(index >= s.length) {
					break;
				}

			} else {
				result.push(s.substring(index));
				break;
			}
		}

		return result;
	}

	// ---------------------------------------------------------------------
	// The following functions heavily borrow/reuse the EReg code from the
	// Haxe/C++ version. The original code and license can be found here:
	//
	// https://github.com/HaxeFoundation/haxe/blob/4.2.5/std/cpp/_std/EReg.hx
	//
	// https://haxe.org/foundation/open-source.html#std-library-license
	// ---------------------------------------------------------------------
	public function replace(s: String, by: String): String {
		var b = new StringBuf();
		var pos = 0;
		var len = s.length;
		var a = by.split("$");
		var first = true;
		do {
			if(!matchSub(s, pos, len))
				break;
			var p = matchedPos();
			if(p.len == 0 && !first) {
				if (p.pos == s.length)
					break;
				p.pos += 1;
			}
			b.addSub(s, pos, p.pos - pos);
			if (a.length > 0)
				b.add(a[0]);
			var i = 1;
			while(i < a.length) {
				var k = a[i];
				var c = k.charCodeAt(0);
				// 1...9
				if(c >= 49 && c <= 57) {
					var matchReplace = {
						final matchIndex = Std.int(c) - 48;
						if(matches != null && matchIndex < matches.length) {
							matches[matchIndex];
						} else {
							null;
						}
					}
					if(matchReplace == null) {
						b.add("$");
						b.add(k);
					} else {
						b.add(matchReplace);
						b.addSub(k, 1, k.length - 1);
					}
				} else if(c == null) {
					b.add("$");
					i++;
					var k2 = a[i];
					if (k2 != null && k2.length > 0)
						b.add(k2);
				} else
					b.add("$" + k);
				i++;
			}
			var tot = p.pos + p.len - pos;
			pos += tot;
			len -= tot;
			first = false;
		} while(isGlobal);
		b.addSub(s, pos, len);
		return b.toString();
	}

	public function map(s: String, f: (EReg) -> String): String {
		var offset = 0;
		var buf = new StringBuf();
		do {
			if(offset >= s.length)
				break;
			else if(!matchSub(s, offset)) {
				buf.add(s.substr(offset));
				break;
			}
			var p = matchedPos();
			buf.add(s.substr(offset, p.pos - offset));
			buf.add(f(this));
			if(p.len == 0) {
				buf.add(s.substr(p.pos, 1));
				offset = p.pos + 1;
			} else
				offset = p.pos + p.len;
		} while(isGlobal);
		if(!isGlobal && offset > 0 && offset < s.length)
			buf.add(s.substr(offset));
		return buf.toString();
	}

	static var escapeRegExpRe = ~/[\[\]{}()*+?.\\\^$|]/g;
	public static function escape(s: String): String {
		return escapeRegExpRe.map(s, function(r) {
			return "\\" + r.matched(0);
		});
	}
}
