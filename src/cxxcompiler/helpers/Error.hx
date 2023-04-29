// =======================================================
// * Error
//
// Where all error messages reside.
// Call "makeError" on any Position.
// =======================================================

package cxxcompiler.helpers;

#if (macro || cxx_runtime)

import reflaxe.helpers.Context;
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
	TopLevelConstructor;
	MainPrependOnNonStatic;
	MainPrependWrongArguments;

	// Memory Management Conversion
	UnsafeToShared;
	UnsafeToUnique;
	SharedToUnique;
	UniqueToShared;
	UniqueToUnique;
	ThisToUnique;
}

class Error {
	public static function makeError(pos: Position, err: ErrorType): Dynamic {
		final msg = switch(err) {
			// General
			case CannotCompileNullType: {
				"Compiler.compileTypeSafe was passed 'null'. Unknown type detected?";
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
			case TopLevelConstructor: {
				"Invalid use of @:topLevel. Cannot be used on constructors.";
			}
			case MainPrependOnNonStatic: {
				"@:prependToMain must be used on static function.";
			}
			case MainPrependWrongArguments: {
				"Functions with @:prependToMain must either have no required arguments or the first two must match (Int, cxx.CArray<cxx.ConstCharPtr>).";
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
