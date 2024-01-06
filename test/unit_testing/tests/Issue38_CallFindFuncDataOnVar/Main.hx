package;

class Main {
	var fn: ()->Void;
	
	static function main() {
		new Main();
	}

	public function new() {
		fn = function() {
			trace("do something");
		}
		fn();
	}
}
