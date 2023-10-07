# Use `--macro cxx.CMake.removeComments()` to remove the generated comments.
# NOTE: they will also remove themselves if you use their suggested --macro call.

# Add additional lines using `--macro cxx.CMake.add("some_cmake_code()")`.
# The lines guaranteed to be in the same order they are added.
# An optional index can be provided to set their position; for example `0` will add the line to the top.

# There is no specific reason for 3.27 being the default; it is simply the latest version at the time of writing this.
# Feel free to modify using `--macro cxx.CMake.setMinimumRequired("your version string")`.
cmake_minimum_required(VERSION 3.27)

# Change project name using `--macro cxx.CMake.setProjectName("MyCoolProject")`.
# Change project version using `--macro cxx.CMake.setProjectVersion("2.34")`.
project(UntitledHaxeProject VERSION 1.0 LANGUAGES CXX)

# Add include directories using `--macro cxx.CMake.addIncludeDirectory("path/to/dir")`.
# Alternatively, use `--macro cxx.Compiler.addCppDirectory("path/to/dir")` to copy header files to the "include" folder.
include_directories(include)

add_executable(
	# Change title using `--macro cxx.CMake.setExecutableName("MyCoolProgram")`.
	Untitled

	# Add source files using `--macro cxx.CMake.addSourceFile("path/to/file")`.
	# Alternatively, use `--macro cxx.Compiler.addCppDirectory("path/to/dir")` to copy source files to the "src" folder.
	src/Main.cpp
	src/_main_.cpp
)
