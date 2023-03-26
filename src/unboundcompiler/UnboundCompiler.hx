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
using reflaxe.helpers.SyntaxHelper;
using reflaxe.helpers.TypedExprHelper;
using reflaxe.helpers.TypeHelper;

import unboundcompiler.subcompilers.SubCompiler;
import unboundcompiler.subcompilers.Compiler_Classes;
import unboundcompiler.subcompilers.Compiler_Enums;
import unboundcompiler.subcompilers.Compiler_Anon;
import unboundcompiler.subcompilers.Compiler_Exprs;
import unboundcompiler.subcompilers.Compiler_Includes;
import unboundcompiler.subcompilers.Compiler_Reflection;
import unboundcompiler.subcompilers.Compiler_Types;

import unboundcompiler.other.DependencyTracker;

class UnboundCompiler extends reflaxe.PluginCompiler<UnboundCompiler> {
	// ----------------------------
	// The extension for the generated header files.
	static final HeaderExt: String = ".h";

	// ----------------------------
	// The extension for the generated source files.
	static final SourceExt: String = ".cpp";

	// ----------------------------
	// The folder all the header files are placed into.
	static final HeaderFolder: String = "include";

	// ----------------------------
	// The folder all the source files are placed into.
	static final SourceFolder: String = "src";

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
	static final AnonUtilsHeaderFile: String = "_AnonUtils";
	static final TypeUtilsHeaderFile: String = "_TypeUtils";

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
	var RComp: Compiler_Reflection;
	var TComp: Compiler_Types;
	var XComp: Compiler_Exprs;

	public function new() {
		super();
		CComp = new Compiler_Classes(this);
		EComp = new Compiler_Enums(this);
		AComp = new Compiler_Anon(this);
		IComp = new Compiler_Includes(this);
		RComp = new Compiler_Reflection(this);
		TComp = new Compiler_Types(this);
		XComp = new Compiler_Exprs(this);

		function setup(c: SubCompiler) c.setSubCompilers(CComp, EComp, AComp, IComp, RComp, TComp, XComp);
		setup(CComp);
		setup(EComp);
		setup(AComp);
		setup(IComp);
		setup(RComp);
		setup(TComp);
		setup(XComp);
	}

	// ----------------------------
	// Called after all module types have
	// been passed to this compiler class.
	public override function onCompileEnd() {
		generateReflectionInfo();
		generateAnonStructHeader();
		generateTypeUtilsHeader();
		generateMainFile();
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

		if(addToHeader) {
			addDep(t);
		}

		final mt = t.toModuleType();
		if(mt != null) {
			addModuleTypeForCompilation(mt);
		}

		switch(t) {
			case TInst(_, params) | TEnum(_, params) | TType(_, params) | TAbstract(_, params): {
				for(p in params) {
					onTypeEncountered(p, addToHeader);
					if(addToHeader) {
						addDep(p);
					}
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
			// Ensure "this" is typed as pointer
			case TConst(TThis): TAbstract(getPtrType(), [e.t]);

			// Redirect "tvar" type
			case TLocal(tvar): getTVarType(tvar);

			// For some reason, `e.t` is inaccurate when typing a TField expression.
			//
			// This ensures the type attached to the field declaration is used,
			// rather than the possibly incorrect  type Haxe decided to give it.
			case TField(_, fa): {
				final t: Null<{ type: Type, params: Array<TypeParameter> }> = switch(fa) {
					case FInstance(_, _, cfr): cfr.get();
					case FStatic(_, cfr): cfr.get();
					case FAnon(cfr): cfr.get();
					case FClosure(_, cfr): cfr.get();
					case FEnum(_, ef): ef;
					case _: null;
				}

				// TODO:
				// If there are any type parameters, `e.t` is more accurate
				// because it has the actual parameters filled in.
				// Maybe find a way to fill in the decl type?
				if(t != null && t.params.length == 0) {
					t.type;
				} else {
					e.t;
				}
			}

			// Return the typed expression's type otherwise.
			case _: e.t;
		}
	}

	var ptrType: Null<Ref<AbstractType>> = null;
	public function getPtrType(): Ref<AbstractType> {
		if(ptrType == null) {
			switch(Context.getModule("ucpp.Ptr")[0]) {
				case TAbstract(abRef, _): {
					ptrType = abRef;
				}
				case _: {
					throw "`ucpp.Ptr` does not refer to an abstract type.";
				}
			}
		}
		return ptrType;
	}

	// ----------------------------
	// Stores reflection information for Class<T>.
	// But only generates if necessary.
	var reflectionCpp: Map<String, Array<String>> = [];

	// Used in sub-compilers to add reflection code
	// that is only added to the output if necessary.
	public function addReflectionCpp(filename: String, cpp: String) {
		if(!reflectionCpp.exists(filename)) {
			reflectionCpp.set(filename, []);
		}
		reflectionCpp.get(filename).push(cpp);
	}

	// Called on compilation end to add the
	// reflection code to the output files.
	function generateReflectionInfo() {
		if(IComp.typeUtilHeaderRequired) {
			for(filename => reflectionCppList in reflectionCpp) {
				var content = "// Reflection info\n";
				content += "#include \"" + TypeUtilsHeaderFile + HeaderExt + "\"\n";
				content += "namespace haxe {\n";
				content += reflectionCppList.map(s -> s.tab()).join("\n");
				content += "\n}\n";

				addCompileEndCallback(function() {
					appendToExtraFile(filename, content, DependencyTracker.bottom);
				});
			}
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
		final optionalInfoHeaderName = AnonUtilsHeaderFile + HeaderExt;
		final genAnonStructHeader = IComp.anonHeaderRequired || anonContent.length > 0;

		// Generate anonymous structures header.
		if(genAnonStructHeader) {
			var content = "#pragma once\n\n";
			content += "#include \"" + optionalInfoHeaderName + "\"\n\n";
			content += IComp.compileHeaderIncludes() + "\n\n";
			content += "namespace haxe {\n\n";
			content += anonContent;
			content += "\n}";
			setExtraFile(HeaderFolder + "/" + AnonStructHeaderFile + HeaderExt, content);
		}

		// Generate haxe::optional_info header.
		if(genAnonStructHeader || IComp.anonUtilHeaderRequired) {
			var content = "#pragma once\n\n";
			content += "#include " + IComp.wrapInclude(OptionalInclude[0], OptionalInclude[1]) + "\n";
			content += "#include " + IComp.wrapInclude(SharedPtrInclude[0], SharedPtrInclude[1]) + "\n";
			if(UniquePtrInclude[0] != SharedPtrInclude[0]) {
				content += "#include " + IComp.wrapInclude(UniquePtrInclude[0], UniquePtrInclude[1]) + "\n";
			}
			content += "\n";
			content += AComp.optionalInfoContent() + "\n\n";
			setExtraFile(HeaderFolder + "/" + optionalInfoHeaderName, content);
		}
	}

	// ----------------------------
	// Generate the header containing all the
	// type information used for reflection.
	function generateTypeUtilsHeader() {
		if(IComp.typeUtilHeaderRequired) {
			final headerContent = RComp.typeUtilHeaderContent();

			var content = "#pragma once\n\n";
			content += IComp.compileHeaderIncludes() + "\n\n";
			content += headerContent + "\n\n";
			setExtraFile(HeaderFolder + "/" + TypeUtilsHeaderFile + HeaderExt, content); 
		}
	}

	// ----------------------------
	// Generates the main.cpp file if necessary.
	function generateMainFile() {
		final mainExpr = getMainExpr();
		if(mainExpr != null) {
			IComp.resetAndInitIncludes(true);

			// Compile the expression before compiling the
			// includes so they are all found.
			final cpp = compileExpression(mainExpr);

			var content = IComp.compileCppIncludes() + "\n\n";
			content += "int main() {\n";
			content += cpp.tab() + ";\n";
			content += "\treturn 0;\n";
			content += "}\n";

			setExtraFile(SourceFolder + "/_main_.cpp", content);
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
	function compileNamespaceStart(md: CommonModuleTypeData, combined: Bool = true): String {
		var result = "";
		if(combined) {
			if(md.pack.length > 0) {
				result += "namespace " + md.pack.join("::") + " {\n";
			}
		} else {
			for(p in md.pack) {
				result += "namespace " + p + " {\n";
			}
		}
		if(md.pack.length > 0) result += "\n";
		return result;
	}

	// ----------------------------
	// Compile all namespace closing brackets.
	function compileNamespaceEnd(md: CommonModuleTypeData, combined: Bool = true): String {
		var result = "";
		if(combined) {
			if(md.pack.length > 0) {
				result += "\n}";
			}
		} else {
			for(p in md.pack) {
				result += "\n}";
			}
		}
		return result;
	}

	// ----------------------------
	// Compile standard function-argument syntax
	// for C++ from a TVar and TypedExpr.
	function compileFunctionArgument(arg: { v: TVar, value: Null<TypedExpr> }, pos: Position, noDefaultValue: Bool = false, compilingInCpp: Bool = false, dependent: Bool = false) {
		return compileFunctionArgumentData({ t: arg.v.t, name: arg.v.name }, arg.value, pos, noDefaultValue, compilingInCpp, dependent);
	}

	function compileFunctionArgumentData(data: { t: Type, name: String }, expr: Null<TypedExpr>, pos: Position, noDefaultValue: Bool = false, compilingInCpp: Bool = false, dependent: Bool = false) {
		var result = TComp.compileType(data.t, pos, false, dependent) + " " + compileVarName(data.name);
		if(!noDefaultValue && expr != null) {
			XComp.compilingInHeader = !compilingInCpp;
			result += " = " + compileExpressionOrError(expr);
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

		// Check & compile code from @:headerCode and @:cppFileCode.
		compileFileCodeMeta(defType);

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
					content += "using " + typedefName + " = " + TComp.compileType(defType.type, defType.pos, true) + ";\n";
				} else {
					content += "typedef " + TComp.compileType(defType.type, defType.pos, true) + " " + typedefName + ";\n";
				}
			}
		}
		content += compileNamespaceEnd(defType);

		final headerFilePath = HeaderFolder + "/" + headerFilename;

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
		// Check & compile code from @:headerCode and @:cppFileCode.
		// Even if the abstract itself isn't compiled, it can still
		// add code to an output file using these meta.
		compileFileCodeMeta(absType);

		// Add internal type for compilation
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

	// ----------------------------
	// Compiles the content generated from @:headerCode and @:cppFileCode.
	function compileFileCodeMeta(cd: CommonModuleTypeData, headerPriority: Int = 2, cppFilePriority: Int = 2): Bool {
		if(cd.hasMeta(":headerCode") || cd.hasMeta(":cppFileCode")) {
			final filename = getFileNameFromModuleData(cd);

			final headerOnly = !cd.hasMeta(":cppFileCode");
			IComp.resetAndInitIncludes(headerOnly, [filename + UnboundCompiler.HeaderExt]);
			IComp.handleSpecialIncludeMeta(cd.meta);

			final headerCode = cd.meta.extractStringFromFirstMeta(":headerCode");
			if(headerCode != null) {
				final headerFilePath = HeaderFolder + "/" + filename + HeaderExt;
				
				setExtraFileIfEmpty(headerFilePath, "#pragma once");
				IComp.appendIncludesToExtraFileWithoutRepeats(headerFilePath, IComp.compileHeaderIncludes(), 1);
				appendToExtraFile(headerFilePath, headerCode + "\n", 2);
			}

			final cppCode = cd.meta.extractStringFromFirstMeta(":cppFileCode");
			if(cppCode != null) {
				final srcFilename = SourceFolder + "/" + filename + SourceExt;

				IComp.appendIncludesToExtraFileWithoutRepeats(srcFilename, IComp.compileCppIncludes(), 1);
				appendToExtraFile(srcFilename, cppCode + "\n", 2);
			}
		}

		return false;
	}

	// ----------------------------
	public function getAbstractInner(t: Type): Type {
		return switch(t) {
			case TAbstract(absRef, params): {
				final abs = absRef.get();
				if(abs.hasMeta(":multiType")) {
					Context.followWithAbstracts(t, true);
				} else {
					abs.type;
				}
			}
			case _: throw "Non-abstract passed to UnboundCompiler.getAbstractInner";
		}
	}

	// ----------------------------
	public function getTypedefInner(t: Type): Type {
		return switch(t) {
			case TType(defRef, _): {
				defRef.get().type;
			}
			case _: throw"Non-typedef passed to UnboundCompiler.getTypedefInner";
		}
	}

	// ----------------------------
	var currentDep: Null<DependencyTracker> = null;
	public function setCurrentDep(dep: DependencyTracker) {
		currentDep = dep;
	}

	public function getCurrentDep(): Null<DependencyTracker> {
		return currentDep;
	}

	public function clearDep() {
		currentDep = null;
	}

	public function addDep(t: Null<Type>) {
		if(t != null && currentDep != null) {
			final mt = t.toModuleType();
			if(mt != null) {
				currentDep.addDep(mt);
			}
		}
	}
}

#end
