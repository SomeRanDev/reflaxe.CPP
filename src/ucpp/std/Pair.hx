package ucpp.std;

@:ucppStd
@:nativeName("std::pair")
@:noHaxeNamespaces
@:include("utility", true)
@:valueType
extern class Pair<T, U> {
	public function new(first: T, second: U);

	public var first: T;
	public var second: U;
}
