#include "StringTools.h"

bool StringTools::startsWith(std::string s, std::string start) {
	return static_cast<int>(s.size()) >= static_cast<int>(start.size()) && s.rfind(start, 0) == 0;
}
