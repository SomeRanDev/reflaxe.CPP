package haxe;

@:cxxStd
@:coreApi
@:valueType
class Exception extends cxx.std.Exception {
	public var message(get, never): String;
	private function get_message(): String {
		return "";
	}

	public var stack(get, never): CallStack;
	private function get_stack(): CallStack {
		return [];
	}

	public var previous(get, never): Null<Exception>;
	private function get_previous(): Null<Exception> {
		return null;
	}

	public var native(get, never): Any;
	final private function get_native(): Any {
		return 0;
	}

	static private function caught(value: Any): Exception {
		return new Exception("Unimplemented.");
	}

	static private function thrown(value: Any): Any {
		return 0;
	}

	public function new(message: String, ?previous: Exception, ?native: Any): Void {
		super();
	}

	private function unwrap(): Any {
		return 0;
	}

	public function toString(): String {
		return "";
	}

	public function details(): String {
		return "";
	}
}
