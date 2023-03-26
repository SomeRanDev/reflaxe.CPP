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
				std::string tempString;
				if(newPos < 0) {
					tempString = s.substr(pos);
				} else {
					tempString = s.substr(pos, newPos - pos);
				};
				result->push_back(tempString);
			};
			pos = newPos + 1;
		};
		
		return result;
	}
	
	// ----------
	// Auto-generated additions from Haxe
	
	// Generate unique id for each instance
	unsigned long _order_id = 0;
	static unsigned long generate_order_id() { static unsigned long i = 0; return i++; }
	
	// Automatic comparison operators
	bool operator==(const HxString& other) const {
		return _order_id == other._order_id;
	}
	
	bool operator<(const HxString& other) const {
		return _order_id < other._order_id;
	}
};

