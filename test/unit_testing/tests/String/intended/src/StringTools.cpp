#include "StringTools.h"

#include <deque>
#include <memory>
#include <string>
#include "HxArray.h"
#include "HxString.h"
#include "Std.h"

using namespace std::string_literals;

std::string StringTools::htmlEscape(std::string s, std::optional<bool> quotes) {
	std::string buf_b = ""s;
	int _g_offset = 0;
	std::string _g_s = s;
	
	while(_g_offset < (int)(_g_s.size())) {
		int tempNumber;
		
		{
			int tempNumber1;
			{
				std::string s2 = _g_s;
				int index = _g_offset++;
				int tempNumber2;
				if(index < 0 || index >= (int)(s2.size())) {
					tempNumber2 = -1;
				} else {
					tempNumber2 = s2.at(index);
				};
				int c = tempNumber2;
				if(c >= 55296 && c <= 56319) {
					int tempLeft;
					
					{
						int index2 = index + 1;
						if(index2 < 0 || index2 >= (int)(s2.size())) {
							tempLeft = -1;
						} else {
							tempLeft = s2.at(index2);
						};
					};
					
					c = ((c - 55232) << 10) | tempLeft & 1023;
				};
				tempNumber1 = c;
			};
			int c = tempNumber1;
			if(c >= 65536) {
				_g_offset++;
			};
			tempNumber = c;
		};
		
		int code = tempNumber;
		
		switch(code) {
		
			case 34: {
				if(quotes) {
					buf_b += Std::string("&quot;"s);
				} else {
					buf_b += std::string(1, code);
				};
				break;
			}
			case 38: {
				buf_b += Std::string("&amp;"s);
				break;
			}
			case 39: {
				if(quotes) {
					buf_b += Std::string("&#039;"s);
				} else {
					buf_b += std::string(1, code);
				};
				break;
			}
			case 60: {
				buf_b += Std::string("&lt;"s);
				break;
			}
			case 62: {
				buf_b += Std::string("&gt;"s);
				break;
			}
			default: {
				buf_b += std::string(1, code);
				break;
			}
		};
	};
	
	return buf_b;
}

std::string StringTools::htmlUnescape(std::string s) {
	std::string tempResult;
	
	{
		std::shared_ptr<std::deque<std::string>> tempArray;
		{
			std::string tempString;
			{
				std::shared_ptr<std::deque<std::string>> tempArray1;
				{
					std::string tempString1;
					{
						std::shared_ptr<std::deque<std::string>> tempArray2;
						{
							std::string tempString2;
							{
								std::shared_ptr<std::deque<std::string>> tempArray3;
								{
									std::string tempString3;
									{
										std::shared_ptr<std::deque<std::string>> _this = HxString::split(s, "&gt;"s);
										tempString3 = HxArray::join<std::string>(_this, ">"s);
									};
									std::string _this = tempString3;
									tempArray3 = HxString::split(_this, "&lt;"s);
								};
								std::shared_ptr<std::deque<std::string>> _this = tempArray3;
								tempString2 = HxArray::join<std::string>(_this, "<"s);
							};
							std::string _this = tempString2;
							tempArray2 = HxString::split(_this, "&quot;"s);
						};
						std::shared_ptr<std::deque<std::string>> _this = tempArray2;
						tempString1 = HxArray::join<std::string>(_this, "\""s);
					};
					std::string _this = tempString1;
					tempArray1 = HxString::split(_this, "&#039;"s);
				};
				std::shared_ptr<std::deque<std::string>> _this = tempArray1;
				tempString = HxArray::join<std::string>(_this, "'"s);
			};
			std::string _this = tempString;
			tempArray = HxString::split(_this, "&amp;"s);
		};
		std::shared_ptr<std::deque<std::string>> _this = tempArray;
		tempResult = HxArray::join<std::string>(_this, "&"s);
	};
	
	return tempResult;
}

bool StringTools::startsWith(std::string s, std::string start) {
	return s.size() >= start.size() && s.rfind(start, 0) == 0;
}

bool StringTools::endsWith(std::string s, std::string end) {
	int elen = end.size();
	int slen = s.size();
	
	return slen >= elen && s.find(end, slen - elen) == slen - elen;
}

bool StringTools::isSpace(std::string s, int pos) {
	std::optional<int> c = s[pos];
	
	return c.value() > 8 && c.value() < 14 || c == 32;
}

std::string StringTools::ltrim(std::string s) {
	int l = s.size();
	int r = 0;
	
	while(r < l && StringTools::isSpace(s, r)) {
		r++;
	};
	
	if(r > 0) {
		return s.substr(r, l - r);
	} else {
		return s;
	};
}

std::string StringTools::rtrim(std::string s) {
	int l = s.size();
	int r = 0;
	
	while(r < l && StringTools::isSpace(s, l - r - 1)) {
		r++;
	};
	
	if(r > 0) {
		return s.substr(0, l - r);
	} else {
		return s;
	};
}

std::string StringTools::lpad(std::string s, std::string c, int l) {
	if((int)(c.size()) <= 0) {
		return s;
	};
	
	std::string buf_b = ""s;
	
	l -= s.size();
	
	while((int)(buf_b.size()) < l) {
		buf_b += Std::string(c);
	};
	
	buf_b += Std::string(s);
	
	return buf_b;
}

std::string StringTools::rpad(std::string s, std::string c, int l) {
	if((int)(c.size()) <= 0) {
		return s;
	};
	
	std::string buf_b = ""s;
	
	buf_b += Std::string(s);
	
	while((int)(buf_b.size()) < l) {
		buf_b += Std::string(c);
	};
	
	return buf_b;
}

std::string StringTools::replace(std::string s, std::string sub, std::string by) {
	std::shared_ptr<std::deque<std::string>> _this = HxString::split(s, sub);
	std::string tempResult = HxArray::join<std::string>(_this, by);
	
	return tempResult;
}

std::string StringTools::hex(int n, std::optional<int> digits) {
	std::string s = ""s;
	std::string hexChars = "0123456789ABCDEF"s;
	
	do {
		s = std::string(1, hexChars[n & 15]) + s;
		n = static_cast<unsigned int>(n) >> 4;
	} while(n > 0);
	
	if(digits.has_value()) {
		while((int)(s.size()) < digits.value()) {
			s = "0"s + s;
		};
	};
	
	return s;
}
