#include "StringTools.h"

bool StringTools::startsWith(std::string s, std::string start) {
	return s.size() >= start.size() && s.rfind(start, 0) == 0;
}
