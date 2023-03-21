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

		if(returnCode != 0) {
			Sys.exit(returnCode);
		}
	}
}