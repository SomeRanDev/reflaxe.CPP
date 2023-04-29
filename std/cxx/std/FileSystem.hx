package cxx.std;

@:cxxStd
@:native("std::filesystem")
@:include("filesystem", true)
@:valueType
extern class FileSystem {
	@:native("std::filesystem::current_path")
	@:include("filesystem", true)
	public static overload extern function currentPath(): Path;

	@:native("std::filesystem::current_path")
	@:include("filesystem", true)
	public static overload extern function currentPath(newPath: Path): Path;

	@:native("std::filesystem::current_path")
	@:include("filesystem", true)
	public static overload extern function currentPath(newPath: String): Path;
}

@:native("std::filesystem::path")
@:include("filesystem", true)
@:valueType
extern class Path {
	public function new(s: String);

	@:const public function string(): String;

	public function concat(p: Path): Path;

	public function clear(): Void;
	public function make_preferred(): cxx.Ref<Path>;
	public function remove_filename(): cxx.Ref<Path>;

	@:const public function root_name(): Path;
	@:const public function root_directory(): Path;
	@:const public function root_path(): Path;
	@:const public function relative_path(): Path;
	@:const public function parent_path(): Path;
	@:const public function filename(): Path;
	@:const public function stem(): Path;
}
