package freecompiler.helpers;

#if (macro || fcpp_runtime)

import haxe.macro.Type;

using reflaxe.helpers.TypeHelper;

using freecompiler.helpers.FreeMeta;

class FreeType {
	// ----------------------------
	// Returns true if the two types are the same even if
	// they have different memory management overrides.
	public static function valueTypesEqual(t: Type, other: Type) {
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
}

#end
