package ucpp;

@:ucppStd
@:nativeName("std::map")
@:noHaxeNamespaces
@:include("map", true)
@:valueType
extern class StdMap<T, U> {
	public function new();

	public function begin(): StdMapIterator<T, U>;
	public function end(): StdMapIterator<T, U>;

	@:const @:noExcept public function empty(): Bool;
	@:const @:noExcept public function size(): ucpp.SizeT;
	@:nativeName("max_size") @:const @:noExcept public function maxSize(): ucpp.SizeT;
	public function at(key: T): U;
	public function insert(values: ucpp.std.Pair<T, U>): Void;
	public function erase(key: T): ucpp.SizeT;
	@:noExcept public function clear(): Void;
	public function find(key: T): StdMapIterator<T, U>;
	@:const public function count(key: T): ucpp.SizeT;
}

@:ucppStd
@:forward
@:nativeTypeCode("std::map<{type0}, {type1}>::iterator")
@:typenamePrefixIfDependentScope
@:valueType
@:noInclude
@:directEquality
extern abstract StdMapIterator<T, U>(ucpp.Ptr<ucpp.std.Pair<T, U>>) from ucpp.Ptr<ucpp.std.Pair<T, U>> to ucpp.Ptr<ucpp.std.Pair<T, U>> {
}
