package cxx;

@:cxxStd
@:cppStd
@:nativeName("std::map", "Map")
@:noHaxeNamespaces
@:include("map", true)
@:valueType
extern class StdMap<T, U> {
	public function new();

	public function begin(): StdMapIterator<T, U>;
	public function end(): StdMapIterator<T, U>;

	@:const @:noExcept public function empty(): Bool;
	@:const @:noExcept public function size(): cxx.num.SizeT;
	@:nativeName("max_size") @:const @:noExcept public function maxSize(): cxx.num.SizeT;
	public function at(key: T): U;
	public function insert(values: cxx.std.Pair<T, U>): Void;
	public function erase(key: T): cxx.num.SizeT;
	@:noExcept public function clear(): Void;
	public function find(key: T): StdMapIterator<T, U>;
	@:const public function count(key: T): cxx.num.SizeT;
}

@:cxxStd
@:forward
@:nativeTypeCode("std::map<{type0}, {type1}>::iterator")
@:typenamePrefixIfDependentScope
@:valueType
@:noInclude
@:directEquality
extern abstract StdMapIterator<T, U>(cxx.Ptr<cxx.std.Pair<T, U>>) from cxx.Ptr<cxx.std.Pair<T, U>> to cxx.Ptr<cxx.std.Pair<T, U>> {
}
