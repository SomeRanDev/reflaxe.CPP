package cxx.io;

@:cxxStd
@:haxeStd
@:valueType
class NativeInput extends haxe.io.Input {
	var stream: Null<cxx.Ptr<cxx.std.ios.IStream>>;

	public function new(stream: cxx.Ptr<cxx.std.ios.IStream>) {
		this.stream = stream;
	}

	public override function readByte(): Int {
		return stream.get();
	}

	public override function close(): Void {
	}
}
