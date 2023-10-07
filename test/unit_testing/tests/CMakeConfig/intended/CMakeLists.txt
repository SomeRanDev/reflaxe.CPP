cmake_minimum_required(VERSION 3.27)

project(CMakeConfig VERSION 4.56 LANGUAGES CXX)

include_directories(include)

add_executable(
	CMakeExecutable

	src/Main.cpp
	src/_main_.cpp
)
