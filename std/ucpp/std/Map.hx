package ucpp.std;

@:ucppStd
@:nativeName("std::map")
@:noHaxeNamespaces
@:include("map", true)
@:valueType
extern class Map<T, U> {
	public function new();

	public function begin(): MapIterator<T, U>;
	public function end(): MapIterator<T, U>;

	@:const @:noExcept public function empty(): Bool;
	@:const @:noExcept public function size(): ucpp.SizeT;
	@:nativeName("max_size") @:const @:noExcept public function maxSize(): ucpp.SizeT;
	public function at(key: T): U;
	public function insert(values: ucpp.std.Pair<T, U>): Void;
	public function erase(key: T): ucpp.SizeT;
	@:noExcept public function clear(): Void;
	public function find(key: T): MapIterator<T, U>;
	@:const public function count(key: T): ucpp.SizeT;
}

@:ucppStd
@:forward
@:nativeTypeCode("std::map<{type0}, {type1}>::iterator")
@:typenamePrefixIfDependentScope
@:valueType
@:noInclude
@:directEquality
extern abstract MapIterator<T, U>(ucpp.Ptr<ucpp.std.Pair<T, U>>) from ucpp.Ptr<ucpp.std.Pair<T, U>> to ucpp.Ptr<ucpp.std.Pair<T, U>> {
}
