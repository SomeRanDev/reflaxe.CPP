package ucpp;

@:ucppStd
extern class NativeString {
	public static extern inline function nullTerminator(): String {
		return untyped __ucpp__("\"\\0\"");
	}
}
