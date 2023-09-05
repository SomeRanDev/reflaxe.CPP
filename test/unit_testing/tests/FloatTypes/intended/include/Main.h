#pragma once

namespace _Main {

class Main_Fields_ {
public:
	static int returnCode;

	template<typename T>
	static void assertIsFloat32(T v) {
		if(sizeof(v) != 4) {
			_Main::Main_Fields_::returnCode = 1;
		};
	}
	static float getZ();
	static void main();
};

}
