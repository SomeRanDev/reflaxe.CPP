// =======================================================
// * SubCompiler
//
// Base class of all Compiler_... classes.
// =======================================================

package cxxcompiler.subcompilers;

#if (macro || cxx_runtime)

import cxxcompiler.Compiler;

class SubCompiler {
	var Main: Compiler;

	@:nullSafety(Off) var CComp: Classes;
	@:nullSafety(Off) var EComp: Enums;
	@:nullSafety(Off) var AComp: Anon;
	@:nullSafety(Off) var IComp: Includes;
	@:nullSafety(Off) var RComp: Reflection;
	@:nullSafety(Off) var DComp: Dynamic.Dynamic_;
	@:nullSafety(Off) var TComp: Types;
	@:nullSafety(Off) var XComp: Expressions;

	public function new(compiler: Compiler) {
		Main = compiler;
	}

	public function setSubCompilers(
		c: Classes, e: Enums,
		a: Anon, i: Includes,
		r: Reflection, d: Dynamic.Dynamic_,
		t: Types, x: Expressions
	) {
		CComp = c;
		EComp = e;
		AComp = a;
		IComp = i;
		RComp = r;
		DComp = d;
		TComp = t;
		XComp = x;
	}
}

#end
