#pragma once

#include <algorithm>
#include <cctype>
#include <deque>
#include <string>

class HxString {
public:
	static std::string toLowerCase(std::string s) {
		std::string temp = s;
		std::transform(temp.begin(), temp.end(), temp.begin(), [](unsigned char c){
			return std::tolower(c);
		});
		
		return temp;
	}
	
	static std::string toUpperCase(std::string s) {
		std::string temp = s;
		std::transform(temp.begin(), temp.end(), temp.begin(), [](unsigned char c){
			return std::toupper(c);
		});
		
		return temp;
	}
	
	static std::deque<std::string> split(std::string s, std::string delimiter) {
		std::deque<std::string> result = std::deque<std::string>{};
		int pos = 0;
		
		while(true) {
			int newPos = s.find(delimiter, pos);
			if(newPos == -1) {
				std::string tempString;
				int endIndex = -1;
				if(endIndex < 0) {
					tempString = s.substr(pos);
				} else {
					tempString = s.substr(pos, endIndex - pos);
				};
				result.push_back(tempString);
				break;
			} else {
				std::string tempString;
				if(newPos < 0) {
					tempString = s.substr(pos);
				} else {
					tempString = s.substr(pos, newPos - pos);
				};
				result.push_back(tempString);
			};
			pos = newPos + 1;
		};
		
		return result;
	}
};

