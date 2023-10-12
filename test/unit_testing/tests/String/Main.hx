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
		var str: String = new String("Test");
		assert(str == "Test");
		assert(str.length == 4);
		assert(str.toString() == "Test");

		assert(String.fromCharCode(65) == "A");
		assert(String.fromCharCode(70) == "F");
		
		assert(str.charCodeAt(1) == 101);

		assert(str.indexOf("es") == 1);
		assert(str.indexOf("Hey") == -1);
		assert(str.indexOf("Te", 2) == -1);

		assert(str.lastIndexOf("Te") == 0);

		assert(str.split("s")[0] == "Te");
		assert(str.split("e").length == 2);
		assert("Hello".split("") == ["H","e","l","l","o"]);
		assert("".split("") == []);
		assert("Hello BLAworld BLA how areBLAyou?".split("BLA") == ["Hello ", "world ", " how are", "you?"]);

		var str2 = "Hello, World!";
		assert(str2.substr(7, 5) == "World");
		assert(str2.substring(7, 12) == "World");

		assert(str2.toLowerCase() == "hello, world!");
		assert(str2.toUpperCase() == "HELLO, WORLD!");

		// StringTools

		final toolsStr = "Hello world!";
		assert(StringTools.contains(toolsStr, "world"));
		assert(StringTools.endsWith(toolsStr, "world!"));

		assert(StringTools.fastCodeAt(toolsStr, 0) == 72);
		assert(StringTools.fastCodeAt(toolsStr, 99) == -1);

		assert(StringTools.hex(0) == "0");
		assert(StringTools.hex(12) == "C");
		assert(StringTools.hex(-24) == "FFFFFFE8");
		assert(StringTools.hex(12, 4) == "000C");
		assert(StringTools.hex(100, 4) == "0064");

		final html = "<button onclick=\"doThing()\">My Button ✨</button>";
		assert(StringTools.htmlEscape(html) == "&lt;button onclick=\"doThing()\"&gt;My Button ✨&lt;/button&gt;");
		assert(StringTools.htmlEscape(html, true) == "&lt;button onclick=&quot;doThing()&quot;&gt;My Button ✨&lt;/button&gt;");

		assert(StringTools.htmlUnescape("&amp;") == "&");
		assert(StringTools.htmlUnescape(StringTools.htmlEscape(html)) == html);

		assert(StringTools.startsWith(toolsStr, "Hello"));

		assert(StringTools.isEof(0));
		assert(!StringTools.isEof(65));

		assert(StringTools.isSpace(" ", 0));
		assert(StringTools.isSpace("\t", 0));
		assert(StringTools.isSpace("\n", 0));
		assert(StringTools.isSpace("\r", 0));
		assert(StringTools.isSpace("Hello world!", 5));

		{
			final it = StringTools.iterator("Hello");
			var result = "";
			while(it.hasNext()) {
				result += it.next();
			}
			assert(result == "Hello");
		}

		{
			final it = StringTools.keyValueIterator("Hello");
			var count = 0;
			var result = "";
			while(it.hasNext()) {
				final n = it.next();
				count += n.key;
				result += n.value;
			}
			assert(count == 10);
			assert(result == "Hello");
		}
		
		assert(StringTools.lpad("Hello", "-", 10) == "-----Hello");
		assert(StringTools.lpad("Hello", "-=", 10) == "-=-=-=Hello");
		assert(StringTools.lpad("Hello", "", 100) == "Hello");
		assert(StringTools.lpad("Hello", "123456789", 1) == "Hello");

		assert(StringTools.rpad("Hello", "-", 10) == "Hello-----");
		assert(StringTools.rpad("Hello", "-=", 10) == "Hello-=-=-=");
		assert(StringTools.rpad("Hello", "", 100) == "Hello");
		assert(StringTools.rpad("Hello", "123456789", 1) == "Hello");

		assert(StringTools.ltrim("    Hello") == "Hello");
		assert(StringTools.ltrim("Hello") == "Hello");
		assert(StringTools.rtrim("Hello        ") == "Hello");
		assert(StringTools.rtrim("Hello") == "Hello");

		assert(StringTools.replace("Hello world!", "Hello", "Goodbye") == "Goodbye world!");
		assert(StringTools.replace("Hello world!", "Greetings", "Goodbye") == "Hello world!");

		// urlEncode & urlDecode have platform specific implementations using
		// conditional compilation, so they simple return null for our custom
		// C++ target.
		//
		// This can be fixed later using @:build macros, but for the time
		// being, these are unsupported by Reflaxe/C++.
		assert(StringTools.urlEncode("https://github.com/SomeRanDev") == null);
		assert(StringTools.urlDecode("https://github.com/SomeRanDev") == null);

		if(returnCode != 0) {
			Sys.exit(returnCode);
		}
	}
}