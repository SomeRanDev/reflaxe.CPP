package;

extern class Stdlib {
	@:native("malloc")
	@:include("stdlib.h", true)
	public static extern function malloc(size: Int): Ptr<Void>;

	@:native("free")
	@:include("stdlib.h", true)
	public static extern function free(p: Ptr<Void>): Void;

	@:native("sizeof")
	public static extern function sizeof(a: Dynamic): Int;
}
