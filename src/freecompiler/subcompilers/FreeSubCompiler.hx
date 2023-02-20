// =======================================================
// * FreeSubCompiler
//
// Base class of all FreeCompiler_... classes.
// =======================================================

package freecompiler.subcompilers;

#if (macro || fcpp_runtime)

import freecompiler.FreeCompiler;

class FreeSubCompiler {
	var Main: FreeCompiler;

	var CComp: FreeCompiler_Classes;
	var EComp: FreeCompiler_Enums;
	var AComp: FreeCompiler_Anon;
	var IComp: FreeCompiler_Includes;
	var TComp: FreeCompiler_Types;
	var XComp: FreeCompiler_Exprs;

	public function new(compiler: FreeCompiler) {
		Main = compiler;
	}

	public function setSubCompilers(
		c: FreeCompiler_Classes, e: FreeCompiler_Enums,
		a: FreeCompiler_Anon, i: FreeCompiler_Includes,
		t: FreeCompiler_Types, x: FreeCompiler_Exprs
	) {
		CComp = c;
		EComp = e;
		AComp = a;
		IComp = i;
		TComp = t;
		XComp = x;
	}
}

#end
