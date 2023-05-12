// =======================================================
// * DefineHelper
//
// List all the custom metadata used in this project and
// provides access using a String enum abstract.
//
// Furthermore, it adds static extensions for objects that
// match: { name: String, meta: Null<MetaAccess> }
// =======================================================

package cxxcompiler.helpers;

#if (macro || cxx_runtime)

import reflaxe.helpers.Context;

import cxxcompiler.config.Define;

class DefineHelper {
	public static function defined(d: Define) {
		return Context.defined(d);
	}
}

#end
