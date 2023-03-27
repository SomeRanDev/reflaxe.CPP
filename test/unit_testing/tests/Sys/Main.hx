package;

import haxe.PosInfos;

class Main {
	var a: Int = 123;
	static var returnCode = 0;

	static function assert(b: Bool, infos: Null<PosInfos> = null) {
		if(!b) {
			haxe.Log.trace("Assert failed", infos);
			returnCode = 1;
		}
	}

	public static function main() {

		trace(Sys.getEnv("ANDROID_NDK_VERSION"));

		trace(ucpp.std.FileSystem.currentPath());

		final testStr = "test-value=" + (Std.random(10));
		Sys.putEnv("Haxe2UC++ Test Value", testStr);

		assert(Sys.getEnv("Haxe2UC++ Test Value") == testStr);

		Sys.putEnv("Haxe2UC++ Test Value", "");

		assert(Sys.getEnv("Haxe2UC++ Test Value") == null);

		if(returnCode != 0) {
			Sys.exit(returnCode);
		}
	}
}