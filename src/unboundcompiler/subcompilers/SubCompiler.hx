// =======================================================
// * SubCompiler
//
// Base class of all Compiler_... classes.
// =======================================================

package unboundcompiler.subcompilers;

#if (macro || ucpp_runtime)

import unboundcompiler.UnboundCompiler;

class SubCompiler {
	var Main: UnboundCompiler;

	var CComp: Compiler_Classes;
	var EComp: Compiler_Enums;
	var AComp: Compiler_Anon;
	var IComp: Compiler_Includes;
	var TComp: Compiler_Types;
	var XComp: Compiler_Exprs;

	public function new(compiler: UnboundCompiler) {
		Main = compiler;
	}

	public function setSubCompilers(
		c: Compiler_Classes, e: Compiler_Enums,
		a: Compiler_Anon, i: Compiler_Includes,
		t: Compiler_Types, x: Compiler_Exprs
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
