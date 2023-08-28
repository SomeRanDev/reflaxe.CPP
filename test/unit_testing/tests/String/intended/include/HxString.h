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
		if((int)(delimiter.size()) <= 0) {
			std::shared_ptr<std::deque<std::string>> result = std::make_shared<std::deque<std::string>>(std::deque<std::string>{});
			int pos = 0;
			int _g = 0;
			int _g1 = (int)(s.size());

			while(_g < _g1) {
				_g++;

				{
					std::string x = s.substr(pos++, 1);

					result->push_back(x);
				};
			};

			return result;
		};

		std::shared_ptr<std::deque<std::string>> result = std::make_shared<std::deque<std::string>>(std::deque<std::string>{});
		int pos = 0;

		while(true) {
			int newPos = (int)(s.find(delimiter, (std::size_t)(pos)));

			if(newPos == -1) {
				{
					std::string tempString;

					{
						int endIndex = -1;

						if(endIndex < 0) {
							tempString = s.substr(pos);
						} else {
							tempString = s.substr(pos, endIndex - pos);
						};
					};

					std::string x = tempString;

					result->push_back(x);
				};

				break;
			} else {
				std::string tempString1;

				if(newPos < 0) {
					tempString1 = s.substr(pos);
				} else {
					tempString1 = s.substr(pos, newPos - pos);
				};

				std::string x = tempString1;

				result->push_back(x);
			};

			pos = (int)(newPos + delimiter.size());
		};

		return result;
	}
};

