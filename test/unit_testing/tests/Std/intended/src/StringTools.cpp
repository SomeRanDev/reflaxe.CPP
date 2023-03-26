#include "StringTools.h"

bool StringTools::startsWith(std::string s, std::string start) {
	return s.length() >= start.length() && s.rfind(start, 0) == 0;
}
