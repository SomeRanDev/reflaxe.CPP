// =======================================================
// * DefineHelper
//
// Adds static extensions for `cxxcompiler.config.Define`.
// =======================================================

package cxxcompiler.helpers;

#if (macro || cxx_runtime)

import reflaxe.helpers.Context;

import cxxcompiler.config.Define;

/**
	Adds static extensions for `cxxcompiler.config.Define`.
**/
class DefineHelper {
	public static function defined(d: Define) {
		return Context.defined(d);
	}
}

#end
