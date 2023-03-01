#include "HxString.h"

#include <algorithm>
#include <cctype>

std::string HxString::toLowerCase(std::string s) {
	std::string temp = s;
	std::transform(temp.begin(), temp.end(), temp.begin(), [](unsigned char c){
		return std::tolower(c);
	});
	
	return temp;
}

std::string HxString::toUpperCase(std::string s) {
	std::string temp = s;
	std::transform(temp.begin(), temp.end(), temp.begin(), [](unsigned char c){
		return std::toupper(c);
	});
	
	return temp;
}

std::vector<std::string> HxString::split(std::string s, std::string delimiter) {
	std::vector<std::string> result = {};
	int pos = 0;
	
	while(true) {
		int newPos = s.find(delimiter, pos);
		if(newPos == -1) {
			std::string tempStdstring;
			int endIndex = -1;
			if(endIndex < 0) {
				tempStdstring = s.substr(pos);
			} else {
				tempStdstring = s.substr(pos, endIndex - pos);
			};
			result.push_back(tempStdstring);
			break;
		} else {
			std::string tempStdstring;
			if(newPos < 0) {
				tempStdstring = s.substr(pos);
			} else {
				tempStdstring = s.substr(pos, newPos - pos);
			};
			result.push_back(tempStdstring);
		};
		pos = newPos + 1;
	};
	
	return result;
}
