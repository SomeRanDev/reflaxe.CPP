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
		// Sys.getEnv
		// Sys.putEnv
		final key = "Haxe2UC++ Test Value";
		final val = "test-value=" + (Std.random(10));

		assert(Sys.getEnv(key) == null);
		Sys.putEnv(key, val);
		assert(Sys.getEnv("Haxe2UC++ Test Value") == val);
		Sys.putEnv(key, "");
		assert(Sys.getEnv(key) == null);

		// Sys.environment
		Sys.putEnv(key + "env_map", "123");
		assert(Sys.environment().get(key + "env_map") == "123");

		final args = Sys.args();
		assert(args.length == 1);
		assert(args[0].indexOf("test_out") >= 0);

		// Sys.getCwd
		// Not consistent enough to test, so we'll just print and see if it crashes.
		trace(Sys.getCwd());

		#if windows
		Sys.setCwd("C:/");
		assert(Sys.getCwd() == "C:\\");
		#end

		// Sys.time
		trace(Sys.time());

		// ---
		// Check both "Sys.sleep" and "Sys.cpuTime"

		// Get time before sleep.
		final beforeSleep = Sys.cpuTime();

		// Sys.sleep
		Sys.sleep(1.3);

		// Duration of sleep.
		final sleepTime =  Sys.cpuTime() - beforeSleep;

		// Check if "sleepTime" is around 1.3 seconds
		assert(sleepTime > 1.29 && sleepTime < 1.31);
		trace("sleepTime = " + sleepTime); // Debug purposes

		if(returnCode != 0) {
			Sys.exit(returnCode);
		}
	}
}