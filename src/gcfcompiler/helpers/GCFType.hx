package gcfcompiler.helpers;

#if (macro || gcf_runtime)

import haxe.macro.Type;

using reflaxe.helpers.TypeHelper;

using gcfcompiler.helpers.GCFMeta;

class GCFType {
	// ----------------------------
	// Returns true if the two types are the same even if
	// they have different memory management overrides.
	public static function valueTypesEqual(t: Type, other: Type) {
		return getInternalType(t).equals(getInternalType(other));
	}

	// ----------------------------
	// If this type is a memory management overrider,
	// this returns the internal type.
	// Returns the provided type otherwise.
	public static function getInternalType(t: Type): Type {
		switch(t) {
			case TAbstract(absRef, params): {
				final abs = absRef.get();
				if(abs.isOverrideMemoryManagement() && params.length == 1) {
					return params[0];
				}
			}
			case _:
		}
		return t;
	}
}

#end
