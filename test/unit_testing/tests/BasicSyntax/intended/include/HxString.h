#pragma once

#include <algorithm>
#include <cctype>
#include <deque>
#include <memory>
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
	
	static std::shared_ptr<std::deque<std::string>> split(std::string s, std::string delimiter) {
		if(static_cast<int>(delimiter.size()) <= 0) {
			std::shared_ptr<std::deque<std::string>> result = std::make_shared<std::deque<std::string>>(std::deque<std::string>{});
			int pos = 0;
			int _g = 0;
			int _g1 = static_cast<int>(s.size());
			while(_g < _g1) {
				int i = _g++;
				result->push_back(s.substr(pos++, 1));
			};
			return result;
		};
		
		std::shared_ptr<std::deque<std::string>> result = std::make_shared<std::deque<std::string>>(std::deque<std::string>{});
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
				result->push_back(tempString);
				break;
			} else {
				std::string tempString1;
				if(newPos < 0) {
					tempString1 = s.substr(pos);
				} else {
					tempString1 = s.substr(pos, newPos - pos);
				};
				result->push_back(tempString1);
			};
			pos = newPos + static_cast<int>(delimiter.size());
		};
		
		return result;
	}
};

