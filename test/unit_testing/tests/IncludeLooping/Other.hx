package;

class Other {
	// switch to cxx.Value<> to trigger error!
	public var main: Other2; //cxx.Value<Other2>;

	public function new(main: Other2 = null) {
		this.main = main;
	}
}
