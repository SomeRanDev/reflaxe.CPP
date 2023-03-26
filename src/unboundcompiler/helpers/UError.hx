// =======================================================
// * UError
//
// Where all error messages reside.
// Call "makeError" on any Position.
// =======================================================

package unboundcompiler.helpers;

#if (macro || ucpp_runtime)

import haxe.macro.Context;
import haxe.macro.Expr;

enum ErrorType {
	// General
	CannotCompileNullType;
	DynamicUnsupported;
	OMMIncorrectParamCount;
	ValueSelfRef;

	// Meta
	ConstExprMetaInvalidUse;
	TopLevelInstanceFunction;

	// Memory Management Conversion
	UnsafeToShared;
	UnsafeToUnique;
	SharedToUnique;
	UniqueToShared;
	UniqueToUnique;
	ThisToUnique;
}

class UError {
	public static function makeError(pos: Position, err: ErrorType): Dynamic {
		final msg = switch(err) {
			// General
			case CannotCompileNullType: {
				"UnboundCompiler.compileTypeSafe was passed 'null'. Unknown type detected?";
			}
			case DynamicUnsupported: {
				"Dynamic not supported. Consider using Any or generics instead?";
			}
			case OMMIncorrectParamCount: {
				"@:overrideMemoryManagement wrapper does not have exactly one type parameter.";
			}
			case ValueSelfRef: {
				"Types using @:valueType cannot reference themselves. Consider wrapping with SharedPtr<T>.";
			}

			// Meta
			case ConstExprMetaInvalidUse: {
				"Invalid use of @:constexpr. Must be used with if statement.";
			}
			case TopLevelInstanceFunction: {
				"Invalid use of @:topLevel. Can only be used on static fields.";
			}

			// Memory Management Conversion
			case UnsafeToShared: {
				"Cannot convert unsafe pointer (Ptr<T>) to shared pointer (SharedPtr<T>).";
			}
			case UnsafeToUnique: {
				"Cannot convert unsafe pointer (Ptr<T>) to unique pointer (UniquePtr<T>).";
			}
			case SharedToUnique: {
				"Cannot convert shared pointer (SharedPtr<T>) to unique pointer (UniquePtr<T>).";
			}
			case UniqueToShared: {
				"Cannot move or copy a unique pointer (UniquePtr<T>), so it cannot be converted to shared pointer (SharedPtr<T>).";
			}
			case UniqueToUnique: {
				"Cannot move or copy a unique pointer (UniquePtr<T>).";
			}
			case ThisToUnique: {
				"Cannot convert \"this\" into a unique pointer (UniquePtr<T>). This may trigger from auto-generated code within a class with @:uniquePtrType; if that is the case, consider changing to @:sharedPtrType.";
			}

			case _: {
				"Unknown error.";
			}
		}
		return Context.error(msg, pos);
	}
}

#end
