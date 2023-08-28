// =======================================================
// * Error
//
// All error messages are documented and reported here.
// Call `makeError` or `makeWarning` on any Position.
// =======================================================

package cxxcompiler.helpers;

#if (macro || cxx_runtime)

import haxe.macro.Expr;
import reflaxe.helpers.Context;
import cxxcompiler.config.Define;

/**
	An enum containing all the possible warnings
	for Reflaxe/C++ to report.
**/
enum WarningType {
	// General
	UsedNullOnNonNullable;
}

/**
	An enum containing all the possible errors
	for Reflaxe/C++ to report.
**/
enum ErrorType {
	// General
	CouldNotCompileType(t: Null<haxe.macro.Type>);
	CannotCompileNullType;
	DynamicUnsupported;
	OMMIncorrectParamCount;
	ValueSelfRef;
	ValueAssignedNull;
	InfiniteReference(stackDetails: String);
	InitializedTypeRequiresValue;
	CovarianceRequiresPtrLikeType;
	NoSuperWithoutSuperClass;

	// Disabled Features
	DisallowedHaxeStd;
	DisallowedSmartPointers;
	DisallowedDynamic;
	DisallowedSmartPointerTypeName(typeString: String);
	DisallowedSmartPointerAnonymous(type: haxe.macro.Type);
	NoStringAddWOHaxeStd;

	// Meta
	UncompilableType(t: Null<haxe.macro.Type>);
	UncompilableField;
	CannotUseOnExternClass;
	ConstExprMetaInvalidUse;
	ConstExprIncompatibleWithConst;
	TopLevelInstanceFunction;
	TopLevelConstructor;
	MainPrependOnNonStatic;
	MainPrependWrongArguments;
	InvalidCStr;
	InvalidAlloc;
	UnsupportedRequireMMT;
	InvalidPassConstTypeParam;
	InvalidPassConstTypeParamIndex;
	PassConstTypeParamIndexOutsideRange;
	DuplicatePassConstTypeParam;

	// Memory Management Conversion
	UnsafeToShared;
	UnsafeToUnique;
	SharedToUnique;
	UniqueToShared;
	UniqueToUnique;
	ThisToUnique;
}

class Error {
	/**
		Print one of the preset warnings for Reflaxe/C++.
	**/
	public static function makeWarning(pos: Position, warn: WarningType) {
		final msg = switch(warn) {
			case UsedNullOnNonNullable: {
				"`null` assigned to a type not wrapped with `Null<T>`. This will generate unsafe C++. Disable this warning with `-D " + Define.NoNullAssignWarnings + "`.";
			}

			case _: {
				"Unknown warning.";
			}
		}

		Context.warning(msg, pos);
	}

	/**
		Print one of the preset errors for Reflaxe/C++.
	**/
	public static function makeError(pos: Position, err: ErrorType): Dynamic {
		final msg = switch(err) {
			// General
			case CouldNotCompileType(t): {
				"Could not compile type: " + t;
			}
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
			case ValueAssignedNull: {
				"Cannot assign `null` to value-type. Wrap the type with `Null<T>`.";
			}
			case InfiniteReference(stackDetails): {
				"[Reflaxe/C++ error] Infinite reference encountered!\nPlease find a way to break the chain:\n" + stackDetails;
			}
			case InitializedTypeRequiresValue: {
				"This Haxe code generates an uninitialized variable in C++ for a type that requires a value.";
			}
			case CovarianceRequiresPtrLikeType: {
				"Covariance must use pointer-like type.";
			}
			case NoSuperWithoutSuperClass: {
				"Cannot use `super` in class without super class.";
			}

			// Disabled Features
			case DisallowedHaxeStd: {
				"Using Haxe std type when disallowed.";
			}
			case DisallowedSmartPointers: {
				"Smart pointer memory management types are disabled.";
			}
			case DisallowedDynamic: {
				"Dynamic type disabled.";
			}
			case DisallowedSmartPointerTypeName(typeString): {
				"Smart pointer memory management types are disabled. Compiling type: " + typeString;
			}
			case DisallowedSmartPointerAnonymous(type): {
				"Smart pointer memory management types are disabled. Compiling anonymous type: " + Std.string(type);
			}
			case NoStringAddWOHaxeStd: {
				"Cannot add Strings without Haxe Std.";
			}

			// Meta
			case UncompilableType(t): {
				'Attempted to compile type $t with @:uncompilable metadata.';
			}
			case UncompilableField: {
				"Attempting to compile expression using field marked with @:uncompilable metadata.";
			}
			case CannotUseOnExternClass: {
				"Cannot use on extern class.";
			}
			case ConstExprMetaInvalidUse: {
				"Invalid use of @:constexpr on expression. Must be used with if statement or variable declaration.";
			}
			case ConstExprIncompatibleWithConst: {
				"Cannot use both @:constexpr and @:const.";
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
			case InvalidCStr: {
				"Invalid use of @:cstr. Must be used on a constant String expresszion.";
			}
			case InvalidAlloc: {
				"Invalid use of @:alloc. Must be used on a \"new Type(...)\" expression.";
			}
			case UnsupportedRequireMMT: {
				"UnsafePtr and SharedPtr are the only arguments supported at the moment.";
			}
			case InvalidPassConstTypeParam: {
				"@:passConstTypeParam must be used on variable declaration and contain two arguments: ([expression], [the index of the type parameter it will replace]).";
			}
			case InvalidPassConstTypeParamIndex: {
				"The second argument of @:passConstTypeParam must be an Int.";
			}
			case PassConstTypeParamIndexOutsideRange: {
				"@:passConstTypeParam provided index outside the range of type parameters.";
			}
			case DuplicatePassConstTypeParam: {
				"A @:passConstTypeParam replacing this index already exists.";
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
