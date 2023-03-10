// =======================================================
// * UnboundCompiler
//
// The main compiler. Most of its behavior is split
// between "sub-compilers" in the `subcompilers` package.
// =======================================================

package unboundcompiler;

#if (macro || ucpp_runtime)

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

import reflaxe.BaseCompiler;
import reflaxe.PluginCompiler;
import reflaxe.ReflectCompiler;

using reflaxe.helpers.ClassTypeHelper;
using reflaxe.helpers.ModuleTypeHelper;
using reflaxe.helpers.NameMetaHelper;
using reflaxe.helpers.NullableMetaAccessHelper;
using reflaxe.helpers.TypeHelper;

import unboundcompiler.subcompilers.SubCompiler;
import unboundcompiler.subcompilers.Compiler_Classes;
import unboundcompiler.subcompilers.Compiler_Enums;
import unboundcompiler.subcompilers.Compiler_Anon;
import unboundcompiler.subcompilers.Compiler_Exprs;
import unboundcompiler.subcompilers.Compiler_Includes;
import unboundcompiler.subcompilers.Compiler_Types;

class UnboundCompiler extends reflaxe.PluginCompiler<UnboundCompiler> {
	// ----------------------------
	// The extension for the generated header files.
	static final HeaderExt: String = ".h";

	// ----------------------------
	// The extension for the generated source files.
	static final SourceExt: String = ".cpp";

	// ----------------------------
	// The C++ classes used for nullability and memory management.
	static final OptionalClassCpp: String = "std::optional";
	static final SharedPtrClassCpp: String = "std::shared_ptr";
	static final UniquePtrClassCpp: String = "std::unique_ptr";

	// ----------------------------
	// The C++ functions used for generating smart pointers.
	static final SharedPtrMakeCpp: String = "std::make_shared";
	static final UniquePtrMakeCpp: String = "std::make_unique";

	// ----------------------------
	// The include params used upon requiring the above C++ classes.
	static final OptionalInclude: Dynamic = ["optional", true];
	static final SharedPtrInclude: Dynamic = ["memory", true];
	static final UniquePtrInclude: Dynamic = ["memory", true];

	// ----------------------------
	// The name of the header file generated for the anonymous structs.
	static final AnonStructHeaderFile: String = "_AnonStructs";
	static final OptionalInfoHeaderFile: String = "_AnonUtils";

	// ----------------------------
	// Required for adding semicolons at the end of each line.
	override function formatExpressionLine(expr: String): String {
		return expr + ";";
	}

	// ============================
	// * Plugins
	// ============================
	public static function onCompileBegin(callback: (UnboundCompiler) -> Void) {
		ReflectCompiler.onCompileBegin(callback);
	}

	// ============================
	// * Sub-Compilers
	// ============================
	var CComp: Compiler_Classes;
	var EComp: Compiler_Enums;
	var AComp: Compiler_Anon;
	var IComp: Compiler_Includes;
	var TComp: Compiler_Types;
	var XComp: Compiler_Exprs;

	public function new() {
		super();
		CComp = new Compiler_Classes(this);
		EComp = new Compiler_Enums(this);
		AComp = new Compiler_Anon(this);
		IComp = new Compiler_Includes(this);
		TComp = new Compiler_Types(this);
		XComp = new Compiler_Exprs(this);

		function setup(c: SubCompiler) c.setSubCompilers(CComp, EComp, AComp, IComp, TComp, XComp);
		setup(CComp);
		setup(EComp);
		setup(AComp);
		setup(IComp);
		setup(TComp);
		setup(XComp);
	}

	// ----------------------------
	// Called after all module types have
	// been passed to this compiler class.
	public override function onCompileEnd() {
		generateAnonStructHeader();
	}

	// ----------------------------
	// Called whenever a significant ModuleType
	// is encountered while compiling to 
	// ensure it is #included and compiled.
	public function onModuleTypeEncountered(mt: ModuleType, addToHeader: Bool) {
		IComp.addIncludeFromModuleType(mt, addToHeader);
		addModuleTypeForCompilation(mt);
	}

	// ----------------------------
	// Called whenever a significant Type
	// is encountered while compiling to
	// ensure it is #included.
	public function onTypeEncountered(t: Type, addToHeader: Bool) {
		IComp.addIncludeFromType(t, addToHeader);

		final mt = t.toModuleType();
		if(mt != null) {
			addModuleTypeForCompilation(mt);
		}

		switch(t) {
			case TInst(_, params) | TEnum(_, params) | TType(_, params) | TAbstract(_, params): {
				for(p in params) {
					onTypeEncountered(p, addToHeader);
				}
			}
			case _: {}
		}
	}

	// ----------------------------
	// The ability to "override" a TVar's
	// type is necessary for some behavior.
	//
	// This collection of functions helps
	// achieve that by intercepting all
	// requests to TypedExpr and TVar types and
	// possibly replacing them.
	var tvarTypeOverrides: Map<Int, Type> = [];

	public function getTVarType(tvar: TVar): Type {
		if(tvarTypeOverrides.exists(tvar.id)) {
			return tvarTypeOverrides.get(tvar.id);
		}
		return tvar.t;
	}

	public function setTVarType(tvar: TVar, t: Type) {
		tvarTypeOverrides.set(tvar.id, t);
	}

	public function getExprType(e: TypedExpr): Type {
		return switch(e.expr) {
			case TLocal(tvar): getTVarType(tvar);
			case _: e.t;
		}
	}

	// ----------------------------
	// Generate the header containing all the
	// specially made classes for the anonymous
	// structures used in Haxe.
	function generateAnonStructHeader() {
		IComp.resetAndInitIncludes(true);
		IComp.addInclude(OptionalInclude[0], true, OptionalInclude[1]);
		final anonContent = AComp.makeAllUnnamedDecls();
		if(IComp.anonHeaderRequired || anonContent.length > 0) {
			final optionalInfoHeaderName = OptionalInfoHeaderFile + HeaderExt;

			// Generate haxe::optional_info header.
			{
				var content = "#pragma once\n\n";
				content += "#include " + IComp.wrapInclude(OptionalInclude[0], OptionalInclude[1]) + "\n";
				content += "#include " + IComp.wrapInclude(SharedPtrInclude[0], SharedPtrInclude[1]) + "\n";
				if(UniquePtrInclude[0] != SharedPtrInclude[0]) {
					content += "#include " + IComp.wrapInclude(UniquePtrInclude[0], UniquePtrInclude[1]) + "\n";
				}
				content += "\n";
				content += AComp.optionalInfoContent() + "\n\n";
				setExtraFile("include/" + optionalInfoHeaderName, content);
			}

			// Generate anonymous structures header.
			{
				var content = "#pragma once\n\n";
				content += "#include \"" + optionalInfoHeaderName + "\"\n\n";
				content += IComp.compileHeaderIncludes() + "\n\n";
				content += "namespace haxe {\n\n";
				content += anonContent;
				content += "\n}";
				setExtraFile("include/" + AnonStructHeaderFile + HeaderExt, content);
			}
		}
	}

	// ----------------------------
	// Checks if this type is the same as the
	// ModuleType that's currently being compiled.
	function isSameAsCurrentModule(t: Type): Bool {
		// If Null<T>, unwrap and check "T"
		switch(t) {
			case TAbstract(absRef, params): {
				switch(absRef.get().name) {
					case "Null" if(params.length == 1): {
						return isSameAsCurrentModule(params[0]);
					}
					case _:
				}
			}
			case _:
		}

		return getCurrentModule().equals(t.toModuleType());
	}

	// ----------------------------
	// Get the file name that would be generated
	// by default for the provided Haxe type.
	function getFileNameFromType(t: Type): Null<String> {
		final mt = t.toModuleType();
		if(mt == null) return null;
		return getFileNameFromModuleData(mt.getCommonData());
	}

	function getFileNameFromModuleData(md: CommonModuleTypeData): String {
		return if(md.hasMeta(":filename")) {
			md.meta.extractStringFromFirstMeta(":filename");
		} else {
			md.moduleId();
		}
	}

	// ----------------------------
	// Compile the start of all namespaces
	// for the provided module data.
	function compileNamespaceStart(md: CommonModuleTypeData): String {
		var result = "";
		for(p in md.pack) {
			result += "namespace " + p + " {\n";
		}
		if(md.pack.length > 0) result += "\n";
		return result;
	}

	// ----------------------------
	// Compile all namespace closing brackets.
	function compileNamespaceEnd(md: CommonModuleTypeData): String {
		var result = "";
		for(p in md.pack) {
			result += "\n}";
		}
		return result;
	}

	// ----------------------------
	// Compile standard function-argument syntax
	// for C++ from a TVar and TypedExpr.
	function compileFunctionArgument(arg: { v: TVar, value: Null<TypedExpr> }, pos: Position, noDefaultValue: Bool = false, compilingInCpp: Bool = false) {
		var result = TComp.compileType(arg.v.t, pos) + " " + compileVarName(arg.v.name);
		if(!noDefaultValue && arg.value != null) {
			XComp.compilingInHeader = !compilingInCpp;
			result += " = " + compileExpressionOrError(arg.value);
			XComp.compilingInHeader = false;
		}
		return result;
	}

	// ----------------------------
	// Stores the super class's name so we can use
	// it when calling "super" functions.
	var superTypeName: String = "";

	// ----------------------------
	// Compiles a class into C++.
	public function compileClassImpl(classType: ClassType, varFields: ClassFieldVars, funcFields: ClassFieldFuncs): Null<String> {
		return CComp.compileClass(classType, varFields, funcFields);
	}

	// ----------------------------
	// Compiles an enum into C++.
	public function compileEnumImpl(enumType: EnumType, options: EnumOptions): Null<String> {
		return EComp.compileEnum(enumType, options);
	}

	// ----------------------------
	// Compiles an typedef into C++.
	public override function compileTypedef(defType: DefType): Null<String> {
		if(defType.hasMeta(":extern")) {
			return null;
		}

		// Get filename for this typedef
		final filename = getFileNameFromModuleData(defType);
		final headerFilename = filename + HeaderExt;

		// Init includes
		IComp.resetAndInitIncludes(true, [headerFilename]);

		// Ignore "static" member structures
		switch(defType.type) {
			case TAnonymous(anonRef): {
				switch(anonRef.get().status) {
					case AClassStatics(_) | AEnumStatics(_) | AAbstractStatics(_): {
						return null;
					}
					case _:
				}
			}
			case _:
		}

		// Get typedef alias name
		final typedefName = defType.getNameOrNative();

		// Include type
		onTypeEncountered(defType.type, true);

		// Compile content
		var content = "";
		content += compileNamespaceStart(defType);
		switch(defType.type) {
			case TAnonymous(anonRef): {
				IComp.addAnonTypeInclude(true);
				content += AComp.compileNamedAnonTypeDefinition(defType, anonRef);
			}
			case _: {
				final hasParams = defType.params.length > 0;
				if(hasParams || defType.hasMeta(":cppUsing")) {
					if(hasParams) {
						content += "template<" + defType.params.map(p -> "typename " + p.name).join(", ") + ">\n";
					}
					content += "using " + typedefName + " = " + TComp.compileType(defType.type, defType.pos) + ";\n";
				} else {
					content += "typedef " + TComp.compileType(defType.type, defType.pos) + " " + typedefName + ";\n";
				}
			}
		}
		content += compileNamespaceEnd(defType);

		final headerFilePath = "include/" + headerFilename;

		// pragma once
		setExtraFileIfEmpty(headerFilePath, "#pragma once");

		// Compile headers
		IComp.appendIncludesToExtraFileWithoutRepeats(headerFilePath, IComp.compileHeaderIncludes(), 1);

		// Output typedef
		appendToExtraFile(headerFilePath, content + "\n", 2);

		return null;
	}

	// ----------------------------
	// Ensures an abstract's internal type is compiled.
	public override function compileAbstract(absType: AbstractType): Null<String> {
		final mt = absType.type.toModuleType();
		if(mt != null) {
			addModuleTypeForCompilation(mt);
		}
		return null;
	}

	// ----------------------------
	// Compile TypedExpr into C++.
	public function compileExpressionImpl(expr: TypedExpr): Null<String> {
		return XComp.compileExpressionToCpp(expr);
	}
}

#end
