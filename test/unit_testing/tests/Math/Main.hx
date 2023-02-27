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

	static function assertFloat(a: Float, b: Float, infos: Null<PosInfos> = null) {
		if(Math.abs(a - b) >= 0.001) {
			haxe.Log.trace("Assert failed", infos);
			returnCode = 1;
		}
	}

	@:topLevel
	@:dce(Off)
	public static function main(): Int {
		assert(Math.ceil(2 * Math.pow(Math.PI, 2)) == 20);

		assert(Math.abs(-3) == 3);

		assert(Math.ceil(2.1) == 3);
		assert(Math.ceil(0.9) == 1);

		assert(Math.ceil(Math.exp(1.0)) == 3);
		assert(Math.floor(Math.exp(1.0)) == 2);

		assert(Math.floor(99.9) == 99);

		assert(Math.isFinite(12));
		assert(Math.isNaN(Math.NaN));
		assert(!Math.isFinite(Math.POSITIVE_INFINITY));
		assert(!Math.isFinite(Math.NEGATIVE_INFINITY));

		assertFloat(Math.sin(Math.PI), 0.0);
		assertFloat(Math.cos(0), 1);
		assertFloat(Math.tan(4), 1.157821);
		assertFloat(Math.asin(1), 1.570796);
		assert(Math.isNaN(Math.acos(100)));
		assertFloat(Math.atan(12), 1.4876);
		assertFloat(Math.atan2(-3, 3), -0.78539);

		assertFloat(Math.log(10), 2.30258);

		assert(Math.sqrt(25) == 5);
		assert(Math.sqrt(100) == 10);

		return returnCode;
	}
}