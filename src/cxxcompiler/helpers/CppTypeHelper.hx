// =======================================================
// * Type
//
// Adds static extensions for haxe.macro.Type.
// =======================================================

package cxxcompiler.helpers;

#if (macro || cxx_runtime)

import reflaxe.helpers.Context;
import haxe.macro.Type;

import cxxcompiler.config.Meta;

using reflaxe.helpers.BaseTypeHelper;
using reflaxe.helpers.NullableMetaAccessHelper;
using reflaxe.helpers.ModuleTypeHelper;
using reflaxe.helpers.NameMetaHelper;
using reflaxe.helpers.TypeHelper;

using cxxcompiler.helpers.MetaHelper;

class CppTypeHelper {
	// ----------------------------
	// Get priority of a type in a class declaration.
	//
	// Higher values appear higher in the class declaration.
	public static function typePriority(t: Type): Float {
		t = t.unwrapNullTypeOrSelf();

		if(isPtr(t)) {
			return 64.5;
		}

		if(isRefOrConstRef(t)) {
			return 64.25;
		}

		if(isCppNumberType(t)) {
			return getNumberTypeSize(t);
		}

		if(t.isBool()) {
			return 1;
		}

		return 999;
	}

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

		return {
			#if macro
				if(!Context.unify(t, other)) {
					Context.unify(getInternalType(t), getInternalType(other));
				} else {
					true;
				}
			#else
				false;
			#end
		}
	}

	// ----------------------------
	// If this type is a memory management overrider,
	// this returns the internal type. Returns the provided type otherwise.
	// Bypasses all Null<T> outside the overrider class.
	public static function getInternalType(t: Type): Type {
		switch(t) {
			case TType(defRef, [inner]) if(isConst(t)): {
				return getInternalType(inner);
			}
			case TType(_.get() => defType, [inner]) if(defType.isReflaxeExtern()): {
				getInternalType(inner);
			}
			case TAbstract(absRef, params): {
				final abs = absRef.get();
				if(abs.name == "Null" && params.length == 1) {
					return getInternalType(params[0]);
				}
				if(abs.metaIsOverrideMemoryManagement() && params.length == 1) {
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
			case TType(defRef, [inner]) if(isConst(t)): {
				return TType(defRef, [replaceInternalType(inner, replacement)]);
			}
			case TType(_.get() => defType, [inner]) if(defType.isReflaxeExtern()): {
				isOverrideMemoryManagement(inner);
			}
			case TAbstract(absRef, params): {
				final abs = absRef.get();
				if(abs.name == "Null" && params.length == 1) {
					return TAbstract(absRef, [replaceInternalType(params[0], replacement)]);
				}
				if(abs.metaIsOverrideMemoryManagement() && params.length == 1) {
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
	public static function isOverrideMemoryManagement(t: Type): Bool {
		return switch(t) {
			case TAbstract(absRef, _) if(absRef.get().metaIsOverrideMemoryManagement()): true;
			case TType(_, [inner]) if(isConst(t)): isOverrideMemoryManagement(inner);
			case TType(_.get() => defType, [inner]) if(defType.isReflaxeExtern()): isOverrideMemoryManagement(inner);
			case _: false;
		}
	}

	// ----------------------------
	// `true` if cxx.Const
	public static function isConst(t: Type): Bool {
		return switch(t) {
			case TType(_.get() => { name: "Const", module: "cxx.Const" }, _): true;
			case _: false;
		}
	}

	// ----------------------------
	// Unwraps all cxx.Const<...> from Type
	public static function unwrapConst(t: Type): Type {
		return switch(t) {
			case TType(_, [inner]) if(isConst(t)): unwrapConst(inner);
			case _: t;
		}
	}

	// ----------------------------
	// `true` if cxx.Ptr
	public static function isPtr(t: Type): Bool {
		return switch(unwrapConst(t)) {
			case TAbstract(_.get() => { name: "Ptr", module: "cxx.Ptr" }, _): true;
			case TType(_.get() => defType, _) if(defType.isReflaxeExtern()): isPtr(defType.type);
			case _: false;
		}
	}

	// ----------------------------
	// If "t" is Null<T> and "target" is T, returns true.
	// Returns false otherwise.
	public static function isNullOfType(t: Type, target: Type): Bool {
		final internal = t.unwrapNullType();
		if(internal != null) {
			return if(!internal.equals(target)) {
				final t1 = Context.followWithAbstracts(internal) ?? internal;
				final t2 = Context.followWithAbstracts(t) ?? t;
				t1.equals(t2);
			} else true;
		}
		return false;
	}

	// ----------------------------
	// Returns true is this is the cxx.Ref or cxx.ConstRef typedef
	public static function isRefOrConstRef(t: Type): Bool {
		return switch(t) {
			case TType(defRef, params) if(params.length == 1): {
				final defType = defRef.get();
				(defType.name == "Ref" && defType.module == "cxx.Ref") ||
				(defType.name == "ConstRef" && defType.module == "cxx.ConstRef") ||
				(defType.isReflaxeExtern() && isRefOrConstRef(defType.type));
			}
			case _: false;
		}
	}

	// ----------------------------
	// Returns true is this is specifically cxx.ConstRef
	public static function isConstRef(t: Type): Bool {
		return switch(t) {
			case TType(defRef, params) if(params.length == 1): {
				final defType = defRef.get();
				(defType.name == "ConstRef" && defType.module == "cxx.ConstRef") ||
				(defType.isReflaxeExtern() && isConstRef(defType.type));
			}
			case _: false;
		}
	}

	// ----------------------------
	// If the type is cxx.Ref or cxx.ConstRef this returns the internal type.
	// Otherwise it returns itself.
	public static function unwrapRefOrConstRef(t: Type): Null<Type> {
		return switch(t) {
			case TType(_, [unwrappedType]) if(isRefOrConstRef(t)): {
				unwrapRefOrConstRef(unwrappedType) ?? unwrappedType;
			}
			case _: null;
		}
	}

	// ----------------------------
	// Returns true variables of this type MUST contain
	// a value upon being declared.
	public static function requiresValue(t: Type): Bool {
		return isRefOrConstRef(t);
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
		Returns `true` if the type is a primitive which
		should always be treated as a value OR has the
		`@:copyType` metadata.

		This is used in determining whether a Value variable
		should be converted to a reference. We want that
		behavior when working with objects, but not numbers
		and bools.
	**/
	public static function isAlwaysValue(t: Type): Bool {
		final mt = t.toModuleType();
		if(mt != null && mt.getCommonData().hasMeta(Meta.CopyType)) {
			return true;
		}

		return isCppNumberType(t) || t.isBool() || t.isString();
	}

	/**
		If this type should have a default value when not default assigned,
		this will return the default value content here.
	**/
	public static function getDefaultValue(t: Type): Null<String> {
		if(isCppNumberType(t)) return "0";
		else if(t.isBool()) return "false";
		return null;
	}

	/**
		Returns `true` if the type is `Int`, `Float`,
		`UInt`, `Single` or in the `cxx.num` package.
	**/
	public static function isCppNumberType(t: Type): Bool {
		return if(t.isNumberType()) true;
		else {
			final mt = t.toModuleType();
			mt != null ? isCxxNum(mt.getCommonData()) : false;
		}
	}

	/**
		Given two number types, find which one takes
		priority in C++ in a binary operation.

		This is not guaranteed to be perfect and is generally
		used to detect if number casting should occur.
	**/
	public static function findPriorityNumberType(t1: Type, t2: Type): Null<Type> {
		if(t1.equals(t2)) return t1;
		if(!isCppNumberType(t1) || !isCppNumberType(t2)) return null;

		// The floating type takes priority
		final isFloat1 = isFloatType(t1);
		if(isFloat1 != isFloatType(t2)) {
			return isFloat1 ? t1 : t2;
		}

		// The unsigned number type takes priority
		final isUnsigned1 = isUnsignedType(t1);
		if(isUnsigned1 != isUnsignedType(t2)) {
			return isUnsigned1 ? t1 : t2;
		}

		// The larger number type takes priority
		final size1 = getNumberTypeSize(t1);
		final size2 = getNumberTypeSize(t2);
		if(size1 != size2) {
			return size1 > size2 ? t1 : t2;
		}

		// They are identical, so let Haxe decide.
		return null;
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
		if(b.hasMeta(Meta.NumberType)) return true;
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
		else {
			final result = switch(t) {
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

			return if(!result) {
				final b = t.toModuleType()?.getCommonData();
				b?.meta?.extractPrimtiveFromFirstMeta(Meta.NumberType, 1) ?? false;
			} else {
				true;
			}
		}
	}

	/**
		Returns `true` if the type is a number type that's unsigned.
		This includes `UInt` and all the `cxx.num.UInt--` types.
	**/
	public static function isUnsignedType(t: Type): Bool {
		return if(!isCppNumberType(t)) false;
		else {
			final result = switch(t) {
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

			return if(!result) {
				final b = t.toModuleType()?.getCommonData();
				b?.meta?.extractPrimtiveFromFirstMeta(Meta.NumberType, 2) ?? false;
			} else {
				true;
			}
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

		final result = if(isCxxNum(baseType)) {
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

		return if(result == -1) {
			final b = t.toModuleType()?.getCommonData();
			b?.meta?.extractPrimtiveFromFirstMeta(Meta.NumberType, 0) ?? -1;
		} else {
			result;
		}
	}
}

#end
