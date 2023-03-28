package;

import haxe.PosInfos;

// Typedefs
typedef MyInt = Int;
typedef MyIntInt = MyInt;

// Value class
@:valueType
class ValueClass {
	public function new() {}
	public var val = 100;
}

typedef ValueClassDef = ValueClass;
typedef ValueClassPtr = ucpp.Ptr<ValueClass>;
typedef ValueClassPtr2 = ucpp.Ptr<ValueClassPtr>;
typedef ValueClassPtr2Value = ucpp.Value<ValueClassPtr2>;
typedef ValueClassPtr2ValueSharedPtr = ucpp.SharedPtr<ValueClassPtr2Value>;

// Normal class
class NormalClass {
	public function new() {}
}

// errorExit
var exitCode = 0;
function assert(cond: Bool, pos: Null<PosInfos> = null) {
	if(!cond) {
		haxe.Log.trace("Assert failed!", pos);
		exitCode = 1;
	}
}

// main
function main() {
	final tdInt: MyInt = 123;
	final realInt = 123;
	assert(tdInt == realInt);

	final td2Int: MyIntInt = 123;
	assert(td2Int == tdInt);

	final a = new ValueClass();
	final b: ValueClassPtr = a;
	final c: ValueClassPtr2 = b;
	final d: ValueClassPtr2Value = c;
	final e: ValueClassPtr2ValueSharedPtr = d;

	assert(a.val == 100);
	assert(b.val == 100);
	assert(c.val == 100);
	assert(d.val == 100);
	assert(e.val == 100);

	assert(a == cast e);

	final f: ucpp.Value<NormalClass> = new NormalClass();
	assert(f == f);

	if(exitCode != 0) {
		Sys.exit(exitCode);
	}
}
