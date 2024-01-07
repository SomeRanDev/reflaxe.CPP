#pragma once

#include <memory>
#include <string>

class Test {
public:
	int index;

	Test() {
		index = -1;
	}

	static std::shared_ptr<Test> One() {
		Test result;
		result.index = 0;
		return std::make_shared<Test>(result);
	}

	static std::shared_ptr<Test> Two() {
		Test result;
		result.index = 1;
		return std::make_shared<Test>(result);
	}

	static std::shared_ptr<Test> Three() {
		Test result;
		result.index = 2;
		return std::make_shared<Test>(result);
	}

	static std::shared_ptr<Test> Four() {
		Test result;
		result.index = 3;
		return std::make_shared<Test>(result);
	}

	std::string toString() {
		switch(index) {
			case 0: {
				return std::string("One");
			}
			case 1: {
				return std::string("Two");
			}
			case 2: {
				return std::string("Three");
			}
			case 3: {
				return std::string("Four");
			}
			default: return "";
		}
		return "";
	}

	operator bool() const {
		return true;
	}
};


namespace _Main {

class Main_Fields_ {
public:
	static int returnCode;

	static void assert(bool b);
	static void main();
};

}
