package;

// not working (not existing in c++)
function test_me(): String {
	return "hello";
}

// works
class Test {
	public static function test(): Int {
		return 5;
	}
}

class Main {
	static function main(){
		trace("Hello world from haxe!");
		Test.test();
		test_me(); 
	}
}
