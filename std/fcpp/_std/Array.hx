import haxe.iterators.ArrayKeyValueIterator;

@:nativeName("std::vector")
@:include("vector", true)
@:valueType
@:coreApi
extern class Array<T> {
	@:nativeName("size()")
	var length(default, null):Int;
	function new():Void;
	function concat(a:Array<T>):Array<T>;
	function join(sep:String):String;
	function pop():Null<T>;

	@:nativeName("push_back")
	function push(x:T):Int;
	function reverse():Void;
	function shift():Null<T>;
	function slice(pos:Int, ?end:Int):Array<T>;
	function sort(f:T->T->Int):Void;
	function splice(pos:Int, len:Int):Array<T>;
	function toString():String;
	function unshift(x:T):Void;
	function insert(pos:Int, x:T):Void;
	function remove(x:T):Bool;
	@:pure function contains( x : T ) : Bool;
	function indexOf(x:T, ?fromIndex:Int):Int;
	function lastIndexOf(x:T, ?fromIndex:Int):Int;
	function copy():Array<T>;

	@:runtime inline function iterator():haxe.iterators.ArrayIterator<T> {
		return new haxe.iterators.ArrayIterator(this);
	}

	@:pure @:runtime public inline function keyValueIterator() : ArrayKeyValueIterator<T> {
		return new ArrayKeyValueIterator(this);
	}

	@:runtime inline function map<S>(f:T->S):Array<S> {
		#if (cpp && !cppia)
		var result = cpp.NativeArray.create(length);
		for (i in 0...length) cpp.NativeArray.unsafeSet(result, i, f(cpp.NativeArray.unsafeGet(this, i)));
		return result;
		#else
		return [for (v in this) f(v)];
		#end
	}

	@:runtime inline function filter(f:T->Bool):Array<T> {
		return [for (v in this) if (f(v)) v];
	}

	function resize(len:Int):Void;
}