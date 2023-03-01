#pragma once

#include <string>
#include <vector>

class HxString {
public:
	static std::string toLowerCase(std::string s);
	
	static std::string toUpperCase(std::string s);
	
	static std::vector<std::string> split(std::string s, std::string delimiter);
};

