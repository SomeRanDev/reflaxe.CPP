package haxe;

#if cxx_callstack

import haxe.CallStack.StackItem;

@:valueType
extern class NativeStackItemData {
	public var classname: String;
	public var method: String;

	public var file: String;
	public var line: Int;
	public var col: Int;
}

@:unsafePtrType
extern class NativeStackItem {
	public var data: NativeStackItemData;
	public static function copyStack(): Array<NativeStackItemData>;
}

@:dox(hide)
@:noCompletion
@:headerCode("
#define HCXX_STACK_METHOD(...) \\
	haxe::NativeStackItem ___s(__VA_ARGS__)

#define HCXX_LINE(line_num) \\
	___s.data.line = line_num

namespace haxe {

// Data for the call stack
struct NativeStackItemData {
	std::string classname;
	std::string method;

	std::string file;
	int line;
	int col;
};

// Manages the call stack data
class NativeStackItem {
public:
	NativeStackItemData data;

	// Generate an item at the start of a function
	NativeStackItem(std::string file, int line, int col, std::string classname, std::string method) {
		data.file = file;
		data.line = line;
		data.col = col;
		data.classname = classname;
		data.method = method;

		// Do not copy by value, use pointers to avoid multiple destructions
		getStack()->push_front(this);
	}

	// Once this object goes out of scope (the function is complete),
	// it removes itself from the static list.
	~NativeStackItem() {
		getStack()->pop_front();
	}

	// Hack to use static variable in header only class
	static std::shared_ptr<std::deque<NativeStackItem*>> getStack() {
		static auto stack = std::make_shared<std::deque<NativeStackItem*>>();
		return stack;
	}

	// Copy the data specifically (so copy/destruction doesn't occur on manager object)
	static std::shared_ptr<std::deque<NativeStackItemData>> copyStack() {
		auto result = std::make_shared<std::deque<NativeStackItemData>>();
		for(auto& item : *getStack()) {
			result->push_back(item->data);
		}
		return result;
	}
};

}
")
@:headerInclude("deque", true)
@:headerInclude("string", true)
class NativeStackTrace {
	@:noCallstack
	public static function saveStack(exception: Any): Void {
	}

	@:noCallstack
	public static function callStack(): Array<NativeStackItemData> {
		return NativeStackItem.copyStack();
	}

	@:noCallstack
	public static function exceptionStack(): Array<NativeStackItemData> {
		return NativeStackItem.copyStack();
	}

	@:noCallstack
	public static function toHaxe(nativeStackTrace: Array<NativeStackItemData>, skip: Int = 0): Array<StackItem> {
		final result = [];

		for(i in 0...nativeStackTrace.length) {
			if(i <= skip) {
				continue;
			}
			final item = nativeStackTrace[i];
			result.push(FilePos(Method(item.classname, item.method), item.file, item.line, item.col));
		}

		return result;

	}
}

#else

@:dox(hide)
@:noCompletion
extern class NativeStackTrace {
	public static inline extern function saveStack(exception: Any): Void {}
	public static inline extern function callStack(): Array<Any> { err(); return []; }
	public static inline extern function exceptionStack(): Array<Any> { err(); return []; }
	public static inline extern function toHaxe(nativeStackTrace: Array<Any>, skip: Int = 0): Array<haxe.CallStack.StackItem> { err(); return []; }

	static inline extern function err() Sys.println("Call stack features must be enabled using -D cxx_callstack.");
}

#end
