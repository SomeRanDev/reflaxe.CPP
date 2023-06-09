#pragma once

#include <optional>
#include <string>

class StringTools {
public:
	static std::string htmlEscape(std::string s, std::optional<bool> quotes = std::nullopt);
	static std::string htmlUnescape(std::string s);
	static bool startsWith(std::string s, std::string start);
	static bool endsWith(std::string s, std::string end);
	static bool isSpace(std::string s, int pos);
	static std::string ltrim(std::string s);
	static std::string rtrim(std::string s);
	static std::string lpad(std::string s, std::string c, int l);
	static std::string rpad(std::string s, std::string c, int l);
	static std::string replace(std::string s, std::string sub, std::string by);
	static std::string hex(int n, std::optional<int> digits = std::nullopt);
};

