// =======================================================
// * GCFSubCompiler
//
// Base class of all GCFCompiler_... classes.
// =======================================================

package gcfcompiler.subcompilers;

#if (macro || gcf_runtime)

import gcfcompiler.GCFCompiler;

class GCFSubCompiler {
	var Main: GCFCompiler;

	var CComp: GCFCompiler_Classes;
	var EComp: GCFCompiler_Enums;
	var IComp: GCFCompiler_Includes;
	var TComp: GCFCompiler_Types;
	var XComp: GCFCompiler_Exprs;

	public function new(compiler: GCFCompiler) {
		Main = compiler;
	}

	public function setSubCompilers(
		c: GCFCompiler_Classes, e: GCFCompiler_Enums,
		i: GCFCompiler_Includes, t: GCFCompiler_Types,
		x: GCFCompiler_Exprs
	) {
		CComp = c;
		EComp = e;
		IComp = i;
		TComp = t;
		XComp = x;
	}
}

#end
