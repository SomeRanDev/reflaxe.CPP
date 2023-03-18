package;

import haxe.PosInfos;

class Main {
	static var returnCode = 0;

	static function assert(b: Bool, infos: Null<PosInfos> = null) {
		if(!b) {
			haxe.Log.trace("Assert failed", infos);
			returnCode = 1;
		}
	}

	public static function main() {
		final reg = ~/abc/;

		// match
		final result = reg.match("abcdef");
		assert(result);

		// matched
		assert(reg.matched(0) == "abc");
		assert(reg.matched(1) == "");

		// matchedPos
		final pos = reg.matchedPos();
		assert(pos.pos == 0);
		assert(pos.len == 3);

		// matchSub
		final reg2 = ~/abc/;
		assert(reg2.matchSub("abcabc", 1));

		final pos2 = reg2.matchedPos();
		assert(pos2.pos == 3);
		assert(pos2.len == 3);
		assert(reg2.matched(0) == "abc");
		assert(reg2.matchedLeft() == "abc");
		assert(reg2.matchedRight() == "");

		// captures
		final capReg = ~/(a)(.)b/;
		assert(capReg.match("Check this out: a#b and also this: a_b."));
		assert(capReg.matched(0) == "a#b");
		assert(capReg.matched(1) == "a");
		assert(capReg.matched(2) == "#");
		assert(capReg.matched(3) == "");
		assert(capReg.matched(-1) == "");
		assert(capReg.matched(9999) == "");

		// split
		assert(~/splitme/.split("") == [""]);
		assert(~/splitme/.split("Hello world!") == ["Hello world!"]);
		assert(~/\s*,\s*/.split("one,two ,three, four") == ["one", "two", "three", "four"]);

		// replace
		assert(reg.replace("123abc", "456") == "123456");
		assert(~/\|([a-z]+)\|/g.replace("|a| |b| fdsf tew |cdef|", "($1)") == "(a) (b) fdsf tew (cdef)");

		// map
		final newStr = reg.map("123abc", function(ereg) {
			final p = ereg.matchedPos();
			return ereg.matched(0) + "_data:(" + p.len + ", " + p.pos + ")";
		});
		assert(newStr == "123abc_data:(3, 3)");

		// EReg.escape
		assert(EReg.escape("...") == "\\.\\.\\.");

		if(returnCode != 0) {
			Sys.exit(returnCode);
		}
	}
}