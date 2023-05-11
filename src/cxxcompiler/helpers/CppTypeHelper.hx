// =======================================================
// * Type
//
// Adds static extensions for haxe.macro.Type.
// =======================================================

package cxxcompiler.helpers;

#if (macro || cxx_runtime)

import haxe.macro.Context;
import haxe.macro.Type;

using reflaxe.helpers.TypeHelper;

using cxxcompiler.helpers.MetaHelper;

class CppTypeHelper {
	// ----------------------------
	// Returns true if the two types are the same even if
	// they have different memory management overrides.
	public static function valueTypesEqual(t: Type, other: Type, followTypes: Bool = false) {
		if(followTypes) {
			#if macro
			t = Context.followWithAbstracts(t);
			other = Context.followWithAbstracts(other);
			#end
		}
		return getInternalType(t).equals(getInternalType(other));
	}

	// ----------------------------
	// When compiling an expression of type "t" for type "other",
	// this function is used to test whether memory management conversion should occur.
	//
	// For example, a pointer should be converted to value if both of the types are the same.
	// However, memory management conversion should not occur when converting to anonymous
	// structures or dynamic types since they are already made to handle any C++ object.
	public static function shouldConvertMM(t: Type, other: Type): Bool {
		if(valueTypesEqual(t, other)) {
			return true;
		}

		final inner = #if macro Context.follow #end(getInternalType(t));
		final innerOther = #if macro Context.follow #end(getInternalType(other));

		// If converting from non-anon to anon, no conversion should be applied.
		if(!inner.isAnonStruct() && innerOther.isAnonStruct()) {
			return false;
		}

		// If they are both anon structs, we handle mm in AComp.compileObjectDecl later.
		if(inner.isAnonStruct() && innerOther.isAnonStruct()) {
			return false;
		}

		// If converting to Dynamic, do not convert.
		if(innerOther.isDynamic()) {
			return false;
		}

		// If converting to an abstract that takes Dynamic, do not convert.
		switch(innerOther) {
			case TAbstract(absRef, _): {
				for(f in absRef.get().from) {
					if(f.t.isDynamic()) {
						return false;
					}
				}
			}
			case _:
		}

		return #if macro Context.unify(t, other) #else false #end;
	}

	// ----------------------------
	// If this type is a memory management overrider,
	// this returns the internal type. Returns the provided type otherwise.
	// Bypasses all Null<T> outside the overrider class.
	public static function getInternalType(t: Type): Type {
		switch(t) {
			case TAbstract(absRef, params): {
				final abs = absRef.get();
				if(abs.name == "Null" && params.length == 1) {
					return getInternalType(params[0]);
				}
				if(abs.isOverrideMemoryManagement() && params.length == 1) {
					return params[0];
				}
			}
			case _:
		}
		return t;
	}

	// ----------------------------
	public static function replaceInternalType(t: Type, replacement: Type): Type {
		switch(t) {
			case TAbstract(absRef, params): {
				final abs = absRef.get();
				if(abs.name == "Null" && params.length == 1) {
					return TAbstract(absRef, [replaceInternalType(params[0], replacement)]);
				}
				if(abs.isOverrideMemoryManagement() && params.length == 1) {
					return TAbstract(absRef, [replaceInternalType(params[0], replacement)]);
				}
			}
			case _:
		}
		return replacement;
	}

	// ----------------------------
	public static function isAnonStructOrNamedStruct(t: Type) {
		final it = getInternalType(t);
		if(it.isAnonStruct()) {
			return true;
		}
		return #if macro Context.follow(it).isAnonStruct() #else false #end;
	}

	// ----------------------------
	// If "t" is Null<T> and "target" is T, returns true.
	// Returns false otherwise.
	public static function isNullOfType(t: Type, target: Type): Bool {
		final internal = t.unwrapNullType();
		return if(internal != null) {
			internal.equals(target);
		} else {
			false;
		}
	}

	// ----------------------------
	// Returns true is this is the cxx.Ref typedef
	public static function isRef(t: Type): Bool {
		return switch(t) {
			case TType(defRef, params) if(params.length == 1): {
				final defType = defRef.get();
				defType.name == "Ref" && defType.module == "cxx.Ref";
			}
			case _: false;
		}
	}

	// ----------------------------
	// Sometimes the type of the `null` being passed is
	// ambiguous in C++ (like being passed to std::any 
	// function when there is template alternative).
	// This checks for these "ambiguous" types. 
	public static function isAmbiguousNullable(t: Type): Bool {
		return switch(t) {
			case TInst(clsRef, _): {
				switch(clsRef.get().kind) {
					case KTypeParameter(_): true;
					case _: false;
				}
			}
			case TAbstract(anonRef, _) if(anonRef.get().module == "Any"): true;
			case TDynamic(_): true;
			case _: false;
		}
	}

	/**
		Returns `true` if the type is `Int`, `Float`,
		`UInt`, `Single` or in the `cxx.num` package.
	**/
	public static function isCppNumberType(t: Type): Bool {
		return if(t.isNumberType()) true;
		else switch(t) {
			case TType(isCxxNum(_.get()) => true, []): true;
			case TAbstract(isCxxNum(_.get()) => true, []): true;
			case _: false;
		}
	}

	/**
		If `true`, that means `other` is a different enough
		number type it should be explicitly casted in C++
		to prevent warnings.
	**/
	public static function shouldCastNumber(t: Type, other: Type): Bool {
		if(!isCppNumberType(t) || !isCppNumberType(other)) return false;
		return (
			isFloatType(t) != isFloatType(other) ||
			isUnsignedType(t) != isUnsignedType(other) ||
			getNumberTypeSize(t) > getNumberTypeSize(other)
		);
	}

	/**
		Returns `true` if the provided `BaseType` is in
		the `cxx.num` package.
	**/
	public static function isCxxNum(b: BaseType): Bool {
		return b.pack.length == 2 && b.pack[0] == "cxx" && b.pack[1] == "num";
	}

	/**
		Returns `true` if the type is a number type that
		can store decimal values. This includes:
			- `Float`
			- `Single`
			- `cxx.num.Float32`
			- `cxx.num.Float64`
	**/
	public static function isFloatType(t: Type): Bool {
		return if(!isCppNumberType(t)) false;
		else switch(t) {
			case TAbstract(abRef, []): {
				final a = abRef.get();
				switch(a.name) {
					case "Single": a.module == "StdTypes" || a.module == "Single";
					case "Float": a.module == "StdTypes";
					case "Float32" | "Float64": isCxxNum(a);
					case _: false;
				}
			}
			case TType(defRef, []): {
				final d = defRef.get();
				switch(d.name) {
					case "Float32" | "Float64": isCxxNum(d);
					case _: false;
				}
			}
			case _: false;
		}
	}

	/**
		Returns `true` if the type is a number type that's unsigned.
		This includes `UInt` and all the `cxx.num.UInt--` types.
	**/
	public static function isUnsignedType(t: Type): Bool {
		return if(!isCppNumberType(t)) false;
		else switch(t) {
			case TAbstract(abRef, []): {
				final a = abRef.get();
				switch(a.name) {
					case "UInt8" | "UInt16" | "UInt32" | "UInt64" | "SizeT": isCxxNum(a);
					case "UInt": a.module == "UInt";
					case _: false;
				}
			}
			case TType(defRef, []): {
				final d = defRef.get();
				switch(d.name) {
					case "UInt8" | "UInt16" | "UInt32" | "UInt64" | "SizeT": isCxxNum(d);
					case _: false;
				}
			}
			case _: false;
		}
	}

	/**
		Returns an estimate of the number type's size in C++.

		These are not meant to be perfectly accurate as the exact
		size of number types varies for each platform/compiler.

		Instead these are used to check if one number type is
		larger than the other to help with better C++ generation.

		Returns `-1` if the type is not a number type.
	**/
	public static function getNumberTypeSize(t: Type): Int {
		final baseType = switch(t) {
			case TAbstract(abRef, []): abRef.get();
			case TType(defRef, []): defRef.get();
			case _: return -1;
		}

		return if(isCxxNum(baseType)) {
			switch(baseType.name) {
				case "Int8": 8;
				case "Int16": 16;
				case "Int32": 32;
				case "Int64": 64;

				case "UInt8": 8;
				case "UInt16": 16;
				case "UInt32": 32;
				case "UInt64": 64;

				case "Float32": 32;
				case "Float64": 64;

				case "SizeT": 32;

				case _: -1;
			}
		} else if(baseType.module == "StdTypes") {
			switch(baseType.name) {
				case "Int": 32;
				case "Single": 32;
				case "Float": 64;
				case _: -1;
			}
		} else {
			switch(baseType) {
				case { module: "Single", name: "Single" }: 32;
				case { module: "UInt", name: "UInt" }: 32;
				case _: -1;
			}
		}
	}
}

#end
