package;

@:valueType
class Bla {
	public var a: Int = 123;
	public function new() {}
	@:const public function check() {
		trace("works?");
	}
}

function main() {
	final a = new Bla();

	final b: cxx.Const<cxx.Ptr<Bla>> = a;
	b.check();

	function getA(): cxx.Const<cxx.Ptr<Bla>> {
		return a;
	}

	getA().check();
}
