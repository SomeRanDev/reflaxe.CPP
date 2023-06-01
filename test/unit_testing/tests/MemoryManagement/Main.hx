package;

@:valueType
class Test {
	public function new() {}
	public var a = 123;
}

var t: Test;

// ---

function main() {
	trace("Hello world!");

	t = new Test();
}

function getTest(): cxx.Ptr<Test> {
	return t;
}
