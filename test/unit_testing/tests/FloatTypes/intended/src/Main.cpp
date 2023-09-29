#include "Main.h"

#include <cstdlib>

int _Main::Main_Fields_::returnCode = 0;

float _Main::Main_Fields_::getZ() {
	return (float)(3.0f);
}

void _Main::Main_Fields_::main() {
	float x = ((float)(1.0));

	_Main::Main_Fields_::assertIsFloat32<float>(x);

	float y = (float)(2.0f);

	_Main::Main_Fields_::assertIsFloat32<float>(y);

	float z = _Main::Main_Fields_::getZ();

	_Main::Main_Fields_::assertIsFloat32<float>(z);

	float w = x + y + z;

	_Main::Main_Fields_::assertIsFloat32<float>(w);

	float a = w - 2;

	_Main::Main_Fields_::assertIsFloat32<float>(a);

	float b = a * 2;

	_Main::Main_Fields_::assertIsFloat32<float>(b);

	float c = b / 2;

	_Main::Main_Fields_::assertIsFloat32<float>(c);

	float d = --c;

	_Main::Main_Fields_::assertIsFloat32<float>(d);

	float e = ++d;

	_Main::Main_Fields_::assertIsFloat32<float>(e);

	float f = e--;

	_Main::Main_Fields_::assertIsFloat32<float>(f);

	float g = f++;

	_Main::Main_Fields_::assertIsFloat32<float>(g);

	float h = -g;

	_Main::Main_Fields_::assertIsFloat32<float>(h);
	exit(_Main::Main_Fields_::returnCode);
}
