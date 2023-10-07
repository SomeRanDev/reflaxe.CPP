package cxx;

#if (macro || display)

import sys.FileSystem;

/**
	A macro-only class used for CMake configuration.

	A `CMakeLists.txt` file will be generated in the output
	folder if `-D cmake` is defined.

	The file's name and location can be modified with the
	define's value: `-D cmake=build/CMakeLists.txt`.
**/
@:cxxStd
class CMake {
	static final DEFAULT_MINIMUM_REQUIRED = "3.27";
	static final DEFAULT_PROJECT_NAME = "UntitledHaxeProject";
	static final DEFAULT_PROJECT_VERSION = "1.0";
	static final DEFAULT_EXECUTABLE_NAME = "Untitled";

	static var enabled: Bool = false;
	static var outputPath: Null<String> = null;
	static var addComments: Bool = true;

	static var minimumRequired: Null<String> = null;
	static var projectName: Null<String> = null;
	static var projectVersion: Null<String> = null;
	static var executableName: Null<String> = null;

	static var additionalIncludeDirectories: Array<String> = [];
	static var additionalSourceFiles: Array<String> = [];

	/**
		Stores the CMakeLists lines.
		Feel free to modify this array directly.

		The entries in <triangle brackets> are macros that will be replaced
		with automatically generated content.
	**/
	public static var lines = [
		"<MINIMUM_REQUIRED>",
		"<PROJECT>",
		"<INCLUDE_DIRS>",
		"<ADD_EXECUTABLE>"
	];

	/**
		Alternative method to enable CMake.
	**/
	public static function enable() {
		enabled = true;
	}

	/**
		Checks if CMake has been manually enabled or `-D cmake` is defined.
	**/
	public static function isEnabled() {
		return enabled || haxe.macro.Context.defined("cmake");
	}

	/**
		Returns the CMakeLists.txt path relative to the Reflaxe/C++ output path.
	**/
	public static function getOutputPath(): String {
		var path = haxe.macro.Context.definedValue("cmake");
		if(path == "1") {
			path = "CMakeLists.txt";
		}
		return path;
	}

	/**
		Adds content to the `CMakeLists.txt` file.
		It can be one or multiple lines.

		If `index` is defined, it will determine the position the content will
		be added to in the `lines` array. Negative values can be used to add
		relative to the end.
	**/
	public static function add(content: String, index: Null<Int> = null): Void {
		if(index == null) {
			lines.push(content);
		} else {
			if(Math.abs(index) > lines.length) {
				throw "Invalid index: " + index;
			}

			lines.insert(index, content);
		}
	}

	/**
		Removes all the automatically generated comments from `CMakeLists.txt`.
	**/
	public static function removeComments(): Void {
		addComments = false;
	}

	public static function setMinimumRequired(versionString: String): Void
		minimumRequired = versionString;

	public static function setProjectName(name: String): Void
		projectName = name;

	public static function setProjectVersion(versionString: String): Void
		projectVersion = versionString;

	public static function setExecutableName(name: String): Void
		executableName = name;

	public static function addIncludeDirectory(includeDirectory: String): Void
		additionalIncludeDirectories.push(includeDirectory);

	public static function addSourceFile(sourceFile: String): Void
		additionalSourceFiles.push(sourceFile);

	/**
		Generates the content for `CMakeLists.txt`.
	**/
	public static function generateCMakeLists(sourceFiles: Array<String>): String {
		final result = [];

		/**
			Header comment.
		**/
		if(addComments) {
			result.push(
"# Use `--macro cxx.CMake.removeComments()` to remove the generated comments.
# NOTE: they will also remove themselves if you use their suggested --macro call.

# Add additional lines using `--macro cxx.CMake.add(\"some_cmake_code()\")`.
# The lines guaranteed to be in the same order they are added.
# An optional index can be provided to set their position; for example `0` will add the line to the top.
"
			);
		}

		/**
			Process `lines`.
		**/
		for(line in lines) switch(line) {
			/**
				<MINIMUM_REQUIRED>

				Adds the `cmake_minimum_required`.
			**/
			case "<MINIMUM_REQUIRED>": {
				if(addComments && minimumRequired == null) {
					result.push(
'# There is no specific reason for $DEFAULT_MINIMUM_REQUIRED being the default; it is simply the latest version at the time of writing this.
# Feel free to modify using `--macro cxx.CMake.setMinimumRequired(\"your version string\")`.'
					);
				}

				result.push('cmake_minimum_required(VERSION ${minimumRequired ?? DEFAULT_MINIMUM_REQUIRED})\n');
			}

			/**
				<PROJECT>

				Adds the `project`.
			**/
			case "<PROJECT>": {
				if(addComments) {
					if(projectName == null) {
						result.push("# Change project name using `--macro cxx.CMake.setProjectName(\"MyCoolProject\")`.");
					}
					if(projectVersion == null) {
						result.push("# Change project version using `--macro cxx.CMake.setProjectVersion(\"2.34\")`.");
					}
				}

				result.push('project(${projectName ?? DEFAULT_PROJECT_NAME} VERSION ${projectVersion ?? DEFAULT_PROJECT_VERSION} LANGUAGES CXX)\n');
			}

			/**
				<INCLUDE_DIRS>

				Adds the `include_directories`.
			**/
			case "<INCLUDE_DIRS>": {
				if(addComments && additionalIncludeDirectories.length == 0) {
					result.push(
"# Add include directories using `--macro cxx.CMake.addIncludeDirectory(\"path/to/dir\")`.
# Alternatively, use `--macro cxx.Compiler.addCppDirectory(\"path/to/dir\")` to copy header files to the \"include\" folder."
					);
				}

				result.push("include_directories(include)\n");
			}

			/**
				<ADD_EXECUTABLE>

				Adds the `add_executable`.
			**/
			case "<ADD_EXECUTABLE>": {
				result.push("add_executable(");
				if(addComments && executableName == null) {
					result.push("\t# Change title using `--macro cxx.CMake.setExecutableName(\"MyCoolProgram\")`.");
				}
				result.push('\t${executableName ?? DEFAULT_EXECUTABLE_NAME}');
				result.push("");
				if(addComments && additionalSourceFiles.length == 0) {
					result.push(
"\t# Add source files using `--macro cxx.CMake.addSourceFile(\"path/to/file\")`.
\t# Alternatively, use `--macro cxx.Compiler.addCppDirectory(\"path/to/dir\")` to copy source files to the \"src\" folder."
					);
				}
				for(s in sourceFiles) {
					result.push('\t$s');
				}
				result.push(")\n");
			}

			/**
				Any other line was added by the user and should be generated normally.
			**/
			case l: result.push(l);
		}

		/**
			Generate file by putting lines together.
		**/
		return result.join("\n");
	}
}

#end
