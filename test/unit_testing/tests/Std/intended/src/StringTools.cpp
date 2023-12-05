#include "StringTools.h"

#include <string>

bool StringTools::startsWith(std::string s, std::string start) {
	return (s.size() >= start.size()) && ((int)(s.rfind(start, (std::size_t)(0))) == 0);
}
