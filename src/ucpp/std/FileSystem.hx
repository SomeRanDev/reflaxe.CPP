package ucpp.std;

@:native("std::filesystem")
@:include("filesystem", true)
@:valueType
extern class FileSystem {
	@:native("std::filesystem::current_path")
	@:include("filesystem", true)
	public static extern function currentPath(): FileSystem;

	public extern inline function toString(): ucpp.DynamicToString {
		return new ucpp.DynamicToString(this);
	}
}
