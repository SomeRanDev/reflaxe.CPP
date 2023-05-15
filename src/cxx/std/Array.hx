package cxx.std;

@:nativeTypeCode("std::array<{type0}, {type1}>")
@:include("array", true)
extern class Array<T, @:const Count: Int>  {
	public function new();

	public function at(pos: cxx.num.SizeT): T;
	public function front(): T;
	public function back(): T;
	public function data(): cxx.CArray<T>;

	public function empty(): Bool;
	public function size(): cxx.num.SizeT;
	public function maxSize(): cxx.num.SizeT;

	public function fill(value: T): Void;
}
