package;

import cxx.num.Float32;

var returnCode = 0;
function assertIsFloat32<T: cxx.num.Float32>(v: T) {
	if(untyped __cpp__("sizeof({0}) != 4", v)) {
		returnCode = 1;
	}
}

function getZ() : Float32 {
    return 3.0;
}

function main() {
    final x = cast(1.0, Float32);
    assertIsFloat32(x);

    final y: Float32 = 2.0;
    assertIsFloat32(y);

    final z = getZ();
    assertIsFloat32(z);

    final w = x + y + z;
    assertIsFloat32(w);

    final a = w - 2;
    assertIsFloat32(a);

    final b = a * 2;
    assertIsFloat32(b);

    var c = b / 2;
    assertIsFloat32(c);

    var d = --c;
    assertIsFloat32(d);

    var e = ++d;
    assertIsFloat32(e);

    var f = e--;
    assertIsFloat32(f);

    final g = f++;
    assertIsFloat32(g);

    final h = -g;
    assertIsFloat32(h);

	Sys.exit(returnCode);
}
