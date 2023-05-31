package haxe;

@:cxxStd
@:haxeStd
@:coreApi
@:valueType
class Exception extends cxx.std.Exception {
	public var message(get, never): String;
	private function get_message(): String {
		return _message;
	}

	public var stack(get, never): CallStack;
	private function get_stack(): CallStack {
		#if cxx_callstack
		return _stack;
		#else
		NativeStackTrace.err();
		return [];
		#end
	}

	public var previous(get, never): Null<Exception>;
	private function get_previous(): Null<Exception> {
		return _previous;
	}

	public var native(get, never): Any;
	final private function get_native(): Any {
		return 0;
	}

	// ---

	static private function caught(value: Any): Exception {
		return new Exception(Std.string(value));
	}

	static private function thrown(value: Any): Any {
		return 0;
	}

	// ---

	var _message: String;
	var _previous: Null<cxx.SharedPtr<Exception>>;
	#if cxx_callstack
	var _stack: CallStack;
	#end

	public function new(message: String, ?previous: Exception, ?native: Any): Void {
		super();

		_message = message;
		_previous = previous != null ? cxx.SharedPtr.make((previous : Exception)) : null;
		#if cxx_callstack
		_stack = NativeStackTrace.toHaxe(NativeStackTrace.callStack());
		#end
	}

	private function unwrap(): Any {
		return 0;
	}

	public function toString(): String {
		return 'Error: $message';
	}

	public function details(): String {
		return toString() + "\n" + haxe.CallStack.toString(stack);
	}
}
