package;

class Main {
	public var other: cxx.Value<Other>;

	public function new() {}
}

function main() {
	trace("Hello world!");

	final m = new Main();
	final o = new Other(m);
}
