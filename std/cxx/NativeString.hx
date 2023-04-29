package cxx;

@:cxxStd
extern class NativeString {
	public static extern inline function nullTerminator(): String {
		return untyped __cpp__("\"\\0\"");
	}
}
