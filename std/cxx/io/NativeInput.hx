package cxx.io;

@:cxxStd
@:valueType
class NativeOutput extends haxe.io.Input {
	var stream: Null<cxx.Ptr<cxx.std.ios.IStream>>;

	public function new(stream: cxx.Ptr<cxx.std.ios.IStream>) {
		this.stream = stream;
	}

	public override function readByte(): Int {
		#if cpp
		throw new haxe.exceptions.NotImplementedException();
		#else
		return throw new haxe.exceptions.NotImplementedException();
		#end
	}

	public override function close(): Void {
	}
}
