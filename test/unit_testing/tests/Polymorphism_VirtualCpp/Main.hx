package;

class Base {
	public function new() {}

	public function getVal(): Int return 1;
	public function getVal2(): Int return 999;
}

class Child extends Base {
	public override function getVal(): Int return 2;
}

function main() {
	final b: Base = new Base();
	final c: Child = new Child();
	final b2: Base = c;

	if(b.getVal() != 1) Sys.exit(1);
	if(c.getVal() != 2) Sys.exit(1);

	// b2 should use Child.getVal based on virtual/polymorphic rules.
	if(b2.getVal() != 2) Sys.exit(1);

	if(b2.getVal2() != 999) Sys.exit(1);
}
