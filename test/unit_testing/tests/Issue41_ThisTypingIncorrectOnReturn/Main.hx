package;

/**
	TODO: Make `withBar` work without having explicit `cxx.Ptr<FooBuilder>` return type.
**/
class FooBuilder {
	public function new() {}
	public function withBar(): cxx.Ptr<FooBuilder> {
		// return this // <-- works

		// works
		// var r: cxx.Ptr<FooBuilder> = this;
		// return r;

		var r = this;
		return r; // <-- does not work: Cannot convert unsafe pointer (Ptr<T>) to shared pointer (SharedPtr<T>).
	}
}

function main() {
	new FooBuilder().withBar();
}
