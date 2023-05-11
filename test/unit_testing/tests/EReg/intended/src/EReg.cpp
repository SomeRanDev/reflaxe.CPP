#include "EReg.h"

#include <deque>
#include <functional>
#include <memory>
#include <regex>
#include <string>
#include "_AnonStructs.h"
#include "HxString.h"
#include "Std.h"

using namespace std::string_literals;

EReg EReg::escapeRegExpRe = EReg("[\\[\\]{}()*+?.\\\\\\^$|]"s, "g"s);

EReg::EReg(std::string r, std::string opt): _order_id(generate_order_id()) {
	this->regex = std::regex(r, std::regex::ECMAScript | std::regex::icase);
	this->smatch = std::smatch();
	this->originalString = r;
	this->originalOptions = opt;
	this->matches = std::nullopt;
	this->left = std::nullopt;
	this->right = std::nullopt;
	this->matchPos = 0;
	this->matchLen = 0;
	this->isGlobal = opt.find("g"s) != -1;
}

std::string EReg::toString() {
	return "~/"s + this->originalString + "/"s + this->originalOptions;
}

bool EReg::match(std::string s) {
	bool result = std::regex_search(s, this->smatch, this->regex);
	
	if(result) {
		this->left = this->smatch.prefix();
		this->right = this->smatch.suffix();
		this->matchPos = this->smatch.position();
		this->matchLen = this->smatch.length();
		this->matches = std::make_shared<std::deque<std::string>>(std::deque<std::string>{});
		
		int _g = 0;
		int _g1 = this->smatch.size();
		
		while(_g < _g1) {
			int i = _g++;
			
			this->matches.value()->push_back(this->smatch.str(i));
		};
	};
	
	return result;
}

std::string EReg::matched(int n) {
	if(!this->matches.has_value()) {
		return ""s;
	};
	if(n < 0 || (unsigned int)(n) >= this->matches.value()->size()) {
		return ""s;
	};
	
	return (*this->matches.value())[n];
}

std::string EReg::matchedLeft() {
	if(!this->left.has_value()) {
		return ""s;
	};
	
	return this->left.value();
}

std::string EReg::matchedRight() {
	if(!this->right.has_value()) {
		return ""s;
	};
	
	return this->right.value();
}

std::shared_ptr<haxe::AnonStruct0> EReg::matchedPos() {
	return haxe::shared_anon<haxe::AnonStruct0>(this->matchLen, this->matchPos);
}

bool EReg::matchSub(std::string s, int pos, int len) {
	bool result = this->match(s.substr(pos, len));
	
	if(result) {
		this->matchPos += pos;
		this->left = s.substr(0, this->matchPos);
		this->right = s.substr(this->matchPos + this->matchLen);
	};
	
	return result;
}

std::shared_ptr<std::deque<std::string>> EReg::split(std::string s) {
	if(s.size() <= (unsigned int)(0)) {
		return std::make_shared<std::deque<std::string>>(std::deque<std::string>{ s });
	};
	
	std::shared_ptr<std::deque<std::string>> result = std::make_shared<std::deque<std::string>>(std::deque<std::string>{});
	int index = 0;
	
	while(true) {
		if(this->matchSub(s, index, -1)) {
			std::shared_ptr<haxe::AnonStruct0> pos = this->matchedPos();
			std::string tempString;
			
			{
				int endIndex = pos->pos;
				if(endIndex < 0) {
					tempString = s.substr(index);
				} else {
					tempString = s.substr(index, endIndex - index);
				};
			};
			
			result->push_back(tempString);
			
			if(pos->pos + pos->len <= index) {
				break;
			};
			
			index = pos->pos + pos->len;
			
			if((unsigned int)(index) >= s.size()) {
				break;
			};
		} else {
			std::string tempString1;
			
			{
				int endIndex = -1;
				if(endIndex < 0) {
					tempString1 = s.substr(index);
				} else {
					tempString1 = s.substr(index, endIndex - index);
				};
			};
			
			result->push_back(tempString1);
			
			break;
		};
	};
	
	return result;
}

std::string EReg::replace(std::string s, std::string by) {
	std::string b_b = ""s;
	int pos = 0;
	int len = s.size();
	std::shared_ptr<std::deque<std::string>> a = HxString::split(by, "$"s);
	bool first = true;
	
	do {
		if(!this->matchSub(s, pos, len)) {
			break;
		};
		
		std::shared_ptr<haxe::AnonStruct0> p = this->matchedPos();
		
		if(p->len == 0 && !first) {
			if((unsigned int)(p->pos) == s.size()) {
				break;
			};
			
			p->pos += 1;
		};
		
		std::optional<int> len1 = p->pos - pos;
		std::string tempRight;
		
		if(!len1.has_value()) {
			tempRight = s.substr(pos);
		} else {
			tempRight = s.substr(pos, len1.value());
		};
		
		b_b += tempRight;
		
		if(a->size() > (unsigned int)(0)) {
			b_b += Std::string((*a)[0]);
		};
		
		int i = 1;
		
		while((unsigned int)(i) < a->size()) {
			std::string k = (*a)[i];
			std::optional<int> c = k[0];
			
			if(c.value() >= 49 && c.value() <= 57) {
				std::optional<std::string> tempMaybeString;
				int tempLeft;
				double x = c.value();
				
				tempLeft = ((int)(x));
				
				int matchIndex = tempLeft - 48;
				
				if(this->matches.has_value() && (unsigned int)(matchIndex) < this->matches.value()->size()) {
					tempMaybeString = (*this->matches.value())[matchIndex];
				} else {
					tempMaybeString = std::nullopt;
				};
				
				std::optional<std::optional<std::string>> matchReplace = tempMaybeString;
				
				if(!matchReplace.has_value()) {
					b_b += Std::string("$"s);
					b_b += Std::string(k);
				} else {
					b_b += Std::string(matchReplace);
					
					std::optional<int> len2 = k.size() - 1;
					std::string tempRight1;
					
					if(!len2.has_value()) {
						tempRight1 = k.substr(1);
					} else {
						tempRight1 = k.substr(1, len2.value());
					};
					
					b_b += tempRight1;
				};
			} else if(!c.has_value()) {
				b_b += Std::string("$"s);
				i++;
				
				std::string k2 = (*a)[i];
				
				if(true && k2.size() > (unsigned int)(0)) {
					b_b += Std::string(k2);
				};
			} else {
				b_b += Std::string("$"s + k);
			};
			
			i++;
		};
		
		int tot = p->pos + p->len - pos;
		
		pos += tot;
		len -= tot;
		first = false;
	} while(this->isGlobal);
	
	std::string tempRight2 = s.substr(pos, len);
	
	b_b += tempRight2;
	
	return b_b;
}

std::string EReg::map(std::string s, std::function<std::string(EReg)> f) {
	int offset = 0;
	std::string buf_b = ""s;
	
	do {
		if((unsigned int)(offset) >= s.size()) {
			break;
		} else if(!this->matchSub(s, offset, -1)) {
			{
				std::string x = s.substr(offset);
				buf_b += Std::string(x);
			};
			
			break;
		};
		
		std::shared_ptr<haxe::AnonStruct0> p = this->matchedPos();
		
		{
			std::string x = s.substr(offset, p->pos - offset);
			buf_b += Std::string(x);
		};
		{
			std::string x = f((*this));
			buf_b += Std::string(x);
		};
		
		if(p->len == 0) {
			{
				std::string x = s.substr(p->pos, 1);
				buf_b += Std::string(x);
			};
			
			offset = p->pos + 1;
		} else {
			offset = p->pos + p->len;
		};
	} while(this->isGlobal);
	
	if(!this->isGlobal && offset > 0 && (unsigned int)(offset) < s.size()) {
		std::string x = s.substr(offset);
		
		buf_b += Std::string(x);
	};
	
	return buf_b;
}

std::string EReg::escape(std::string s) {
	return EReg::escapeRegExpRe.map(s, [&](EReg r) mutable {
		return "\\"s + r.matched(0);
	});
}
