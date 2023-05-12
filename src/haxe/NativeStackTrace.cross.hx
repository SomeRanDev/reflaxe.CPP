package haxe;

#if cxx_callstack

import haxe.CallStack.StackItem;

@:unsafePtrType
extern class NativeStackItem {
	public var type: Int;
	public var data: String;

	public var file: String;
	public var line: Int;
	public var col: Int;

	public static function getStack(): Array<cxx.Ptr<NativeStackItem>>;
}

@:dox(hide)
@:noCompletion
@:headerCode("
#define HCXX_STACK_METHOD(...) \\
	auto ___s = haxe::NativeStackItem::method(__VA_ARGS__)

#define HCXX_LINE(line_num) \\
	___s.line = line_num

namespace haxe {

class NativeStackItem {
public:
	std::string data;
	int type;

	std::string file;
	int line;
	int col;

	NativeStackItem(int type, std::string file, int line, int col, std::string data):
		data(data), type(type), file(file), line(line), col(col)
	{
		getStack()->push_back(this);
	}

	~NativeStackItem() {
		getStack()->pop_back();
	}

	static std::shared_ptr<std::deque<NativeStackItem*>> getStack() {
		static auto stack = std::make_shared<std::deque<NativeStackItem*>>();
		return stack;
	}

	static NativeStackItem method(std::string file, int line, int col, std::string classname, std::string method) {
		return NativeStackItem(0, file, line, col, classname + \"::\" + method);
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
	public static function callStack(): Array<NativeStackItem> {
		return NativeStackItem.getStack();
	}

	@:noCallstack
	public static function exceptionStack(): Array<NativeStackItem> {
		return NativeStackItem.getStack();
	}

	@:noCallstack
	public static function toHaxe(nativeStackTrace: Array<NativeStackItem>, skip: Int = 0): Array<StackItem> {
		final result = [];

		for(i in 0...nativeStackTrace.length) {
			if(i <= skip) {
				continue;
			}
			final item = nativeStackTrace[i];
			switch(item.type) {
				case 0: {
					final str = item.data.split("::");
					result.push(FilePos(Method(str[0], str[1]), item.file, item.line, item.col));
				}
				case _: {
					result.push(CFunction);
				}
			}
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
