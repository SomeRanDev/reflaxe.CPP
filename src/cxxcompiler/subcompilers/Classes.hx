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

import reflaxe.BaseCompiler;
import reflaxe.data.ClassFuncData;
import reflaxe.data.ClassVarData;
import reflaxe.input.ClassHierarchyTracker;

using reflaxe.helpers.DynamicHelper;
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

using cxxcompiler.helpers.DefineHelper;
using cxxcompiler.helpers.Error;
using cxxcompiler.helpers.MetaHelper;

@:allow(cxxcompiler.Compiler)
@:access(cxxcompiler.Compiler)
@:access(cxxcompiler.subcompilers.Includes)
@:access(cxxcompiler.subcompilers.Types)
class Classes extends SubCompiler {
	@:nullSafety(Off) var classType: ClassType;

	/**
		A list of extern classes encountered that should be `Dynamic`
		compatible, but haven't been compiled yet because `Dynamic`
		hasn't been encountered yet.

		Once `Dynamic` is found, these classes will be compiled and
		this list will be emptied.
	**/
	var dynamicCompatibleExterns: Array<{ classType: ClassType, varFields: Array<ClassVarData>, funcFields: Array<ClassFuncData> }> = [];

	public var currentFunction: Null<ClassFuncData> = null;

	public var superConstructorCall: Null<String> = null;

	var variables: Map<String, Array<String>> = [];
	var functions: Map<String, Array<String>> = [];

	function addVariable(funcOutput: String, access: String = "public") {
		if(!variables.exists(access)) {
			variables.set(access, []);
		}
		variables.get(access).trustMe().push(funcOutput);
	}

	function addFunction(funcOutput: String, access: String = "public") {
		if(!functions.exists(access)) {
			functions.set(access, []);
		}
		functions.get(access).trustMe().push(funcOutput);
	}

	var topLevelFunctions: Array<String> = [];
	var cppVariables: Array<String> = [];
	var cppFunctions: Array<String> = [];

	var extendedFrom: Array<String> = [];

	var destructorField: Null<ClassFuncData> = null;
	var hadVirtual: Bool = false;

	var fieldsCompiled = 0;

	var classTypeRef: Null<Ref<ClassType>> = null;
	var className: String = "";
	var classNameNS: String = "";

	// Used in autogen and extension classes
	var classNameWParams: String = "";

	var filename: String = "";

	var dep: Null<DependencyTracker> = null;

	var headerOnly: Bool = false;
	var noAutogen: Bool = false;
	var hasConstructor: Bool = false;

	var headerContent: Array<String> = [];

	public function compileClass(classType: ClassType, varFields: Array<ClassVarData>, funcFields: Array<ClassFuncData>): Null<String> {
		if(classType.isExtern) {
			if(classType.hasMeta(Meta.DynamicCompatible)) {
				// If Dynamic isn't confirmed to be used, let's
				// delay generating extern compatibility wrappers.
				if(!DComp.enabled) {
					dynamicCompatibleExterns.push({ classType: classType, varFields: varFields, funcFields: funcFields });
				}
			} else {
				return null;
			}
		}

		// Init variables
		initFields(classType);

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

		headerContent = ["", "", "", ""];

		// @:prependContent
		final prependContent = classType.getCombinedStringContentOfMeta(Meta.PrependContent);
		headerContent[0] += prependContent;

		// Meta
		final clsMeta = Main.compileMetadata(classType.meta, MetadataTarget.Class);
		headerContent[0] += clsMeta.trustMe();

		// Template generics
		if(classType.params.length > 0) {
			headerOnly = true;
			headerContent[0] += "template<" + classType.params.map(p -> "typename " + p.name).join(", ") + ">\n";
		}

		// Class declaration
		final classNamePrefix = classType.meta.extractStringFromFirstMeta(Meta.ClassNamePrefix);
		headerContent[0] += "class " + (classNamePrefix != null ? (classNamePrefix + " ") : "") + className;

		if(classType.superClass != null) {
			final superType = classType.superClass.t;
			Main.onModuleTypeEncountered(TClassDecl(superType), true);
			for(p in classType.superClass.params) {
				Main.onTypeEncountered(p, true);
			}
			Main.superTypeName = TComp.compileClassName(superType, classType.pos, classType.superClass.params, true, true, true);
			extendedFrom.push(Main.superTypeName);
		}

		for(i in classType.interfaces) {
			final interfaceType = i.t;
			Main.onModuleTypeEncountered(TClassDecl(interfaceType), true);
			for(p in i.params) {
				Main.onTypeEncountered(p, true);
			}
			extendedFrom.push(TComp.compileClassName(interfaceType, classType.pos, i.params, true, true, true));
		}


		// Normally, "extendedFrom" would be used here to setup all the extended classes.
		// However, some additional extendedFrom classes may be required based on the compiled expressions.
		// So we delay this until later.

		headerContent[2] += " {\n";

		// @:headerClassCode
		if(classType.hasMeta(Meta.HeaderClassCode)) {
			final code = classType.meta.extractStringFromFirstMeta(Meta.HeaderClassCode);
			if(code != null) {
				headerContent[3] += code + "\n";
			}
		}

		// Instance vars
		for(v in varFields) {
			compileVar(v);
		}

		// Class functions
		for(f in funcFields) {
			compileFunction(f);
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

		// We generated the files ourselves with "appendToExtraFile",
		// so we return null so Reflaxe doesn't generate anything itself.
		return null;
	}

	// Initialize fields at the start of `compileClass`.
	function initFields(classType: ClassType) {
		this.classType = classType;
		variables = [];
		functions = [];
		topLevelFunctions = [];
		cppVariables = [];
		cppFunctions = [];

		extendedFrom = [];

		destructorField = null;
		hadVirtual = false;

		fieldsCompiled = 0;

		superConstructorCall = null;

		classTypeRef = switch(Main.getCurrentModule()) {
			case TClassDecl(c): c;
			case _: throw "Impossible";
		}
		className = TComp.compileClassName(classTypeRef, classType.pos, null, false, true);
		final fullClassPath = TComp.compileClassName(classTypeRef, classType.pos, null, true, true);
		classNameNS = fullClassPath.length > 0 ? (fullClassPath + "::") : fullClassPath;

		final wParams = if(classType.params.length > 0) {
			"<" + classType.params.map(p -> p.name).join(", ") + ">";
		} else {
			"";
		}

		classNameWParams = className + wParams;

		DComp.reset(fullClassPath, fullClassPath + wParams);

		filename = Main.getFileNameFromModuleData(classType);

		// Dependency tracker
		dep = DependencyTracker.make(TClassDecl(classTypeRef), filename);
		if(dep != null) Main.setCurrentDep(dep);

		headerOnly = classType.isHeaderOnly();
		noAutogen = classType.hasMeta(Meta.NoAutogen);
		hasConstructor = false;
	}

	// Compile class var
	function compileVar(v: ClassVarData) {
		final field = v.field;
		final isStatic = v.isStatic;
		final addToCpp = !headerOnly && isStatic;
		final varName = Main.compileVarName(field.name, null, field);
		final e = field.expr();
		final cppVal = if(e != null) {
			XComp.compilingInHeader = headerOnly;
			XComp.compilingForTopLevel = addToCpp;

			// Note to self: should I be using: `Main.compileClassVarExpr(field.expr())`?
			final result = XComp.compileExpressionForType(e, field.type, true);

			XComp.compilingForTopLevel = false;

			result ?? "";
		} else {
			"";
		}

		Main.onTypeEncountered(field.type, true);

		final meta = Main.compileMetadata(field.meta, MetadataTarget.ClassField);
		final assign = (cppVal.length == 0 ? "" : (" = " + cppVal));
		final type = TComp.compileType(field.type, field.pos, false, true);
		var decl = (meta ?? "") + (isStatic ? "static " : "") + type + " " + varName;
		if(!addToCpp) {
			decl += assign;
		}
		final section = field.meta.extractStringFromFirstMeta(Meta.ClassSection);
		addVariable(decl + ";", section ?? "public");

		if(addToCpp) {
			cppVariables.push(type + " " + classNameNS + varName + assign + ";");
		}

		DComp.addVar(v, type, varName);

		fieldsCompiled++;
	}

	// Compile class function
	function compileFunction(f: ClassFuncData) {
		currentFunction = f;

		final field = f.field;

		final isStatic = f.isStatic;
		final isDynamic = f.kind == MethDynamic;
		final isAbstract = field.isAbstract || classType.isInterface;
		final isInstanceFunc = !isStatic && !isDynamic;

		final isConstructor = isInstanceFunc && field.name == "new";
		final isDestructor = isInstanceFunc && field.name == "destructor";

		// If destructor is found for first time, save for later.
		// Need to check for all virtuals before compiling destructor.
		if(isDestructor && destructorField == null) {
			destructorField = f;
			return;
		}

		final useReturnType = !isConstructor && !isDestructor;
		var name = if(isConstructor) {
			hasConstructor = true;
			className;
		} else if(isDestructor) {
			"~" + className;
		} else {
			Main.compileVarName(field.name);
		}

		var section = field.meta.extractStringFromFirstMeta(Meta.ClassSection);
		if(section == null) section = "public";

		var addToCpp = !headerOnly && !isAbstract;

		// -----------------
		// Type encounters
		if(f.ret != null) {
			Main.onTypeEncountered(f.ret, true);
		}
		for(a in f.args) {
			Main.onTypeEncountered(a.type, true);
		}

		final meta = Main.compileMetadata(field.meta, MetadataTarget.ClassField);

		// -----------------
		// Track covariance
		var isCovariant = false;
		var covariantOGName = "";
		var covariantOGRet = "";
		var covariantOGRetVal = "";

		// -----------------
		// Compile return type
		final ret = if(f.ret == null) {
			"void";
		} else if(f.ret.isDynamic()) {
			"auto";
		} else {
			final covariant = ClassHierarchyTracker.funcGetCovariantBaseType(classType, field, isStatic);
			if(covariant != null) {
				isCovariant = true;
				covariantOGName = name;
				name += "OG";
				covariantOGRet = TComp.compileType(covariant, field.pos, false, true);
				covariantOGRetVal = TComp.compileType(covariant, field.pos, true, true);
			}
			TComp.compileType(f.ret, field.pos, false, true);
		}

		// -----------------
		// Function attributes
		final specifiers = [];

		if(isStatic) {
			specifiers.push("static");
		}
		if(field.hasMeta(Meta.ConstExpr)) {
			specifiers.push("constexpr");
		}
		if(field.hasMeta(Meta.CppInline)) {
			specifiers.push("inline");
		}
		if(isAbstract || (isDestructor && hadVirtual) || field.hasMeta(Meta.Virtual) || ClassHierarchyTracker.funcHasChildOverride(classType, field, isStatic)) {
			specifiers.push("virtual");
			hadVirtual = true;
		}

		final customSpecifiers = field.meta.extractPrimtiveFromAllMeta(Meta.Specifier);
		for(specifier in customSpecifiers) {
			if(specifier.isString()) {
				specifiers.push(specifier);
			}
		}

		final prefix = specifiers.length > 0 ? (specifiers.join(" ") + " ") : "";

		// -----------------
		// Function SUFFIX attributes
		final suffixSpecifiers = [];

		if(field.hasMeta(Meta.NoExcept)) {
			specifiers.push("noexcept");
		}

		// -----------------
		// Main function modifiers
		if(field.hasMeta(Meta.PrependToMain)) {
			final entries = field.meta.maybeExtract(Meta.PrependToMain);
			final pos = entries.length > 0 ? entries[0].pos : field.pos;
			if(!isStatic) {
				pos.makeError(MainPrependOnNonStatic);
			} else {
				// -----------------
				// Convert this static function information into a TypedExpr.
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

		final prependFieldContent = field.getCombinedStringContentOfMeta(Meta.PrependContent);
		final appendFieldContent = field.getCombinedStringContentOfMeta(Meta.AppendContent);

		if(isDynamic) {
			// -----------------
			// Compile dynamic function as a variable containing a function.
			// -----------------

			// -----------------
			// Requires #include <functional>
			IComp.addInclude("functional", true, true);

			// -----------------
			// Compile the function content
			final dynAddToCpp = !headerOnly && isStatic;
			XComp.compilingInHeader = !dynAddToCpp;
			XComp.compilingForTopLevel = true;
			final callable = Main.compileClassVarExpr(field.expr().trustMe());
			XComp.compilingForTopLevel = false;

			// -----------------
			// Compile declaration
			final assign = " = " + callable;
			final type = "std::function<" + ret + "(" + f.args.map(a -> {
				return TComp.compileType(a.type, field.pos, false, true);
			}).join(", ") + ")>";
			var decl = (meta ?? "") + prefix + type + " " + name;
			if(!dynAddToCpp) {
				decl += assign;
			}

			// -----------------
			// Add to output
			addVariable(prependFieldContent + decl + ";" + appendFieldContent, section);

			if(dynAddToCpp) {
				cppVariables.push(type + " " + classNameNS + name + assign);
			}

			fieldsCompiled++;
		} else {
			// -----------------
			// Check for @:topLevel and check if valid
			final topLevel = field.hasMeta(Meta.TopLevel);
			if(topLevel) {
				if(isConstructor) {
					field.pos.makeError(TopLevelConstructor);
				} else if(!isStatic) {
					field.pos.makeError(TopLevelInstanceFunction);
				}
			}

			// -----------------
			// Compile the function arguments
			TComp.enableDynamicToTemplate(classType.params.concat(field.params).map(p -> p.name));

			final argCpp = [];
			final argTypes = [];
			for(arg in f.args) {
				var type = arg.type;

				// If the argument is a front optional, and has conflicing
				// default value, make sure `null` can be passed to it.
				// (Wrap type in Null<T>).
				if(arg.isFrontOptional() && arg.hasConflicingDefaultValue() && arg.tvar != null && !arg.tvar.t.isNull()) {
					type = arg.tvar.t.wrapWithNull();
					Main.setTVarType(arg.tvar, type);
				}

				argCpp.push(Main.compileFunctionArgumentData(type, arg.name, arg.expr, field.pos, arg.isFrontOptional(), false, true));
				argTypes.push(TComp.compileType(type, field.pos, false, true));
			}

			DComp.addFunc(f, argTypes, name);

			final argDecl = "(" + argCpp.join(", ") + ")";

			// -----------------
			// Compile the type parameters
			final templateTypes = field.params.map(f -> f.name).concat(TComp.disableDynamicToTemplate());
			final templateDecl = if(templateTypes.length > 0) {
				addToCpp = false;
				"template<" + templateTypes.map(t -> "typename " + t).join(", ") + ">\n";
			} else {
				"";
			};

			// We reuse this for covariant
			final genFuncDecl = (name: String, ret: String) -> (meta ?? "") + (topLevel ? "" : prefix) + (useReturnType ? (ret + " ") : "") + name + argDecl;

			// -----------------
			// Compile the function content
			XComp.pushReturnType(f.ret);
			final funcDeclaration = genFuncDecl(name, ret);
			var content = if(f.expr != null) {
				XComp.compilingInHeader = !addToCpp;

				// Optional arguments in front need to be given
				// their default value if they are passed `null`.
				final frontOptionalAssigns = [];
				for(arg in f.args) {
					if(arg.expr != null && arg.isFrontOptional() && arg.hasConflicingDefaultValue()) {
						final t = arg.tvar != null ? Main.getTVarType(arg.tvar) : arg.type;
						frontOptionalAssigns.push('if(!${arg.name}) ${arg.name} = ${XComp.compileExpressionForType(arg.expr, t)};');
					}
				}
				
				// Store every section of code to be added to the function
				final code = [];

				final useCallStack = Define.Callstack.defined() && !field.hasMeta(Meta.NoCallstack);
				if(useCallStack) {
					IComp.addNativeStackTrace();
					code.push(XComp.generateStackTrackCode(classType, name, field.pos) + ";");
				}

				if(frontOptionalAssigns.length > 0) {
					code.push(frontOptionalAssigns.join("\n"));
				}

				XComp.pushTrackLines(useCallStack);
				code.push(Main.compileClassFuncExpr(f.expr));
				XComp.popTrackLines();

				// Use initialization list to set _order_id in constructor.
				final constructorInitFields = if(isConstructor && !noAutogen) {
					["_order_id(generate_order_id())"];
				} else {
					[];
				}

				if(superConstructorCall != null) {
					constructorInitFields.unshift(superConstructorCall);
					superConstructorCall = null;
				}

				final constructorInitFieldsStr = constructorInitFields.length > 0 ? (":\n\t" + constructorInitFields.join(", ") + "\n") : "";
				final suffixSpecifiersStr = suffixSpecifiers.length > 0 ? (suffixSpecifiers.join(" ") + " ") : "";

				final space = constructorInitFieldsStr.length == 0 && suffixSpecifiersStr.length == 0 ? " " : "";

				// Put everything together
				constructorInitFieldsStr + suffixSpecifiersStr + space + "{\n" + code.join("\n\n").tab() + "\n}";
			} else {
				"";
			}
			XComp.popReturnType();

			final covariantContent = () -> {
				final argNames = f.args.map(a -> a.name);
				return suffixSpecifiers.join(" ") + " {\n\treturn std::static_pointer_cast<" + covariantOGRetVal + ">(" + name + "(" + argNames.join(", ") + "));\n}";
			}

			// -----------------
			// Add to output
			if(addToCpp) {
				final headerContent = prependFieldContent + funcDeclaration + ";" + appendFieldContent;
				if(topLevel) {
					topLevelFunctions.push(headerContent);
				} else {
					addFunction(headerContent, section);
					if(isCovariant) {
						addFunction(prependFieldContent + genFuncDecl(covariantOGName, covariantOGRet) + ";" + appendFieldContent, section);
					}
				}

				final argCpp = f.args.map(a -> {
					// If the type was changed (ex: made to Null<T> if front optional),
					// we need to get the modified version from tvar if possible.
					final type = a.tvar != null ? Main.getTVarType(a.tvar) : a.type;
					return Main.compileFunctionArgumentData(type, a.name, a.expr, field.pos, true);
				});
				final cppArgDecl = "(" + argCpp.join(", ") + ")";
				cppFunctions.push((useReturnType ? (ret + " ") : "") + (topLevel ? "" : classNameNS) + name + cppArgDecl + content);
				if(isCovariant) {
					cppFunctions.push(covariantOGRet + (topLevel ? "" : classNameNS) + covariantOGName + cppArgDecl + covariantContent());
				}
			} else {
				final content = prependFieldContent + templateDecl + funcDeclaration + (isAbstract ? " = 0;" : content) + appendFieldContent;
				addFunction(content, section);
				if(isCovariant) {
					final covarContent = prependFieldContent + templateDecl + genFuncDecl(covariantOGName, covariantOGRet) + (isAbstract ? " = 0;" : covariantContent()) + appendFieldContent;
					addFunction(covarContent, section);
				}
			}

			if(!topLevel) {
				fieldsCompiled++;
			}
		}
	}

	// Generate file output
	function generateOutput() {
		// Auto-generated content
		if(hasConstructor && !noAutogen) {
			IComp.addHaxeUtilHeader(true);
			addFunction("HX_COMPARISON_OPERATORS(" + classNameWParams + ")");
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

	// Add additional extension classes based on flags and found data.
	function addExtensionClasses() {
		if(IComp.isExtraFlagOn(ExtraFlag.SharedFromThis)) {
			IComp.addInclude("memory", true, true);
			extendedFrom.push("std::enable_shared_from_this<" + classNameWParams + ">");
		}
	}

	// Source file (.cpp)
	function generateSourceFile() {
		if(!headerOnly && (cppVariables.length > 0 || cppFunctions.length > 0)) {
			final srcFilename = Compiler.SourceFolder + "/" + filename + Compiler.SourceExt;
			Main.setExtraFileIfEmpty(srcFilename, "#include \"" + filename + Compiler.HeaderExt + "\"");

			IComp.appendIncludesToExtraFileWithoutRepeats(srcFilename, IComp.compileCppIncludes(), 1);
			
			var result = "";

			if(cppVariables.length > 0) {
				result += cppVariables.join("\n\n") + "\n";
			}

			if(cppFunctions.length > 0) {
				result += (result.length > 0 ? "\n" : "") + cppFunctions.join("\n\n");
			}

			Main.appendToExtraFile(srcFilename, result + "\n", 2);
		}
	}

	// Header file (.h)
	function generateHeaderFile() {
		if(fieldsCompiled <= 0 && !classType.hasMeta(":used")) {
			return;
		}

		final headerFilename = Compiler.HeaderFolder + "/" + filename + Compiler.HeaderExt;
		Main.setExtraFileIfEmpty(headerFilename, "#pragma once");

		IComp.appendIncludesToExtraFileWithoutRepeats(headerFilename, IComp.compileHeaderIncludes(), 1);

		if(classType.hasMeta(Meta.HeaderCode)) {
			final code = classType.meta.extractStringFromFirstMeta(Meta.HeaderCode);
			if(code != null) {
				Main.appendToExtraFile(headerFilename, code + "\n", 2);
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
					result += v.join("\n\n").tab() + "\n";
					varsExist = true;
				}
			}

			if(functions.exists(key)) {
				final f = functions.get(key).trustMe();
				if(f.length > 0) {
					result += (varsExist ? "\n" : "");
					result += f.join("\n\n").tab() + "\n";
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
		Main.addCompileEndCallback(function() {
			Main.appendToExtraFile(headerFilename, result + "\n", currentDep != null ? currentDep.getPriority() : DependencyTracker.minimum);
		});

		final content = DComp.getDynamicContent(classType);
		final dynFilename = "dynamic/Dynamic_" + filename + Compiler.HeaderExt;
		Main.addCompileEndCallback(function() {
			if(DComp.enabled) {
				Main.setExtraFileIfEmpty(Compiler.HeaderFolder + "/" + dynFilename, "#pragma once\n\n#include \"Dynamic.h\"");
				Main.appendToExtraFile(Compiler.HeaderFolder + "/" + dynFilename,  content);
				Main.appendToExtraFile(headerFilename, "#include \"" + dynFilename + "\"\n", 9999999);
			}
		});

		Main.addReflectionCpp(headerFilename, classTypeRef.trustMe());
	}
}

#end
