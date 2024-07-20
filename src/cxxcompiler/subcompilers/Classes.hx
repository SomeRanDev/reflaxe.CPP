// =======================================================
// * Classes
//
// This sub-compiler is used to handle compiling of all
// class delcarations
// =======================================================

package cxxcompiler.subcompilers;

#if (macro || cxx_runtime)

import reflaxe.helpers.Context; // Use like haxe.macro.Context
import haxe.macro.Type;

import haxe.display.Display.MetadataTarget;

import reflaxe.data.ClassFuncArg;
import reflaxe.data.ClassFuncData;
import reflaxe.data.ClassVarData;
import reflaxe.debug.MeasurePerformance;
import reflaxe.input.ClassHierarchyTracker;
import reflaxe.helpers.ExprHelper;

using reflaxe.helpers.ArrayHelper;
using reflaxe.helpers.BaseTypeHelper;
using reflaxe.helpers.ClassTypeHelper;
using reflaxe.helpers.DynamicHelper;
using reflaxe.helpers.ClassFieldHelper;
using reflaxe.helpers.NameMetaHelper;
using reflaxe.helpers.NullableMetaAccessHelper;
using reflaxe.helpers.NullHelper;
using reflaxe.helpers.PositionHelper;
using reflaxe.helpers.SyntaxHelper;
using reflaxe.helpers.TypeHelper;

import cxxcompiler.subcompilers.Includes.ExtraFlag;
import cxxcompiler.config.Define;
import cxxcompiler.config.Meta;
import cxxcompiler.other.DependencyTracker;

using cxxcompiler.helpers.CppTypeHelper;
using cxxcompiler.helpers.DefineHelper;
using cxxcompiler.helpers.Error;
using cxxcompiler.helpers.MetaHelper;

/**
	Structure used in `FunctionCompileContext` to store covariant related data.
**/
typedef FunctionCovariantData = {
	isCovariant: Bool,
	name: String,
	ret: String,
	retVal: String
}

/**
	Structure for storing data for compiling class functions.
**/
typedef FunctionCompileContext = {
	// data
	f: ClassFuncData,
	field: ClassField,
	args: Null<Array<ClassFuncArg>>,

	// flags
	isConstructor: Bool,
	isStatic: Bool,
	isAbstract: Bool,
	useReturnType: Bool,
	addToCpp: Bool,

	// covariance
	covariance: FunctionCovariantData,

	// default constructor
	defaultConstructorExpr: Null<TypedExpr>,

	// pieces
	section: String,
	meta: String,
	ret: String,
	prefix: String,
	name: String,
	headerSuffixSpecifiers: Array<String>,
	suffixSpecifiers: Array<String>,
	prependFieldContent: String,
	appendFieldContent: String,
}

/**
	The compiler component for compiling Haxe classes.
**/
@:allow(cxxcompiler.Compiler)
@:access(cxxcompiler.Compiler)
@:access(cxxcompiler.subcompilers.Includes)
@:access(cxxcompiler.subcompilers.Types)
class Classes extends SubCompiler {
	/**
		A list of extern classes encountered that should be `Dynamic`
		compatible, but haven't been compiled yet because `Dynamic`
		hasn't been encountered yet.

		Once `Dynamic` is found, these classes will be compiled and
		this list will be emptied.
	**/
	var dynamicCompatibleExterns: Array<{ classType: Ref<ClassType>, varFields: Array<ClassVarData>, funcFields: Array<ClassFuncData> }> = [];

	// ---------------------------------------------------
	// Variables that expose the current context
	// of this class...
	// ---------------------------------------------------
	public var currentFunction: Null<ClassFuncData> = null;
	public var superConstructorCall: Null<String> = null;

	// ---------------------------------------------------
	// The following variables are reset for each
	// class that's compiled...
	// ---------------------------------------------------

	/**
		The `ClassType` for the class currently being compiled.
	**/
	@:nullSafety(Off)
	var classType: ClassType;
	
	/**
		Variable declarations compiled into C++ to be added into class
		in header file.

		Mapped by the section they should be stored in "public", "private", etc.
	**/
	var variables: Map<String, Array<String>> = [];

	/**
		Function declarations compiled into C++ to be added into class
		in header file.

		Mapped by the section they should be stored in "public", "private", etc.
	**/
	var functions: Map<String, Array<String>> = [];

	// ---------------------------------------------------
	// Store C++ output for content for the source file (.cpp).
	// ---------------------------------------------------
	var topLevelFunctions: Array<String> = [];
	var cppVariables: Array<String> = [];
	var cppFunctions: Array<String> = [];

	// ---------------------------------------------------
	// Important context information to track
	// ---------------------------------------------------
	var classTypeRef: Null<Ref<ClassType>> = null;
	var className: String = "";
	var classNameNS: String = "";
	var filename: String = "";

	var fieldsCompiled = 0;

	var isExtern: Bool = false;
	var extendedFrom: Array<String> = [];
	var destructorField: Null<ClassFuncData> = null;
	var hadVirtual: Bool = false;
	var hasConstructor: Bool = false;

	// ---------------------------------------------------
	// Cache results of metadata for class
	// ---------------------------------------------------
	var headerOnly: Bool = false;
	var noAutogen: Bool = false;
	
	/**
		The declaration of the class is stored here.

		It's an array so different pieces of content can be injected
		at different points in the class compilation process.

		At the end, it's joined together without anything between
		each element.
	**/
	var headerContent: Array<String> = [];

	/**
		Used in autogen and extension classes.
	**/
	var classNameWParams: String = "";

	/**
		The current `DependencyTracker` for the class being compiled.
	**/
	var dep: Null<DependencyTracker> = null;

	/**
		Called by `cxxcompiler.Compiler` to generate C++ for class.
	**/
	public function compileClass(classType: ClassType, varFields: Array<ClassVarData>, funcFields: Array<ClassFuncData>, maybeClassRef: Null<Ref<ClassType>> = null): Null<String> {
		#if cxx_measure
		final perf = new reflaxe.debug.MeasurePerformance();
		#end
		
		// Handle extern classes
		if(classType.isExtern && maybeClassRef == null) {
			if(classType.hasMeta(Meta.DynamicCompatible)) {
				// If Dynamic isn't confirmed to be used, let's
				// delay generating extern compatibility wrappers.
				if(!DComp.enabled) {
					final clsRef = findClassTypeRef();
					dynamicCompatibleExterns.push({ classType: clsRef, varFields: varFields, funcFields: funcFields });
					return null;
				}
			} else {
				return null;
			}
		}

		// Init variables
		initFields(classType, maybeClassRef);

		// Init includes
		IComp.resetAndInitIncludes(headerOnly, [filename + Compiler.HeaderExt]);
		IComp.handleSpecialIncludeMeta(classType.meta);

		// Ensure no self-reference
		final isValueType = classType.getMemoryManagementType() == Value;
		if(isValueType) {
			for(v in varFields) {
				if(!v.isStatic && Main.isSameAsCurrentModule(v.field.type)) {
					v.field.pos.makeError(ValueSelfRef);
				}
			}
		}

		headerContent = ["", "", "", "", ""];

		// @:prependContent
		final prependContent = classType.getCombinedStringContentOfMeta(Meta.PrependContent);
		headerContent[0] += prependContent;

		// Meta
		final clsMeta = Main.compileMetadata(classType.meta, MetadataTarget.Class);
		headerContent[0] += clsMeta.trustMe();

		// Template generics
		if(classType.params.length > 0) {
			// Generic classes must be header-only in C++
			headerOnly = true;

			// Compile the parameters ["TYPE NAME", ...]
			final templateParams = [];
			for(param in classType.params) {
				final paramType = switch(param.t) {
					// Check if this is a @:const type param.
					// If so, let's translate it into a C++ constant type param.
					case TInst(_.get() => { kind: KTypeParameter(constraints), meta: meta, pos: pos }, _) if(meta.has(":const")): {
						if(constraints.length != 1) {
							// If there are no constraits OR multiple constraits, let C++ infer the type.
							"auto";
						} else {
							// Use the constrait as the template type.
							TComp.compileType(constraints[0], pos, true, true);
						}
					}
					case _: "typename";
				}
				templateParams.push('$paramType ${param.name}');
			}
			
			// Generate the template layout
			headerContent[0] += "template<" + templateParams.join(", ") + ">\n";
		}

		// Class declaration
		final classNamePrefix = classType.meta.extractStringFromFirstMeta(Meta.ClassNamePrefix);
		headerContent[0] += "class " + (classNamePrefix != null ? (classNamePrefix + " ") : "") + className;

		// Super class
		if(classType.superClass != null) {
			final superType = classType.superClass.t;

			// @:passConstTypeParam for super class
			if(classType.hasMeta(Meta.PassConstTypeParam)) {
				final superTypeType = TInst(superType, classType.superClass.params);
				MetaHelper.applyPassConstTypeParam(superTypeType, classType.meta.maybeExtract(Meta.PassConstTypeParam), classType.pos);
			}

			// Encounter super type and its params
			Main.onModuleTypeEncountered(TClassDecl(superType), true, classType.pos);
			for(p in classType.superClass.params) {
				Main.onTypeEncountered(p, true, classType.pos);
			}

			// Compile super type
			Main.superTypeName = TComp.compileClassName(superType, classType.pos, classType.superClass.params, true, true, true);
			if(!superType.get().hasMeta(Meta.IgnoreIfExtended)) {
				extendedFrom.push(Main.superTypeName);
			}
		} else {
			Main.superTypeName = null;
		}

		// Interfaces
		for(i in classType.interfaces) {
			final interfaceType = i.t;
			Main.onModuleTypeEncountered(TClassDecl(interfaceType), true, classType.pos);
			for(p in i.params) {
				Main.onTypeEncountered(p, true, classType.pos);
			}
			if(!interfaceType.get().hasMeta(Meta.IgnoreIfExtended)) {
				extendedFrom.push(TComp.compileClassName(interfaceType, classType.pos, i.params, true, true, true));
			}
		}

		// Normally, "extendedFrom" would be used here to setup all the extended classes.
		// However, some additional extendedFrom classes may be required based on the compiled expressions.
		// So we delay this until later.

		headerContent[2] += " {\n";

		// @:headerClassCode
		if(classType.hasMeta(Meta.HeaderClassCode)) {
			if(!isExtern) {
				final code = classType.meta.extractStringFromAllMeta(Meta.HeaderClassCode);
				if(code.length > 0) {
					headerContent[4] += code.join("\n") + "\n";
				}
			} else {
				classType.meta.getFirstPosition(Meta.HeaderClassCode)?.makeError(CannotUseOnExternClass);
			}
		}

		// Instance vars
		final orderedVarFields = varFields.copy();
		orderedVarFields.sort(function(varData1, varData2) {
			final p1 = varData1.field.type.typePriority();
			final p2 = varData2.field.type.typePriority();
			if(p1 == p2) {
				return varData1.field.name < varData2.field.name ? 1 : -1;
			}
			return p1 - p2 < 0 ? 1 : -1;
		});
		for(v in orderedVarFields) {
			compileVar(v);
		}

		// Class functions
		for(f in funcFields) {
			#if cxx_measure
			final funcPerf = new MeasurePerformance();
			#end

			compileFunction(f);

			#if cxx_measure
			Sys.println(StringTools.lpad(perf.millisecondsString(), " ", 16 + 4) + " Function : " + f.field.name);
			#end
		}

		// Destructor
		if(destructorField != null) {
			compileFunction(destructorField);
		}

		currentFunction = null;

		XComp.compilingInHeader = false;

		generateOutput();

		// Let the reflection compiler know this class was compiled.
		RComp.addCompiledModuleType(Main.getCurrentModule().trustMe());

		// Clear the dependency tracker.
		Main.clearDep();

		#if cxx_measure
		Sys.println(StringTools.lpad(perf.millisecondsString(), " ", 16) + " Type : " + (classType.pack.joinAppend(".") + classType.name));
		#end

		// We generated the files ourselves with "appendToExtraFile",
		// so we return null so Reflaxe doesn't generate anything itself.
		return null;
	}

	function findClassTypeRef() {
		return switch(Main.getCurrentModule()) {
			case TClassDecl(c): c;
			case _: throw "Impossible";
		}
	}

	/**
		Called if the `Dynamic` type is enabled.

		Compiles all cached extern classes that need to have
		`Dynamic` wrappers generated for.
	**/
	public function onDynamicEnabled() {
		if(dynamicCompatibleExterns.length > 0) {
			final externs = dynamicCompatibleExterns.copy();
			dynamicCompatibleExterns = [];

			for(cls in externs) {
				// Extern classes will return `null` anyway, so we can ignore.
				compileClass(cls.classType.get(), cls.varFields, cls.funcFields, cls.classType);
			}
		}
	}

	/**
		Helper for adding the C++ header output of a variable.
	**/
	function addVariable(funcOutput: String, access: String = "public") {
		if(!variables.exists(access)) {
			variables.set(access, []);
		}
		variables.get(access).trustMe().push(funcOutput);
	}

	/**
		Helper for adding the C++ header output of a function.
	**/
	function addFunction(funcOutput: String, access: String = "public") {
		if(!functions.exists(access)) {
			functions.set(access, []);
		}
		functions.get(access).trustMe().push(funcOutput);
	}

	/**
		Initialize fields at the start of `compileClass`.
	**/
	function initFields(classType: ClassType, maybeClassRef: Null<Ref<ClassType>> = null) {
		this.classType = classType;
		variables = [];
		functions = [];
		topLevelFunctions = [];
		cppVariables = [];
		cppFunctions = [];

		extendedFrom = [];

		isExtern = classType.isReflaxeExtern();
		destructorField = null;
		hadVirtual = false;

		fieldsCompiled = 0;

		superConstructorCall = null;

		classTypeRef = maybeClassRef ?? findClassTypeRef();
		className = TComp.compileClassName(classTypeRef, classType.pos, null, false, true);
		final fullClassPath = TComp.compileClassName(classTypeRef, classType.pos, null, true, true);
		classNameNS = fullClassPath.length > 0 ? (fullClassPath + "::") : fullClassPath;

		final wParams = if(classType.params.length > 0) {
			"<" + classType.params.map(p -> p.name).join(", ") + ">";
		} else {
			"";
		}

		classNameWParams = className + wParams;

		DComp.reset(fullClassPath, fullClassPath + wParams, classType, TypeHelper.fromModuleType(TClassDecl(classTypeRef)));

		filename = Compiler.getFileNameFromModuleData(classType);

		// Dependency tracker
		dep = DependencyTracker.make(TClassDecl(classTypeRef), filename);
		if(dep != null) Main.setCurrentDep(dep);

		headerOnly = classType.isHeaderOnly();
		noAutogen = classType.hasMeta(Meta.NoAutogen);
		hasConstructor = false;
	}

	/**
		Compile class variable.
	**/
	function compileVar(v: ClassVarData) {
		final field = v.field;
		final isStatic = v.isStatic;
		final isConstexpr = field.hasMeta(Meta.ConstExpr);
		final addToCpp = !headerOnly && !isConstexpr && isStatic;
		final varName = Main.compileVarName(field.getNameOrNativeName(), null, field);

		// Runtime metadata unsupported at the moment.
		if(varName == "__meta__") {
			return;
		}

		final e = field.expr();
		final cppVal = if(e != null) {
			XComp.compilingInHeader = headerOnly;
			XComp.compilingForTopLevel = addToCpp;

			// Note to self: should I be using: `Main.compileClassVarExpr(field.expr())`?
			final result = XComp.compileExpressionForType(e, field.type, true);

			XComp.compilingForTopLevel = false;

			result ?? "";
		} else if(field.type.isPtr()) {
			Compiler.PointerNullCpp;
		} else {
			"";
		}

		Main.onTypeEncountered(field.type, true, field.pos);

		if(field.hasMeta(Meta.PassConstTypeParam)) {
			MetaHelper.applyPassConstTypeParam(field.type, field.meta.maybeExtract(Meta.PassConstTypeParam), field.pos);
		}

		final type = TComp.compileType(field.type, field.pos, false, true);

		if(!isExtern) {
			if(dep != null) dep.assertCanUseInHeader(field.type, field.pos);

			// Do I need this? Might be more organized to just compile here.
			// final meta = Main.compileMetadata(field.meta, MetadataTarget.ClassField);

			// Find all attributes
			final attributes = [];
			final cppAttributes = [];
			final isConst = field.hasMeta(Meta.Const);
			if(isConst) {
				if(isConstexpr) field.pos.makeError(ConstExprIncompatibleWithConst);
				attributes.push("const");
				cppAttributes.push("const");
			} else if(isConstexpr) {
				attributes.push("constexpr");
			}
			if(isStatic) {
				attributes.push("static");
			}

			// Join attributes together if they exist
			final prefix = attributes.length > 0 ? (attributes.join(" ") + " ") : "";

			// Generate variable C++
			final assign = (cppVal.length == 0 ? "" : (" = " + cppVal));
			var decl = prefix + type + " " + varName;
			if(!addToCpp) {
				decl += assign;
			}
			final section = field.meta.extractStringFromFirstMeta(Meta.ClassSection);
			addVariable(decl + ";", section ?? "public");

			if(addToCpp) {
				final cppPrefix = cppAttributes.length > 0 ? (cppAttributes.join(" ") + " ") : "";
				cppVariables.push(cppPrefix + type + " " + classNameNS + varName + assign + ";");
			}
		}

		if(!classType.hasMeta(Meta.DontGenerateDynamic) && !field.hasMeta(Meta.DontGenerateDynamic)) {
			DComp.addVar(v, type, field.getHaxeName());
		}

		fieldsCompiled++;
	}

	/**
		Compile class function.
	**/
	function compileFunction(f: ClassFuncData) {
		currentFunction = f;

		final field = f.field;

		final ctx: FunctionCompileContext = {
			f: f,
			field: field,
			args: null,

			isStatic: false,
			isAbstract: false,
			isConstructor: false,
			useReturnType: false,
			addToCpp: false,

			covariance: {
				isCovariant: false,
				name: "",
				ret: "",
				retVal: ""
			},

			defaultConstructorExpr: null,

			section: "",
			meta: "",
			ret: "",
			prefix: "",
			name: "",
			headerSuffixSpecifiers: [],
			suffixSpecifiers: [],
			prependFieldContent: "",
			appendFieldContent: ""
		}

		ctx.isStatic = f.isStatic;
		final isDynamic = f.kind == MethDynamic;
		ctx.isAbstract = ctx.field.isAbstract || classType.isInterface;
		final isInstanceFunc = !ctx.isStatic && !isDynamic;

		ctx.isConstructor = (isInstanceFunc && field.name == "new") || (ctx.isStatic && field.hasMeta(Meta.Constructor));
		final isDestructor = isInstanceFunc && field.name == "destructor";

		// If destructor is found for first time, save for later.
		// Need to check for all virtuals before compiling destructor.
		if(isDestructor && destructorField == null) {
			destructorField = f;
			return;
		}

		ctx.useReturnType = !ctx.isConstructor && !isDestructor;
		ctx.name = if(ctx.isConstructor) {
			hasConstructor = true;
			className;
		} else if(isDestructor) {
			"~" + className;
		} else {
			Main.compileVarName(field.getNameOrNativeName());
		}

		ctx.section = field.meta.extractStringFromFirstMeta(Meta.ClassSection) ?? "public";
		ctx.addToCpp = !headerOnly && !ctx.isAbstract;

		// -----------------
		// Type encounters
		if(f.ret != null) {
			Main.onTypeEncountered(f.ret, true, f.field.pos);
			if(dep != null) dep.assertCanUseInHeader(f.ret, f.field.pos);
		}
		for(a in f.args) {
			Main.onTypeEncountered(a.type, true, f.field.pos);
			if(dep != null) dep.assertCanUseInHeader(a.type, f.field.pos);
		}

		ctx.meta = Main.compileMetadata(field.meta, MetadataTarget.ClassField) ?? "";

		// -----------------
		// Track covariance
		ctx.covariance.isCovariant = false;
		ctx.covariance.name = "";
		ctx.covariance.ret = "";
		ctx.covariance.retVal = "";

		// -----------------
		// Compile return type
		ctx.ret = if(f.ret == null) {
			"void";
		} else if(f.ret.isDynamic()) {
			"auto";
		} else if(!ctx.isStatic) {
			final covariant = ClassHierarchyTracker.funcGetCovariantBaseType(classType, field, ctx.isStatic);
			if(covariant != null) {
				final covariantMMT = Types.getMemoryManagementTypeFromType(covariant);
				if(covariantMMT == Value) {
					f.field.pos.makeError(CovarianceRequiresPtrLikeType);
				} else {
					ctx.covariance.isCovariant = true;
					ctx.covariance.name = ctx.name;
					ctx.name += "OG";
					ctx.covariance.ret = TComp.compileType(covariant, field.pos, false, true);
					ctx.covariance.retVal = TComp.compileType(covariant, field.pos, true, true);
				}
			}
			TComp.compileType(f.ret, field.pos, false, true);
		} else {
			TComp.compileType(f.ret, field.pos, false, true);
		}

		// -----------------
		// Function attributes
		final specifiers = [];

		if(ctx.isStatic) {
			specifiers.push("static");
		}
		if(field.hasMeta(Meta.ConstExpr)) {
			specifiers.push("constexpr");
		}
		if(field.hasMeta(Meta.CppInline)) {
			specifiers.push("inline");
		}
		if(!ctx.isStatic && (
				ctx.isAbstract ||
				(isDestructor && hadVirtual) ||
				field.hasMeta(Meta.Virtual) ||
				ClassHierarchyTracker.funcHasChildOverride(classType, field, ctx.isStatic)
			)
		) {
			specifiers.push("virtual");
			hadVirtual = true;
		}

		final customSpecifiers = field.meta.extractPrimtiveFromAllMeta(Meta.Specifier);
		for(specifier in customSpecifiers) {
			if(specifier.isString()) {
				specifiers.push(specifier);
			}
		}

		ctx.prefix = specifiers.length > 0 ? (specifiers.join(" ") + " ") : "";

		// -----------------
		// Function SUFFIX attributes
		if(field.hasMeta(Meta.Const)) {
			if(ctx.isStatic) {
				field.pos.makeError(CannotUseConstOnStatic);
			}
			ctx.suffixSpecifiers.push("const");
			ctx.headerSuffixSpecifiers.push("const");
		}

		if(field.hasMeta(Meta.NoExcept)) {
			ctx.suffixSpecifiers.push("noexcept");
			ctx.headerSuffixSpecifiers.push("noexcept");
		}

		// -----------------
		// Function Header SUFFIX attributes
		if((classType.superClass != null || classType.interfaces.length > 0) && ClassHierarchyTracker.funcIsOverride(f)) {
			ctx.headerSuffixSpecifiers.push("override");
		}

		// -----------------
		// Main function modifiers
		if(field.hasMeta(Meta.PrependToMain)) {
			final entries = field.meta.maybeExtract(Meta.PrependToMain);
			final pos = entries.length > 0 ? entries[0].pos : field.pos;
			if(!ctx.isStatic) {
				pos.makeError(MainPrependOnNonStatic);
			} else {
				// -----------------
				// Convert this static function information into a TypedExpr.
				final name = ctx.name;
				final ct = Context.toComplexType(TInst(classTypeRef.trustMe(), [])).trustMe();
				final clsComplex = haxe.macro.ComplexTypeTools.toString(ct).split(".");
				final untypedExpr = if(f.args.length == 0) {
					macro $p{clsComplex}.$name();
				} else {
					// Check that the arguments match (Int, cxx.CArray)
					// First check that there are no more than two required arguments.
					// Next check that the first two arguments match the required types.
					if(
						f.args.map(a -> !a.opt).length <= 2 &&
						Context.unify(f.args[0].type, Context.getType("Int")) &&
						Context.unify(f.args[1].type, Context.getType("cxx.CArray"))
					) {
						macro $p{clsComplex}.$name(untyped argc, untyped argv);
					} else {
						pos.makeError(MainPrependWrongArguments);
					}
				}

				final typedExpr = Context.typeExpr(untypedExpr);
				Main.addMainPrependFunction(typedExpr);
			}
		}

		ctx.prependFieldContent = field.getCombinedStringContentOfMeta(Meta.PrependContent);
		ctx.appendFieldContent = field.getCombinedStringContentOfMeta(Meta.AppendContent);

		final incrementFields = if(isDynamic) {
			compileDynamicFunction(ctx);
			true;
		} else {
			compileNormalFunction(ctx);
		}

		if(incrementFields) {
			fieldsCompiled++;
		}
	}

	/**
		Processes the function argument list by doing the following:

		* Filters out all arguments with `@:templateArg` metadata.
	**/
	function processArguments(input: Array<ClassFuncArg>, allowTemplateArgs: Bool): Array<ClassFuncArg> {
		final result = [];
		for(arg in input) {
			if(arg.tvar != null && arg.tvar.hasMeta(Meta.TemplateArg)) {
				if(!allowTemplateArgs) {
					arg.tvar.meta.maybeExtract(Meta.TemplateArg)[0].pos.makeError(CannotPassTemplateArgumentHere);
				}
				continue;
			}
			result.push(arg);
		}
		return result;
	}

	/**
		Returns the function arguments from the `FunctionCompileContext`
		context object.
	**/
	function getArguments(ctx: FunctionCompileContext, allowTemplateArgs: Bool = true): Array<ClassFuncArg> {
		if(ctx.args == null) ctx.args = processArguments(ctx.f.args, allowTemplateArgs);
		return ctx.args;
	}

	/**
		Compile dynamic function as a variable containing a function.
	**/
	function compileDynamicFunction(ctx: FunctionCompileContext) {
		final f = ctx.f;
		final field = ctx.field;

		// -----------------
		// Requires #include <functional>
		IComp.addInclude("functional", true, true);

		// -----------------
		// Compile the function content
		final dynAddToCpp = !headerOnly && ctx.isStatic;
		XComp.compilingInHeader = !dynAddToCpp;
		XComp.compilingForTopLevel = true;

		final fieldExpr = field.expr();
		final callable = if(f.expr != null && fieldExpr != null) {
			// Wrap the internal function expression in "TFunction" before compiling...
			final expr = switch(fieldExpr.expr) {
				case TFunction(tfunc): {
					{
						expr: TFunction({
							expr: f.expr.trustMe(),
							args: tfunc.args,
							t: tfunc.t
						}),
						pos: fieldExpr.pos,
						t: fieldExpr.t
					}
				}
				case _: fieldExpr;
			}
			Main.compileClassVarExpr(expr);
		} else {
			Compiler.PointerNullCpp;
		}

		XComp.compilingForTopLevel = false;

		final cppArgs = getArguments(ctx, false).map(a -> {
			return TComp.compileType(a.type, field.pos, false, true);
		});

		if(!isExtern) {
			// -----------------
			// Compile declaration
			final assign = " = " + callable;
			final type = "std::function<" + ctx.ret + "(" + cppArgs.join(", ") + ")>";
			var decl = (ctx.meta ?? "") + ctx.prefix + type + " " + ctx.name;
			if(!dynAddToCpp) {
				decl += assign;
			}

			// -----------------
			// Add to output
			addVariable(ctx.prependFieldContent + decl + ";" + ctx.appendFieldContent, ctx.section);

			if(dynAddToCpp) {
				cppVariables.push(type + " " + classNameNS + ctx.name + assign);
			}
		}
	}

	/**
		Compile non-dynamic functions as actual C++ functions.
	**/
	function compileNormalFunction(ctx: FunctionCompileContext): Bool {
		final field = ctx.field;

		// -----------------
		// Check for @:topLevel and check if valid
		final topLevel = field.hasMeta(Meta.TopLevel);
		if(topLevel) {
			if(ctx.isConstructor) {
				field.pos.makeError(TopLevelConstructor);
			} else if(!ctx.isStatic) {
				field.pos.makeError(TopLevelInstanceFunction);
			}
		}

		// -----------------
		// Compile the function arguments
		if(!isExtern) {
			TComp.enableDynamicToTemplate(classType.params.concat(field.params).map(p -> p.name));
		}

		final argCpp = compileArguments(ctx);

		if(!isExtern) {
			final argDecl = "(" + argCpp.join(", ") + ")";
			final templateDecl = generateTemplateDecl(ctx);

			// -----------------
			// Compile the function content for C++
			final fb = compileFunctionBody(ctx, argDecl, topLevel);
			generateFunctionOutput(ctx, fb.funcDeclaration, fb.content, templateDecl, argDecl, topLevel);
		}

		return topLevel;
	}

	/**
		Compile the function arguments to C++.

		Also registers the function with the Dynamic compiler.
	**/
	function compileArguments(ctx: FunctionCompileContext): Array<String> {
		final argTypes = [];
		final argCpp = [];

		for(arg in getArguments(ctx)) {
			var type = arg.type;

			// If the argument is a front optional, and has conflicting
			// default value, make sure `null` can be passed to it.
			// (Wrap type in Null<T>).
			if(arg.isFrontOptional() && arg.hasConflictingDefaultValue() && arg.tvar != null && !arg.tvar.t.isNull()) {
				type = arg.tvar.t.wrapWithNull();
				Main.setTVarType(arg.tvar, type);
			}

			argTypes.push(type);
			argCpp.push(Main.compileFunctionArgumentData(type, arg.name, arg.expr, ctx.field.pos, arg.isFrontOptional(), false, true));
		}

		// -----------------
		// Register this function to Dynamic compiler
		if(!classType.hasMeta(Meta.DontGenerateDynamic) && !ctx.field.hasMeta(Meta.DontGenerateDynamic)) {
			DComp.addFunc(ctx.f, argTypes, ctx.name);
		}

		return argCpp;
	}

	/**
		Generate basic declaration without content.
		We reuse this for covariant.
	**/
	function generateHeaderDecl(ctx: FunctionCompileContext, name: String, ret: String, argDecl: String, topLevel: Bool) {
		return (ctx.meta ?? "") + (topLevel ? "" : ctx.prefix) + (ctx.useReturnType ? (ret + " ") : "") + name + argDecl;
	}

	/**
		Generate content for covariant function wrapper.
	**/
	function covariantContent(ctx: FunctionCompileContext) {
		final argNames = getArguments(ctx).map(a -> a.name);
		return ctx.suffixSpecifiers.join(" ") + " {\n\treturn std::static_pointer_cast<" + ctx.covariance.retVal + ">(" + ctx.name + "(" + argNames.join(", ") + "));\n}";
	}

	/**
		Compile the code within the function.
	**/
	function compileFunctionBody(ctx: FunctionCompileContext, argDecl: String, topLevel: Bool): { funcDeclaration: String, content: String } {
		final f = ctx.f;
		final field = ctx.field;
		XComp.pushReturnType(f.ret);

		var content = "";
		final funcDeclaration = generateHeaderDecl(ctx, ctx.name, ctx.ret, argDecl, topLevel);

		if(f.expr != null) {
			XComp.compilingInHeader = !ctx.addToCpp;

			// -----------------
			// Optional arguments in front need to be given
			// their default value if they are passed `null`.
			final frontOptionalAssigns = [];
			for(arg in getArguments(ctx)) {
				if(arg.expr != null && arg.isFrontOptional() && arg.hasConflictingDefaultValue()) {
					final t = arg.tvar != null ? Main.getTVarType(arg.tvar) : arg.type;
					frontOptionalAssigns.push('if(!${arg.name}) ${arg.name} = ${XComp.compileExpressionForType(arg.expr, t)};');
				}
			}

			// -----------------
			// Store every section of the function body C++ to be added to the function
			final body = [];

			final useCallStack = Define.Callstack.defined() && !field.hasMeta(Meta.NoCallstack);
			if(useCallStack) {
				#if cxx_custom_callstack
				if(Compiler.CallStackCustomFunction != null) {
					final result = Compiler.CallStackCustomFunction(classType, ctx.name, field, Main);
					if(result != null) {
						body.push(result);
					}
				}
				#else
				IComp.addNativeStackTrace(field.pos);
				body.push(XComp.generateStackTrackCode(classType, ctx.name, field.pos) + ";");
				#end
			}

			if(frontOptionalAssigns.length > 0) {
				body.push(frontOptionalAssigns.join("\n"));
			}

			// -----------------
			// Get expression to compile
			var bodyExpr = f.expr;

			// To be added back, see TODO below...
			// if(ctx.isConstructor) {
			// 	XComp.startTrackingThisFields();
			// }

			// -----------------
			// Use initialization list to set _order_id in constructor.
			final constructorInitFields:Array<String> = [];

			if(ctx.isConstructor) {
				if(!noAutogen) {
					constructorInitFields.push("_order_id(generate_order_id())");
				}

                // -----------------
                // Remove all assignments to `this->` fields in constructor body.
                if(field.hasMeta(Meta.CppcList)) {
                    switch(bodyExpr.expr) {
                        case TBlock(exprs): {
                            var cleanExpressions:Array<haxe.macro.TypedExpr> = exprs.copy();

                            for(ex in exprs) {
                                // trace($type(ex));
                                switch(ex.expr) {
                                    case TBinop(OpAssign, {expr: TField({expr: TConst(TThis)}, name)}, e2): {
                                        switch(e2.expr) {
                                            case TConst(_) | TLocal(_): {
                                                cleanExpressions.remove(ex);

                                                final name_raw = switch(name) {
                                                    case FInstance(_, _, s): s;
                                                    case _: null;
                                                }

                                                final value_raw = switch(e2.expr) {
                                                    case TConst(c): {
                                                        switch(c) {
                                                            case TInt(v): Std.string(v);
                                                            case TFloat(v): v;
                                                            case TString(v): '"' + v + '"';
                                                            case TBool(v): v ? "1" : "0";
                                                            case TNull: "nullptr";
                                                            case _: "0";
                                                        }
                                                    }
                                                    case TLocal(v): v.name;
                                                    case _: { throw "Impossible"; }
                                                }

                                                constructorInitFields.push(name_raw + "(" + value_raw + ")");
                                            }
                                            case _: {}
                                        }
                                    }
                                    case _: {
                                        // trace(ex);
                                    }
                                }
                            }

                            bodyExpr = {
                                expr: TBlock(cleanExpressions),
                                pos: bodyExpr.pos,
                                t: bodyExpr.t
                            };
                        }
                        case _: {}
                    }
                }
            }

			XComp.pushTrackLines(useCallStack);
			body.push(Main.compileClassFuncExpr(bodyExpr));
			XComp.popTrackLines();

			if(superConstructorCall != null) {
				constructorInitFields.unshift(superConstructorCall);
				superConstructorCall = null;
			}

			// -----------------
			// Generate bigger pieces
			final constructorInitFieldsStr = constructorInitFields.length > 0 ? (":\n\t" + constructorInitFields.join(", ") + "\n") : "";
			final suffixSpecifiersStr = getSuffixSpecifiers(ctx, true);
			final space = constructorInitFieldsStr.length == 0 && suffixSpecifiersStr.length == 0 ? " " : "";

			// -----------------
			// Put everything together
			content = constructorInitFieldsStr + suffixSpecifiersStr + space + "{\n" + body.join("\n\n").tab() + "\n}";
		}

		XComp.popReturnType();

		return {
			funcDeclaration: funcDeclaration,
			content: content
		};
	}

	function getHeaderSuffixSpecifiers(ctx: FunctionCompileContext, endSpace: Bool = false) {
		return ctx.headerSuffixSpecifiers.length > 0 ? (" " + ctx.headerSuffixSpecifiers.join(" ") + (endSpace ? " " : "")) : "";
	}

	function getSuffixSpecifiers(ctx: FunctionCompileContext, endSpace: Bool = false) {
		return ctx.suffixSpecifiers.length > 0 ? (" " + ctx.suffixSpecifiers.join(" ") + (endSpace ? " " : "")) : "";
	}

	/**
		Compile the type parameters.
	**/
	function generateTemplateDecl(ctx: FunctionCompileContext): String {
		final templateTypes = ctx.field.params.map(function(t) {
			final typeCpp = {
				// If the type param uses `@:const`, use the constraint as the type.
				final constType = t.t.extractTypeParameterConstType();
				if(constType != null) {
					final pos = switch(t.t) {
						case TInst(_.get() => { pos: pos }, _): pos;
						case _: throw "Impossible since `constType` will be `null` if not TInst.";
					}
					TComp.compileType(constType, pos);
				} else {
					"typename";
				}
			};
			return typeCpp + " " + t.name;
		}).concat(TComp.disableDynamicToTemplate().map(n -> "typename " + n));

		return if(templateTypes.length > 0) {
			ctx.addToCpp = false;
			"template<" + templateTypes.map(t -> t).join(", ") + ">\n";
		} else {
			"";
		};
	}

	/**
		Add normal function to output variables.
	**/
	function generateFunctionOutput(ctx: FunctionCompileContext, funcDeclaration: String, content: String, templateDecl: String, argDecl: String, topLevel: Bool) {
		if(ctx.addToCpp) {
			generateFunctionOutputForCpp(ctx, funcDeclaration, content, argDecl, topLevel);
		} else {
			generateFunctionOutputForHeader(ctx, funcDeclaration, content, templateDecl, argDecl, topLevel);
		}
	}

	/**
		Generate a function in C++ for a source file.
	**/
	function generateFunctionOutputForCpp(ctx: FunctionCompileContext, funcDeclaration: String, content: String, argDecl: String, topLevel: Bool) {
		if(ctx.isConstructor) {
			generateDefaultConstructor(ctx, topLevel);
		}

		final headerContent = ctx.prependFieldContent + funcDeclaration + getHeaderSuffixSpecifiers(ctx) + ";" + ctx.appendFieldContent;
		if(topLevel) {
			topLevelFunctions.push(headerContent);
		} else {
			addFunction(headerContent, ctx.section);
			if(ctx.covariance.isCovariant) {
				final decl = generateHeaderDecl(ctx, ctx.covariance.name, ctx.covariance.ret, argDecl, topLevel);
				addFunction(ctx.prependFieldContent + decl + getSuffixSpecifiers(ctx) + ";" + ctx.appendFieldContent, ctx.section);
			}
		}

		final argCpp = getArguments(ctx).map(a -> {
			// If the type was changed (ex: made to Null<T> if front optional),
			// we need to get the modified version from tvar if possible.
			final type = a.tvar != null ? Main.getTVarType(a.tvar) : a.type;
			return Main.compileFunctionArgumentData(type, a.name, a.expr, ctx.field.pos, true);
		});

		final cppArgDecl = "(" + argCpp.join(", ") + ")";
		cppFunctions.push((ctx.useReturnType ? (ctx.ret + " ") : "") + (topLevel ? "" : classNameNS) + ctx.name + cppArgDecl + content);

		if(ctx.covariance.isCovariant) {
			cppFunctions.push(ctx.covariance.ret + (topLevel ? "" : classNameNS) + ctx.covariance.name + cppArgDecl + covariantContent(ctx));
		}
	}

	/**
		Generate a function in C++ for a header file.
	**/
	function generateFunctionOutputForHeader(ctx: FunctionCompileContext, funcDeclaration: String, content: String, templateDecl: String, argDecl: String, topLevel: Bool) {
		final content = (
			ctx.prependFieldContent +
			templateDecl +
			funcDeclaration +
			getHeaderSuffixSpecifiers(ctx) +
			(ctx.isAbstract ? " = 0;" : content) +
			ctx.appendFieldContent
		);
		addFunction(content, ctx.section);

		if(ctx.covariance.isCovariant) {
			final decl = generateHeaderDecl(ctx, ctx.covariance.name, ctx.covariance.ret, argDecl, topLevel);
			final covarContent = (
				ctx.prependFieldContent +
				templateDecl +
				decl +
				getHeaderSuffixSpecifiers(ctx) +
				(ctx.isAbstract ? " = 0;" : covariantContent(ctx)) +
				ctx.appendFieldContent
			);
			addFunction(covarContent, ctx.section);
		}

		if(ctx.isConstructor) {
			generateDefaultConstructor(ctx, topLevel);
		}
	}

	/**
		Returns `true` if the class currently being compiled is
		expected to generate a second, zero-argument constructor.

		In other words, it has the `@:defaultConstructor` meta.
	**/
	function hasExtraDefaultConstructor() {
		return classType.hasMeta(":defaultConstructor");
	}

	/**
		Generates the default (zero-argument) constructor.
		
		This is added using the `@:defaultConstructor` on a class.
	**/
	function generateDefaultConstructor(ctx: FunctionCompileContext, topLevel: Bool) {
		if(hasExtraDefaultConstructor()) {
			if(topLevel) throw "Impossible"; // Constructors should never be top level

			final superCall = Main.superTypeName != null ? ': ${Main.superTypeName}()' : "";
			final funcDeclaration = generateHeaderDecl(ctx, ctx.name, ctx.ret, "()", topLevel);

			final data = classType.extractPreconstructorFieldAssignments();
			final cpp = if(data != null) {
				final e = data.modifiedConstructor;
				final expr = {
					expr: TBlock(data.expressions),
					pos: e.pos,
					t: e.t
				}

				// Do not use callstack for default constructor
				XComp.pushTrackLines(false);
				final content = Main.compileClassFuncExpr(expr).tab();
				XComp.popTrackLines();

				"{\n" + content + "\n}";
			} else {
				"{}";
			}

			if(ctx.addToCpp) {
				addFunction(funcDeclaration + ";", ctx.section);
				cppFunctions.push('$classNameNS${ctx.name}${ctx.covariance.name}()$superCall $cpp');
			} else {
				addFunction('$funcDeclaration$superCall $cpp', ctx.section);
			}
		}
	}

	/**
		Generate file output.
	**/
	function generateOutput() {
		if(!isExtern) {
			// Auto-generated content
			if(hasComparisonOperators(classType)) {
				IComp.addHaxeUtilHeader(true);
				addFunction("\nHX_COMPARISON_OPERATORS(" + classNameWParams + ")");
			}

			addExtensionClasses();

			if(extendedFrom.length > 0) {
				headerContent[1] += ": " + extendedFrom.map(e -> "public " + e).join(", ");
			}

			if(destructorField == null && hadVirtual) {
				addVariable('virtual ~$className() {}');
			}

			generateSourceFile();
			generateHeaderFile();
		}

		generateReflection();
	}

	/**
		Returns `true` if the provided `ClassType` will have comparison
		operators generated.
	**/
	public static function hasComparisonOperators(classType: ClassType) {
		return !classType.isExtern && classType.constructor != null && !classType.hasMeta(Meta.NoAutogen);
	}

	/**
		Add additional extension classes based on flags and found data.
	**/
	function addExtensionClasses() {
		if(IComp.isExtraFlagOn(ExtraFlag.SharedFromThis)) {
			IComp.addInclude("memory", true, true);
			extendedFrom.push("std::enable_shared_from_this<" + classNameWParams + ">");
		}
	}

	/**
		Source file (.cpp)
	**/
	function generateSourceFile() {
		final cppFileCodeMeta = classType.hasMeta(Meta.CppFileCode);
		if(cppFileCodeMeta || (!headerOnly && (cppVariables.length > 0 || cppFunctions.length > 0))) {
			final srcFilename = Compiler.SourceFolder + "/" + filename + Compiler.SourceExt;
			Main.setExtraFileIfEmpty(srcFilename, "#include \"" + filename + Compiler.HeaderExt + "\"");
			Main.registerSourceFile(srcFilename);

			IComp.appendIncludesToExtraFileWithoutRepeats(srcFilename, IComp.compileCppIncludes(), 1);
			
			if(cppFileCodeMeta) {
				final code = classType.meta.extractStringFromAllMeta(Meta.CppFileCode);
				if(code.length > 0) {
					Main.appendToExtraFile(srcFilename, code.join("\n") + "\n", 2);
				}
			}

			var result = "";

			if(cppVariables.length > 0) {
				result += cppVariables.join("\n\n") + "\n";
			}

			if(cppFunctions.length > 0) {
				result += (result.length > 0 ? "\n" : "") + cppFunctions.join("\n\n");
			}

			Main.appendToExtraFile(srcFilename, result + "\n", 3);
		}
	}

	function shouldGenerateHeader() {
		return fieldsCompiled > 0 || classType.hasMeta(":used") || classType.hasMeta(":keep");
	}

	function getHeaderFilename() {
		return Compiler.HeaderFolder + "/" + filename + Compiler.HeaderExt;
	}

	/**
		Header file (.h)
	**/
	function generateHeaderFile() {
		final headerFilename = getHeaderFilename();
		Main.setExtraFileIfEmpty(headerFilename, "#pragma once");

		if(!shouldGenerateHeader()) {
			return;
		}

		IComp.appendIncludesToExtraFileWithoutRepeats(headerFilename, IComp.compileHeaderIncludes(), 1);
		Main.appendToExtraFile(headerFilename, IComp.compileForwardDeclares(), 2);

		if(classType.hasMeta(Meta.HeaderCode)) {
			final code = classType.meta.extractStringFromAllMeta(Meta.HeaderCode);
			if(code.length > 0) {
				Main.appendToExtraFile(headerFilename, code.join("\n") + "\n", 3);
			}
		}

		var result = "";
		result += Main.compileNamespaceStart(classType);
		result += headerContent.join("");

		final keys: Array<String> = Lambda.array({ iterator: () -> variables.keys() });
		for(fk in functions.keys()) {
			if(!keys.contains(fk)) keys.push(fk);
		}

		for(key in keys) {
			result += key + ":\n";

			var varsExist = false;
			if(variables.exists(key)) {
				final v = variables.get(key).trustMe();
				if(v.length > 0) {
					result += v.join("\n").tab() + "\n";
					varsExist = true;
				}
			}

			if(functions.exists(key)) {
				final f = functions.get(key).trustMe();
				if(f.length > 0) {
					result += (varsExist ? "\n" : "");
					result += f.join("\n").tab() + "\n";
				}
			}
		}

		result += "};";

		// @:appendContent
		final appendContent = classType.getCombinedStringContentOfMeta(Meta.AppendContent);
		if(appendContent.length > 0) {
			result += appendContent;
		}

		result += "\n";

		result += Main.compileNamespaceEnd(classType);

		if(topLevelFunctions.length > 0) {
			result += (result.length > 0 ? "\n\n" : "") + topLevelFunctions.join("\n\n");
		}

		final currentDep = dep;
		final name = classType.name;
		final classTypePos = classType.pos;
		Main.addCompileEndCallback(function() {
			final priority = currentDep != null ? currentDep.getPriority() : DependencyTracker.minimum;
			if(priority == -1) {
				classTypePos.makeError(InfiniteReference(DependencyTracker.getErrorStackDetails()));
			} else {
				Main.appendToExtraFile(headerFilename, result + "\n", priority);
			}
		});
	}

	/**
		Generate reflection and dynamic information in the header file.
	**/
	function generateReflection() {
		if(!shouldGenerateHeader()) {
			return;
		}

		if(classType.hasMeta(Meta.Unreflective)) {
			return;
		}

		final headerFilename = getHeaderFilename();

		if(!classType.hasMeta(Meta.DontGenerateDynamic)) {
			final content = DComp.getDynamicContent();
			final dynFilename = getDynamicFileName(classType);
			Main.addCompileEndCallback(function() {
				if(DComp.enabled) {
					Main.setExtraFileIfEmpty(Compiler.HeaderFolder + "/" + dynFilename, "#pragma once\n\n#include \"Dynamic.h\"");
					Main.appendToExtraFile(Compiler.HeaderFolder + "/" + dynFilename,  content);
					Main.appendToExtraFile(headerFilename, "#include \"" + dynFilename + "\"\n", 9999999);
				}
			});
		}

		Main.addReflectionCpp(headerFilename, classTypeRef.trustMe());
	}

	/**
		Name for header file with reflection info.
	**/
	public static function getReflectionFileName(classType: ClassType) {
		return Compiler.getFileNameFromModuleData(classType) + Compiler.HeaderExt;
	}

	/**
		Name for dynamic header wrapper.
	**/
	public static function getDynamicFileName(classType: ClassType) {
		return "dynamic/Dynamic_" + Compiler.getFileNameFromModuleData(classType) + Compiler.HeaderExt;
	}
}

#end
