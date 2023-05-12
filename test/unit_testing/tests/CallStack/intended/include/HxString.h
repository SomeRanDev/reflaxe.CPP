#pragma once

#include <algorithm>
#include <cctype>
#include <deque>
#include <memory>
#include <string>
#include "haxe_NativeStackTrace.h"

class HxString {
public:
	static std::string toLowerCase(std::string s) {
		HCXX_STACK_METHOD(std::string("std/cxx/_std/String.hx"), 10, 2, std::string("HxString"), std::string("toLowerCase"));
		
		HCXX_LINE(11);
		std::string temp = s;
		HCXX_LINE(12);
		std::transform(temp.begin(), temp.end(), temp.begin(), [](unsigned char c){
			return std::tolower(c);
		});
		
		HCXX_LINE(13);
		return temp;
	}
	
	static std::string toUpperCase(std::string s) {
		HCXX_STACK_METHOD(std::string("std/cxx/_std/String.hx"), 16, 2, std::string("HxString"), std::string("toUpperCase"));
		
		HCXX_LINE(17);
		std::string temp = s;
		HCXX_LINE(18);
		std::transform(temp.begin(), temp.end(), temp.begin(), [](unsigned char c){
			return std::toupper(c);
		});
		
		HCXX_LINE(19);
		return temp;
	}
	
	static std::shared_ptr<std::deque<std::string>> split(std::string s, std::string delimiter) {
		HCXX_STACK_METHOD(std::string("std/cxx/_std/String.hx"), 22, 2, std::string("HxString"), std::string("split"));
		
		HCXX_LINE(23);
		if((int)(delimiter.size()) <= 0) {
			HCXX_LINE(24);
			std::shared_ptr<std::deque<std::string>> result = std::make_shared<std::deque<std::string>>(std::deque<std::string>{});
			HCXX_LINE(25);
			int pos = 0;
			HCXX_LINE(26);
			int _g = 0;
			HCXX_LINE(26);
			int _g1 = (int)(s.size());
			
			HCXX_LINE(26);
			while(_g < _g1) {
				HCXX_LINE(26);
				_g++;
				
				HCXX_LINE(27);
				result->push_back(s.substr(pos++, 1));
			};
			
			HCXX_LINE(29);
			return result;
		};
		
		HCXX_LINE(32);
		std::shared_ptr<std::deque<std::string>> result = std::make_shared<std::deque<std::string>>(std::deque<std::string>{});
		HCXX_LINE(33);
		int pos = 0;
		
		HCXX_LINE(34);
		while(true) {
			HCXX_LINE(35);
			int newPos = (int)(s.find(delimiter, (std::size_t)(pos)));
			
			HCXX_LINE(36);
			if(newPos == -1) {
				HCXX_LINE(37);
				std::string tempString;
				HCXX_LINE(37);
				int endIndex = -1;
				
				HCXX_LINE(37);
				if(endIndex < 0) {
					HCXX_LINE(37);
					tempString = s.substr(pos);
				} else {
					HCXX_LINE(37);
					tempString = s.substr(pos, endIndex - pos);
				};
				
				HCXX_LINE(37);
				result->push_back(tempString);
				
				HCXX_LINE(38);
				break;
			} else {
				HCXX_LINE(40);
				std::string tempString1;
				
				HCXX_LINE(40);
				if(newPos < 0) {
					HCXX_LINE(40);
					tempString1 = s.substr(pos);
				} else {
					HCXX_LINE(40);
					tempString1 = s.substr(pos, newPos - pos);
				};
				
				HCXX_LINE(40);
				result->push_back(tempString1);
			};
			
			HCXX_LINE(42);
			pos = (int)(newPos + delimiter.size());
		};
		
		HCXX_LINE(44);
		return result;
	}
};

