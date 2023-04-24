class Main {
	var testMap: Map<String, Int>;

	public function new() {}

	function bla() {
		testMap = [];
		testMap["test"] = 123;

		trace("Test");
		trace(testMap);
	}

	public static function main() {
		final a = new Main();
		a.bla();
	}
}

