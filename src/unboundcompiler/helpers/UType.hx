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
