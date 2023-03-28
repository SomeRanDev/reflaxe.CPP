// =======================================================
// * UType
//
// Adds static extensions for haxe.macro.Type.
// =======================================================

package unboundcompiler.helpers;

#if (macro || ucpp_runtime)

import haxe.macro.Context;
import haxe.macro.Type;

using reflaxe.helpers.TypeHelper;

using unboundcompiler.helpers.UMeta;

class UType {
	// ----------------------------
	// Returns true if the two types are the same even if
	// they have different memory management overrides.
	public static function valueTypesEqual(t: Type, other: Type, followTypes: Bool = false) {
		if(followTypes) {
			t = Context.followWithAbstracts(t);
			other = Context.followWithAbstracts(other);
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

		final inner = Context.follow(getInternalType(t));
		final innerOther = Context.follow(getInternalType(other));

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

		return Context.unify(t, other);
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
		return Context.follow(it).isAnonStruct();
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
	// Returns true is this is the ucpp.Ref typedef
	public static function isRef(t: Type): Bool {
		return switch(t) {
			case TType(defRef, params) if(params.length == 1): {
				final defType = defRef.get();
				defType.name == "Ref" && defType.module == "ucpp.Ref";
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
}

#end
