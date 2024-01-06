package;

var returnCode = 0;
function assert(v: Bool, v2: Bool, infos: Null<haxe.PosInfos> = null) {
	if(v != v2) {
		haxe.Log.trace("Assert failed", infos);
		returnCode = 1;
	}
}

// ---

interface IValidating {
	function validateComponent(nextFrame: Bool = false): Bool;
}

class Foo implements IValidating {
	public function new() {}
	public function validateComponent(nextFrame: Bool = true) {
		return nextFrame;
	}
}

class Foo2 extends Foo {
	public override function validateComponent(nextFrame: Bool = false) {
		return nextFrame;
	}
}

class Bar implements IValidating {
	public function new() {}
	public function validateComponent(nextFrame: Bool = false) {
		return nextFrame;
	}
}

// ---

function main() {
	assert(new Foo().validateComponent(), true);
	assert(new Foo2().validateComponent(), false);
	assert(new Bar().validateComponent(), false);

	Sys.exit(returnCode);
}
