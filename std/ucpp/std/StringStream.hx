package ucpp.std;

@:include("sstream", true)
extern class StringStream {
	public function new();
	public function str(): String;

	@:nativeName("operator<<")
	public function add(any: Dynamic): StringStream;
}
