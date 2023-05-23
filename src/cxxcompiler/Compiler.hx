// =======================================================
// * Compiler
//
// The main compiler. Most of its behavior is split
// between "sub-compilers" in the `subcompilers` package.
// =======================================================

package cxxcompiler;

#if (macro || cxx_runtime)

import reflaxe.helpers.Context; // Use like haxe.macro.Context
import haxe.macro.Expr;
import haxe.macro.Type;

import reflaxe.BaseCompiler;
import reflaxe.PluginCompiler;
import reflaxe.ReflectCompiler;
import reflaxe.data.ClassFuncData;
import reflaxe.data.ClassVarData;
import reflaxe.data.EnumOptionData;

using reflaxe.helpers.BaseTypeHelper;
using reflaxe.helpers.ModuleTypeHelper;
using reflaxe.helpers.NameMetaHelper;
using reflaxe.helpers.NullableMetaAccessHelper;
using reflaxe.helpers.NullHelper;
using reflaxe.helpers.PositionHelper;
using reflaxe.helpers.SyntaxHelper;
using reflaxe.helpers.TypedExprHelper;
using reflaxe.helpers.TypeHelper;

import cxxcompiler.subcompilers.SubCompiler;
import cxxcompiler.subcompilers.Classes;
import cxxcompiler.subcompilers.Enums;
import cxxcompiler.subcompilers.Anon;
import cxxcompiler.subcompilers.Expressions;
import cxxcompiler.subcompilers.Includes;
import cxxcompiler.subcompilers.Reflection;
import cxxcompiler.subcompilers.Dynamic.Dynamic_;
import cxxcompiler.subcompilers.Types;

import cxxcompiler.config.Define;
import cxxcompiler.config.Meta;
import cxxcompiler.other.DependencyTracker;

using cxxcompiler.helpers.DefineHelper;
using cxxcompiler.helpers.MetaHelper;
using cxxcompiler.helpers.CppTypeHelper;

class Compiler extends reflaxe.PluginCompiler<Compiler> {
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
	static final HaxeUtilsHeaderFile: String = "_HaxeUtils";
	static final AnonStructHeaderFile: String = "_AnonStructs";
	static final AnonUtilsHeaderFile: String = "_AnonUtils";
	static final TypeUtilsHeaderFile: String = "_TypeUtils";

	// ----------------------------
	// Required for adding semicolons at the end of each line.
	override function formatExpressionLine(expr: String): String {
		return expr + ";";
	}

	// ----------------------------
	// Required for adding call stack information on each expression.
	override function prefixExpressionContent(expr: TypedExpr, output: String): Null<Array<String>> {
		return if(Define.Callstack.defined() && XComp.trackLinesCallStack) {
			final result = super.prefixExpressionContent(expr, output) ?? [];
			result.push('HCXX_LINE(${expr.pos.line()})');
			return result;
		} else {
			super.prefixExpressionContent(expr, output);
		}
	}

	// ============================
	// * Plugins
	// ============================
	public static function onCompileBegin(callback: (Compiler) -> Void) {
		ReflectCompiler.onCompileBegin(callback);
	}

	// ============================
	// * Sub-Compilers
	// ============================
	var CComp: Classes;
	var EComp: Enums;
	var AComp: Anon;
	var IComp: Includes;
	var RComp: Reflection;
	var DComp: Dynamic_;
	var TComp: Types;
	var XComp: Expressions;

	public function new() {
		super();

		@:nullSafety(Off) final self = this;

		CComp = new Classes(self);
		EComp = new Enums(self);
		AComp = new Anon(self);
		IComp = new Includes(self);
		RComp = new Reflection(self);
		DComp = new Dynamic_(self);
		TComp = new Types(self);
		XComp = new Expressions(self);

		function setup(c: SubCompiler) c.setSubCompilers(CComp, EComp, AComp, IComp, RComp, DComp, TComp, XComp);
		setup(CComp);
		setup(EComp);
		setup(AComp);
		setup(IComp);
		setup(RComp);
		setup(DComp);
		setup(TComp);
		setup(XComp);
	}

	// ----------------------------
	// Called before anything is compiled.
	public override function onCompileStart() {
		// Compile the -main expression if available
		// to load some types to be compiled with
		// Reflaxe's dynamic dce.
		final mainExpr = getMainExpr();
		if(mainExpr != null) {
			IComp.resetAndInitIncludes(true);
			compileExpression(mainExpr);
		}
	}

	// ----------------------------
	// Called after all module types have
	// been passed to this compiler class.
	public override function onCompileEnd() {
		compileAllTypedefs();
		generateMainFile();
		generateReflectionInfo();
		generateAnonStructHeader();
		generateTypeUtilsHeader();
		generateHaxeUtilsHeader();
		generateDynamic();
		copyAdditionalFiles();
	}

	// ----------------------------
	// Called whenever a significant ModuleType
	// is encountered while compiling to 
	// ensure it is #included and compiled.
	public function onModuleTypeEncountered(mt: ModuleType, addToHeader: Bool, blamePosition: Position) {
		final t = TypeHelper.fromModuleType(mt);
		if(t.isExprClass()) return;

		// Add include only if NOT in header OR no forward declare.
		if(!addToHeader || !checkForForwardDeclare(t, blamePosition)) {
			if(addToHeader) {
				addDep(t, blamePosition);
			}
			IComp.addIncludeFromModuleType(mt, addToHeader);
		}

		// Tell BaseCompiler to compile it
		addModuleTypeForCompilation(mt);
	}

	/**
		Checks if the provided type is depending on the current module.

		If it is, let's generate a forward declaration instead of
		including it (to prevent infinite include loop).
	**/
	function checkForForwardDeclare(t: Type, blamePosition: Position) {
		return if(isCurrentDependantOfType(t, blamePosition)) {
			final mt = t.toModuleType();
			if(mt == null) throw "Impossible";
			final cppCls = mt.getCommonData();

			if(!cppCls.isExtern) { // Ignore extern classes (might be repetitive here)
				IComp.addForwardDeclare(mt);
				IComp.addIncludeFromType(t, false);
				IComp.includeMMType(cppCls.getMemoryManagementType(), true);

				// Stack details setup from `isThisDefOfType` from `isCurrentDependantOfType`.
				getCurrentDep()?.addForwardDeclared(mt, DependencyTracker.getDepStackDetails());

				true;
			} else {
				false;
			}
		} else {
			false;
		}
	}

	function isCurrentDependantOfType(t: Type, depReasonPos: Position) {
		final isCppClass = switch(t) {
			case TInst(_.get() => cls, _): !cls.isExtern; // Ignore extern classes
			case TEnum(_.get() => enm, _): !enm.isExtern;
			case _: false;
		}
		if(isCppClass) {
			final dep = getCurrentDep();
			if(dep != null) {
				if(dep.isThisDepOfType(t)) {
					return true;
				}
			}
		}
		return false;
	}

	// ----------------------------
	// Called whenever a significant Type
	// is encountered while compiling to
	// ensure it is #included.
	public function onTypeEncountered(t: Type, addToHeader: Bool, blamePosition: Position) {
		if(t.isExprClass()) return;

		// Add include only if NOT in header OR no forward declare.
		if(!addToHeader || !checkForForwardDeclare(t, blamePosition)) {
			if(addToHeader) {
				addDep(t, blamePosition);
			}
			IComp.addIncludeFromType(t, addToHeader);
		}

		// How it used to work
		// if(addToHeader) {
		// 	addDep(t);
		// 	addDep(Context.followWithAbstracts(t));
		// }

		// Tell BaseCompiler to compile if module type
		final mt = t.toModuleType();
		if(mt != null) {
			addModuleTypeForCompilation(mt);
		}

		switch(t) {
			case TInst(_, params) | TEnum(_, params) | TType(_, params) | TAbstract(_, params): {
				for(p in params) {
					onTypeEncountered(p, addToHeader, blamePosition);
				}
			}
			
			case _: {}
		}

		switch(t) {
			case TType(_, _) | TAbstract(_, _): {
				final followed = Context.follow(t);
				switch(followed) {
					case TAbstract(absRef, _): {
						final inner = getAbstractInner(followed);
						if(!t.equals(inner) && !followed.equals(inner)) {
							onTypeEncountered(inner, addToHeader, blamePosition);
						}
					}
					case _:
				}
			}
			case _:
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
			return tvarTypeOverrides.get(tvar.id).trustMe();
		}
		return tvar.t;
	}

	public function setTVarType(tvar: TVar, t: Type) {
		tvarTypeOverrides.set(tvar.id, t);
	}

	public function getExprType(e: TypedExpr, ignoreCast: Bool = true): Type {
		return switch(e.expr) {
			// Get "this" type"
			case TConst(TThis): {
				if(XComp.thisOverride != null) {
					// Get "this" override type
					getExprType(XComp.thisOverride);
				} else {
					// Ensure "this" is typed as pointer
					TAbstract(getPtrType(), [e.t]);
				}
			}

			// Redirect "tvar" type
			case TLocal(tvar): getTVarType(tvar);

			// Get the internal type for a cast
			case TCast(castExpr, mt) if(ignoreCast): {
				if(mt == null) {
					getExprType(castExpr);
				} else {
					e.t;
				}
			}

			case TBinop(OpSub | OpAdd, e1, e2): {
				final t1 = getExprType(e1);
				final t2 = getExprType(e2);
				return if(t1.isCppNumberType() || t2.isCppNumberType()) {
					CppTypeHelper.findPriorityNumberType(t1, t2) ?? e.t;
				} else {
					e.t;
				}
			}

			// Implements @:redirectType behavior for function return
			case TCall(calledExpr, _): {
				switch(calledExpr.expr) {
					case TField(_, fa): {
						switch(fa) {
							case FInstance(_, _, cfRef) if(cfRef.get().hasMeta(Meta.RedirectType)): {
								getExprType(calledExpr).getTFunReturn() ?? e.t;
							}
							case _: e.t;
						}
					}
					case _: e.t;
				}
			}

			case TField(_, fa): {
				// Implements @:redirectType behavior
				switch(fa) {
					case FInstance(clsRef, _, cfRef): {
						final cf = cfRef.get();
						if(cf.hasMeta(Meta.RedirectType)) {
							final fieldName = cf.meta.extractStringFromFirstMeta(Meta.RedirectType);
							final cls = clsRef.get();
							for(f in cls.fields.get()) {
								if(f.name == fieldName)
									return f.type;
							}
						}
					}
					case _:
				}

				// For some reason, `e.t` is inaccurate when typing a TField expression.
				//
				// This ensures the type attached to the field declaration is used,
				// rather than the possibly incorrect  type Haxe decided to give it.
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

	var nullType: Null<Ref<AbstractType>> = null;
	public function getNullType(): Ref<AbstractType> {
		if(nullType == null) {
			switch(Context.getModule("Null")[0]) {
				case TAbstract(abRef, _): {
					nullType = abRef;
				}
				case _: {
					throw "`Null` does not refer to an abstract type.";
				}
			}
		}
		return nullType.trustMe();
	}

	/**
		Wrap a type with the corresponding memory management
		overriding type.
	**/
	public function wrapWithMMType(type: Type, mmt: MemoryManagementType): Type {
		return switch(mmt) {
			case Value: TAbstract(getValueType(), [type]);
			case UnsafePtr: TAbstract(getPtrType(), [type]);
			case SharedPtr: TAbstract(getSharedPtrType(), [type]);
			case UniquePtr: TAbstract(getUniquePtrType(), [type]);
		}
	}

	var valType: Null<Ref<AbstractType>> = null;
	public function getValueType(): Ref<AbstractType> {
		if(valType == null) {
			switch(Context.getModule("cxx.Value")[0]) {
				case TAbstract(abRef, _): {
					valType = abRef;
				}
				case _: {
					throw "`cxx.Value` does not refer to an abstract type.";
				}
			}
		}
		return valType.trustMe();
	}

	var ptrType: Null<Ref<AbstractType>> = null;
	public function getPtrType(): Ref<AbstractType> {
		if(ptrType == null) {
			switch(Context.getModule("cxx.Ptr")[0]) {
				case TAbstract(abRef, _): {
					ptrType = abRef;
				}
				case _: {
					throw "`cxx.Ptr` does not refer to an abstract type.";
				}
			}
		}
		return ptrType.trustMe();
	}

	var sharedPtrType: Null<Ref<AbstractType>> = null;
	public function getSharedPtrType(): Ref<AbstractType> {
		if(sharedPtrType == null) {
			switch(Context.getModule("cxx.SharedPtr")[0]) {
				case TAbstract(abRef, _): {
					sharedPtrType = abRef;
				}
				case _: {
					throw "`cxx.SharedPtr` does not refer to an abstract type.";
				}
			}
		}
		return sharedPtrType.trustMe();
	}

	var uniquePtrType: Null<Ref<AbstractType>> = null;
	public function getUniquePtrType(): Ref<AbstractType> {
		if(uniquePtrType == null) {
			switch(Context.getModule("cxx.UniquePtr")[0]) {
				case TAbstract(abRef, _): {
					uniquePtrType = abRef;
				}
				case _: {
					throw "`cxx.UniquePtr` does not refer to an abstract type.";
				}
			}
		}
		return uniquePtrType.trustMe();
	}

	var refType: Null<Ref<DefType>> = null;
	public function getRefType(): Ref<DefType> {
		if(refType == null) {
			switch(Context.getModule("cxx.Ref")[0]) {
				case TType(defRef, _): {
					refType = defRef;
				}
				case _: {
					throw "`cxx.Ref` does not refer to an abstract type.";
				}
			}
		}
		return refType.trustMe();
	}

	/**
		If the variable has not explicitly given a memory management
		type to its type, use the memory management type from the
		assigned expression.
	**/
	public function determineTVarType(tvar: TVar, maybeExpr: Null<TypedExpr>) {
		if(maybeExpr != null) {
			final exprType = getExprType(maybeExpr);
			final tmmt = Types.getMemoryManagementTypeFromType(exprType);
			final tvarType = getTVarType(tvar).unwrapNullTypeOrSelf();

			// Check if variable doesn't have explicit memory management type.
			final mt = tvarType.toModuleType();
			if(mt != null && !mt.getCommonData().isOverrideMemoryManagement()) {
				final cmmt = Types.getMemoryManagementTypeFromType(tvarType);
				if(cmmt != tmmt && exprType.valueTypesEqual(tvarType)) {
					final newType = switch(tmmt) {
						// Convert Value types references.
						// This is so if Haxe generates secret variables, they still
						// modify the original object. For example, a static variable
						// using a value type should be modified, NOT a copy modified.
						case Value if(!tvarType.isRef()):
							TType(getRefType(), [wrapWithMMType(tvarType, Value)]);
						case UnsafePtr | SharedPtr | UniquePtr:
							wrapWithMMType(tvarType, tmmt);
						case _:
							null;
					}
					if(newType != null) {
						setTVarType(tvar, newType);
					}
				}
			}
		}
	}

	// ----------------------------
	// Stores reflection information for Class<T>.
	// But only generates if necessary.
	var reflectionClasses: Map<String, Array<Ref<ClassType>>> = [];

	// Used in sub-compilers to add reflection code
	// that is only added to the output if necessary.
	public function addReflectionCpp(filename: String, clsRef: Ref<ClassType>) {
		if(!reflectionClasses.exists(filename)) {
			reflectionClasses.set(filename, []);
		}
		reflectionClasses.get(filename).trustMe().push(clsRef);
	}

	// Called on compilation end to add the
	// reflection code to the output files.
	function generateReflectionInfo() {
		if(IComp.typeUtilHeaderRequired) {
			for(filename => clsRefList in reflectionClasses) {
				var content = "// Reflection info\n";
				content += "#include \"" + TypeUtilsHeaderFile + HeaderExt + "\"\n";
				content += "namespace haxe {\n";
				content += clsRefList.map(clsRef -> RComp.compileClassReflection(clsRef)).map(s -> s.tab()).join("\n");
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

	function generateHaxeUtilsHeader() {
		if(IComp.haxeUtilHeaderRequired) {
			final headerContent = haxeUtilsHeaderContent();

			var content = "#pragma once\n\n";
			content += headerContent + "\n\n";
			setExtraFile(HeaderFolder + "/" + HaxeUtilsHeaderFile + HeaderExt, content); 
		}
	}

	function haxeUtilsHeaderContent() {
		return "#define HX_COMPARISON_OPERATORS(...)\\
	unsigned long _order_id = 0;\\
	static unsigned long generate_order_id() { static unsigned long i = 0; return i++; }\\
	bool operator==(const __VA_ARGS__& other) const { return _order_id == other._order_id; }\\
	bool operator<(const __VA_ARGS__& other) const { return _order_id < other._order_id; }";
	}

	function generateDynamic() {
		if(DComp.enabled) {
			IComp.resetAndInitIncludes(true);
			final headerContent = DComp.dynamicTypeContent();

			if(DComp.exceptionType == null) {
				DComp.exceptionType = Context.getType("haxe.Exception");
			}
			IComp.addIncludeFromType(DComp.exceptionType, false);

			// dynamic/Dynamic.h
			var content = "#pragma once\n\n";
			content += IComp.compileHeaderIncludes() + "\n\n";
			content += headerContent + "\n\n";
			setExtraFile(HeaderFolder + "/dynamic/Dynamic" + HeaderExt, content);

			// _main_.cpp
			var cppContent = "// Implementation for haxe::makeError from dynamic/Dynamic.h\n";
			cppContent += IComp.compileCppIncludes() + "\n\n";
			cppContent += "void haxe::makeError(const char* msg) {\n\tthrow haxe::Exception(msg);\n}";
			appendToExtraFile(SourceFolder + "/_main_.cpp", cppContent, 10);
		}
	}

	// ----------------------------
	// Copies files configured to be added
	// to the output using `cxx.Compiler`.
	function copyAdditionalFiles() {
		#if macro
		for(file in cxx.Compiler.findAllExtraFiles()) {
			final fp = file.path;
			if(sys.FileSystem.exists(fp)) {
				final path = new haxe.io.Path(fp);
				final outPath = (file.includeFolder ? HeaderFolder : SourceFolder) + "/" + path.file + "." + path.ext;
				final content = sys.io.File.getContent(fp);
				setExtraFile(outPath, content);
			}
		}
		#end
	}

	// ----------------------------
	// Generates the main.cpp file if necessary.
	function generateMainFile() {
		final mainExpr = getMainExpr();
		if(mainExpr != null) {
			IComp.resetAndInitIncludes(true);

			// Compile the expressions before compiling the
			// includes so they are all found.
			final cpp = compileExpressionOrError(mainExpr);
			final prependsCpp = prependExpressions.map(compileExpressionOrError);

			var content = IComp.compileCppIncludes() + "\n\n";
			content += "int main(int argc, const char* argv[]) {\n";
			for(pcpp in prependsCpp) {
				content += pcpp.tab() + ";\n";
			}
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

	public static function getFileNameFromModuleData(md: BaseType): String {
		return if(md.hasMeta(Meta.Filename)) {
			md.meta.extractStringFromFirstMeta(Meta.Filename) ?? md.moduleId();
		} else {
			md.moduleId();
		}
	}

	/**
		Compiles the {this} expression for @:nativeFunctionCode.
	**/
	public override function compileNFCThisExpression(expr: TypedExpr, meta: Null<MetaAccess>): String {
		final val = meta.maybeHas(Meta.MakeThisValue);
		return if(meta.maybeHas(Meta.MakeThisNotNull)) {
			val ? XComp.compileExpressionNotNullAsValue(expr) : XComp.compileExpressionNotNull(expr);
		} else {
			val ? XComp.compileExpressionAsValue(expr) : compileExpressionOrError(expr); 
		}
	}

	// ----------------------------
	// Compile the start of all namespaces
	// for the provided module data.
	function compileNamespaceStart(md: BaseType, combined: Bool = true): String {
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
	function compileNamespaceEnd(md: BaseType, combined: Bool = true): String {
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
		return compileFunctionArgumentData(arg.v.t, arg.v.name, arg.value, pos, noDefaultValue, compilingInCpp, dependent);
	}

	function compileFunctionArgumentData(t: Type, name: String, expr: Null<TypedExpr>, pos: Position, noDefaultValue: Bool = false, compilingInCpp: Bool = false, dependent: Bool = false) {
		var result = TComp.compileType(t, pos, false, dependent) + " " + compileVarName(name);
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
	public function compileClassImpl(classType: ClassType, varFields: Array<ClassVarData>, funcFields: Array<ClassFuncData>): Null<String> {
		return CComp.compileClass(classType, varFields, funcFields);
	}

	// ----------------------------
	// Compiles an enum into C++.
	public function compileEnumImpl(enumType: EnumType, options: Array<EnumOptionData>): Null<String> {
		return EComp.compileEnum(enumType, options);
	}

	// ----------------------------
	// Stores typedef to be compiled later.
	var typedefs: Array<{ defType: DefType, mt: ModuleType, filename: String, dep: DependencyTracker }> = [];
	public override function compileTypedef(defType: DefType): Null<String> {
		final filename = getFileNameFromModuleData(defType);
		final mt = getCurrentModule();

		if(mt == null) throw "No current module";

		typedefs.push({
			defType: defType,
			mt: mt,
			filename: filename,
			dep: DependencyTracker.make(mt, filename)
		});

		return null;
	}

	// ----------------------------
	// Compiles an typedef into C++.
	public function compileAllTypedefs() {
		for(t in typedefs) {
			compileTypedefImpl(t.defType, t.mt, t.filename, t.dep);
		}
	}

	public function compileTypedefImpl(defType: DefType, mt: ModuleType, filename: String, dep: DependencyTracker): Null<String> {
		if(defType.hasMeta(Meta.Extern)) {
			return null;
		}

		final t = switch(mt) {
			case TTypeDecl(defRef): TType(defRef, []);
			case _: throw "Impossible";
		}

		// Check & compile code from @:headerCode and @:cppFileCode.
		compileFileCodeMeta(defType);

		// Header filename
		final headerFilename = filename + HeaderExt;

		// Track dependencies
		setCurrentDep(dep);

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
		onTypeEncountered(defType.type, true, defType.pos);

		// Compile content
		var content = "";
		content += compileNamespaceStart(defType);
		switch(defType.type) {
			case TAnonymous(anonRef): {
				IComp.addAnonTypeInclude(true);
				content += AComp.compileNamedAnonTypeDefinition(defType, anonRef);
			}
			case _: {
				// Compile the "type" the typedef is being assigned without any memory management
				// so the mm type can be handled upon construction. Ensures it can be compiled as
				// a value when passing to an anonymous structure.
				final targetType = TComp.compileType(getTypedefInner(t), defType.pos, true);

				final hasParams = defType.params.length > 0;
				if(hasParams || !defType.hasMeta(Meta.CppTypedef)) {
					if(hasParams) {
						content += "template<" + defType.params.map(p -> "typename " + p.name).join(", ") + ">\n";
					}
					content += "using " + typedefName + " = " + targetType + ";\n";
				} else {
					content += "typedef " + targetType + " " + typedefName + ";\n";
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
		final name = defType.name;
		final currentDep = dep;
		addCompileEndCallback(function() {
			final priority = currentDep.getPriority();
			appendToExtraFile(headerFilePath, content, priority);
		});

		// Clear the dependency tracker.
		clearDep();

		return null;
	}

	// ----------------------------
	// Ensures an abstract's internal type is compiled.
	public override function compileAbstract(absType: AbstractType): Null<String> {
		// Check & compile code from @:headerCode and @:cppFileCode.
		// Even if the abstract itself isn't compiled, it can still
		// add code to an output file using these meta.
		compileFileCodeMeta(absType);

		// Append some special code to the cxx.DynamicToString output.
		// The custom string conversion of extern classes with toString
		// functions are handled here.
		//
		// For now, this feature is disabled. But keeping commented just in case.
		// if(absType.pack.length == 1 && absType.pack[0] == "cxx" && absType.name == "DynamicToString") {
		// 	compileExtraDynamicToString(absType);
		// }

		// Add internal type for compilation
		final mt = absType.type.toModuleType();
		if(mt != null) {
			addModuleTypeForCompilation(mt);
		}
		return null;
	}

	// ----------------------------
	// Compile TypedExpr into C++.
	public function compileExpressionImpl(expr: TypedExpr, topLevel: Bool): Null<String> {
		return XComp.compileExpressionToCpp(expr, topLevel);
	}

	// ----------------------------
	// Compiles the content generated from @:headerCode and @:cppFileCode.
	function compileFileCodeMeta(cd: BaseType, headerPriority: Int = 2, cppFilePriority: Int = 2): Bool {
		if(cd.hasMeta(Meta.HeaderCode) || cd.hasMeta(Meta.CppFileCode)) {
			final filename = getFileNameFromModuleData(cd);

			final headerOnly = !cd.hasMeta(Meta.CppFileCode);
			IComp.resetAndInitIncludes(headerOnly, [filename + Compiler.HeaderExt]);
			IComp.handleSpecialIncludeMeta(cd.meta);

			final headerCode = cd.meta.extractStringFromFirstMeta(Meta.HeaderCode);
			if(headerCode != null) {
				final headerFilePath = HeaderFolder + "/" + filename + HeaderExt;
				
				setExtraFileIfEmpty(headerFilePath, "#pragma once");
				IComp.appendIncludesToExtraFileWithoutRepeats(headerFilePath, IComp.compileHeaderIncludes(), 1);
				appendToExtraFile(headerFilePath, headerCode + "\n", 2);
			}

			final cppCode = cd.meta.extractStringFromFirstMeta(Meta.CppFileCode);
			if(cppCode != null) {
				final srcFilename = SourceFolder + "/" + filename + SourceExt;

				IComp.appendIncludesToExtraFileWithoutRepeats(srcFilename, IComp.compileCppIncludes(), 1);
				appendToExtraFile(srcFilename, cppCode + "\n", 2);
			}
		}

		return false;
	}

	// ----------------------------
	// This should be used instead of `AbstractType.type`.
	// Properly unwraps @:multiType.
	public static function getAbstractInner(t: Type): Type {
		return switch(t) {
			case TAbstract(absRef, params): {
				final abs = absRef.get();
				if(abs.hasMeta(":multiType")) {
					Context.followWithAbstracts(t, true);
				} else {
					abs.type;
				}
			}
			case _: throw "Non-abstract passed to Compiler.getAbstractInner";
		}
	}

	// ----------------------------
	// This should be used instead of `DefType.type`.
	// Properly unwraps memory management types and returns the desired type.
	public static function getTypedefInner(t: Type): Type {
		return switch(t) {
			case TType(defRef, _): {
				// In a rare case of conflicting memory management types:
				//
				// typedef MyClassPtr = cxx.Ptr<MyClass>;
				// typedef MyClassPtrVal = cxx.Value<MyClassPtr>; // cxx.Value<cxx.Ptr<MyClass>> ???
				//
				// We assume the highest-level memory management type is desired.
				// As such, `MyClassPtrVal` should actually be treated like `cxx.Value<MyClass>`.
				//
				// This code achieves this by recusively iterating through each typedef and
				// checking if is has an "internal type" that's a typedef, and using that
				// internal type instead of the original memory-managed-wrapped type.
				final defType = defRef.get();
				final internal = defType.type.getInternalType();
				if(!defType.type.isTypedef() && internal.isTypedef()) {
					final unwrapped = switch(internal) {
						case TType(defRef2, _): {
							getTypedefInner(internal).getInternalType();
						}
						case _: {
							internal;
						}
					}
					return defType.type.replaceInternalType(unwrapped);
				}

				// Otherwise, let's just return the inner typedef type.
				defRef.get().type;
			}
			case _: throw "Non-typedef passed to Compiler.getTypedefInner";
		}
	}

	// ----------------------------
	// This is a simple way of managing and configuring the DependencyTracker system.
	//
	// `setCurrentDep`, `getCurrentDep`, & `clearDep` manage the dependency tracker
	// that is being compiled for. These should be called before compiling the
	// content for a module declaration.
	//
	// `addDep` adds a dependency to the current dependency tracker. It can be called
	// from any of the sub-compilers to add a dependency for the current module.
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

	public function addDep(t: Null<Type>, pos: Position) {
		if(t != null && currentDep != null) {
			final mt = t.toModuleType();
			if(mt != null) {
				currentDep.addDep(mt, pos);
			}
		}
	}

	// ----------------------------
	// Prepend expressions are expressions called before the main expression.
	// A static class function can be marked using @:prependToMain and it will
	// be automatically generated at the beginning of the main function.
	var prependExpressions: Array<TypedExpr> = [];

	public function addMainPrependFunction(expr: TypedExpr) {
		if(!prependExpressions.contains(expr)) {
			prependExpressions.push(expr);
		}
	}

	// ----------------------------
	// Find all instances of inline "toString" functions on extern classes.
	// They are stored to be compiled later with cxx.DynamicToString so these
	// extern classes can be given their own print behavior.
	var externToStrings: Map<String, { field: ClassField, mt: ModuleType }> = [];

	function checkForExternToString(mt: ModuleType) {
		final id = mt.getUniqueId();
		if(externToStrings.exists(id)) {
			return;
		}

		// Get the `ClassType` if it's an extern.
		final classType = switch(mt) {
			case TClassDecl(clsRef): {
				final cls = clsRef.get();
				cls.isExtern ? cls : null;
			}
			case _: null;
		}

		// Find an inline toString function field.
		var toStringField = null;
		if(classType != null) {
			for(field in classType.fields.get()) {
				switch(field.kind) {
					case FMethod(MethInline) if(field.name == "toString"): {
						if(field.expr() != null) {
							toStringField = field;
						}
					}
					case _:
				}
			}
		}

		// Store in map for later.
		if(toStringField != null) {
			externToStrings.set(id, { field: toStringField, mt: mt });
		}
	}

	// This function is unused, but keeping around in case decide to achieve
	// something similar in the future!
	//
	// function compileExtraDynamicToString(absType: AbstractType, ) {
	// 	final filename = getFileNameFromModuleData(absType);
	// 	final headerFilePath = HeaderFolder + "/" + filename + HeaderExt;

	// 	addCompileEndCallback(function() {
	// 		IComp.resetAndInitIncludes(true, [filename + Compiler.HeaderExt]);

	// 		var headerCode = [];

	// 		for(_ => fieldData in externToStrings) {
	// 			final classType = switch(fieldData.mt) {
	// 				case TClassDecl(clsRef): clsRef.get();
	// 				case _: null;
	// 			}
	// 			final t = TypeHelper.fromModuleType(fieldData.mt);
	// 			final field = fieldData.field;
	// 			final typeCpp = TComp.compileType(t, field.pos, true);

	// 			final thisExpr = {
	// 				expr: TIdent("value"),
	// 				pos: field.pos,
	// 				t: t
	// 			};

	// 			final e = switch(field.expr().expr) {
	// 				case TFunction(tfunc): {
	// 					tfunc.expr;
	// 				}
	// 				case _: null;
	// 			}

	// 			if(e != null) {
	// 				XComp.setThisOverride(thisExpr);
	// 				final exprCpp = compileExpression(e);
	// 				XComp.clearThisOverride();

	// 				final typeArgs = classType.params.map(p -> "typename " + p.name).join(", ");
	// 				var cpp = "template<" + typeArgs + ">\n";
	// 				cpp += "std::string to_string<" + typeCpp + ">(" + typeCpp + " value) {\n";
	// 				cpp += exprCpp.tab();
	// 				cpp += "\n}";

	// 				headerCode.push(cpp);
	// 			}
	// 		}

	// 		IComp.appendIncludesToExtraFileWithoutRepeats(headerFilePath, IComp.compileHeaderIncludes(), 1);

	// 		appendToExtraFile(headerFilePath, "namespace haxe {\n" + headerCode.join("\n\n") + "\n}\n", 10);
	// 	});
	// }
}

#end
