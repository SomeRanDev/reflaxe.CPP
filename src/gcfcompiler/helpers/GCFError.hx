package gcfcompiler.helpers;

#if (macro || gcf_runtime)

import haxe.macro.Context;
import haxe.macro.Expr;

enum ErrorType {
	CannotCompileNullType;
	DynamicUnsupported;
	OMMIncorrectParamCount;
	ValueSelfRef;
}

class GCFError {
	public static function makeError(pos: Position, err: ErrorType): Dynamic {
		final msg = switch(err) {
			case CannotCompileNullType: {
				"GCFCompiler.compileTypeSafe was passed 'null'. Unknown type detected?";
			}
			case DynamicUnsupported: {
				"Dynamic not supported";
			}
			case OMMIncorrectParamCount: {
				"@:overrideMemoryManagement wrapper does not have exactly one type parameter.";
			}
			case ValueSelfRef: {
				"Types using @:valueType cannot reference themselves. Consider wrapping with SharedPtr<T>.";
			}
			case _: {
				"Unknown error.";
			}
		}
		return Context.error(msg, pos);
	}
}

#end
