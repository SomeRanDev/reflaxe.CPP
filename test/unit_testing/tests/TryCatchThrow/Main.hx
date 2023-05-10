package;

function main() {
	function assert(b: Bool) {
		if(!b) {
			Sys.println("Assert failed");
			Sys.exit(1);
		}
	}

	// Catch Haxe errors
	final msg = "a message";
	try {
		throw msg;
	} catch(e) {
		assert(e.message == msg);
	}

	try {
		throw new haxe.Exception(msg);
	} catch(e) {
		assert(e.message == msg);
	}

	// Catch native C++ errors
	try {
		untyped __include__("stdexcept", true);
		throw untyped __cpp__("std::runtime_error(\"test\")");
	} catch(e: cxx.std.Exception) {
		assert(e.what().toString() == "test");
	}
}
