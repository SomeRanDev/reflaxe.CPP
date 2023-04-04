#pragma once

#include <deque>
#include <functional>
#include <memory>
#include <optional>
#include <regex>
#include <string>
#include "_AnonStructs.h"
#include "_HaxeUtils.h"

class EReg {
public:
	std::regex regex;
	
	std::smatch smatch;
	
	std::optional<std::shared_ptr<std::deque<std::string>>> matches;
	
	std::optional<std::string> left;
	
	std::optional<std::string> right;
	
	int matchPos;
	
	int matchLen;
	
	bool isGlobal;
	
	static EReg escapeRegExpRe;

	EReg(std::string r, std::string opt);
	
	bool match(std::string s);
	
	std::string matched(int n);
	
	std::string matchedLeft();
	
	std::string matchedRight();
	
	std::shared_ptr<haxe::AnonStruct0> matchedPos();
	
	bool matchSub(std::string s, int pos, int len = -1);
	
	std::shared_ptr<std::deque<std::string>> split(std::string s);
	
	std::string replace(std::string s, std::string by);
	
	std::string map(std::string s, std::function<std::string(EReg)> f);
	
	static std::string escape(std::string s);
	
	HX_COMPARISON_OPERATORS(EReg)
};

