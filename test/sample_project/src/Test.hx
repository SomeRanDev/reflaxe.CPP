package;
/*
abstract Test(Int) from Int to Int {
	public function new(i: Int) {
		this = i;
	}

	public function toDouble(): Int {
		return this * 2;
	}
}

enum Test2 {
	One;
	Two;
	Three(a: Int);
}

class Bla {
	public var a = 123;
	public function new() {
	}
}

function test_anon(a: {name: String}) {
	trace(a.name);
}

function main() {
	trace("Hello world!");

	var a: Ptr<Int> = cast Stdlib.malloc(12);
	Stdlib.free(cast a);

	var c: Null<Bla> = new Bla();
	trace(Std.string(c.a));

	function bla(input: { name: String, age: Int }) {
		trace(input.name);
	}
	bla({name: "John", age: 123});
	

	var d = Three(123);
	switch(d) {
		case Three(v): trace(Std.string(v));
		case _:
	}

	final b = new Test(123);
	trace(Std.string(b.toDouble()));
}
*/

/*
class Person {
	public function new() {
		name = "John";
	}

	public function toString() {
		return name;
	}

	public var name: String;
}

function bla(a: { function toString(): String; }) {
	trace(a.toString());
}*/

@:topLevel
function test() {
	trace("in test");
}

@:topLevel
function main(): Int {
	test();
	trace("Hello", "world!", "Again");

	var bla = 123;
	if(bla == 123) {
		trace("It's 123!!");
	} else if(bla == 23) {
		trace("23");
	} else {
		trace("1");
	}

	//bla(new Person());
	return 0;
}