// =======================================================
// * Compiler_Classes
//
// This sub-compiler is used to handle compiling of all
// class delcarations
// =======================================================

package unboundcompiler.subcompilers;

#if (macro || ucpp_runtime)

import haxe.macro.Context;
import haxe.macro.Type;

import haxe.display.Display.MetadataTarget;

import reflaxe.BaseCompiler;
import reflaxe.input.ClassHierarchyTracker;

using reflaxe.helpers.DynamicHelper;
using reflaxe.helpers.NameMetaHelper;
using reflaxe.helpers.NullableMetaAccessHelper;
using reflaxe.helpers.SyntaxHelper;
using reflaxe.helpers.TypeHelper;

import unboundcompiler.subcompilers.Compiler_Includes.ExtraFlag;
import unboundcompiler.other.DependencyTracker;

using unboundcompiler.helpers.UError;
using unboundcompiler.helpers.UMeta;

@:allow(unboundcompiler.UnboundCompiler)
@:access(unboundcompiler.UnboundCompiler)
@:access(unboundcompiler.subcompilers.Compiler_Includes)
@:access(unboundcompiler.subcompilers.Compiler_Types)
class Compiler_Classes extends SubCompiler {
	var classType: ClassType;

	var variables: Array<String> = [];
	var functions: Array<String> = [];
	var topLevelFunctions: Array<String> = [];
	var cppVariables: Array<String> = [];
	var cppFunctions: Array<String> = [];

	var extendedFrom: Array<String> = [];

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

	public function compileClass(classType: ClassType, varFields: ClassFieldVars, funcFields: ClassFieldFuncs): Null<String> {
		// Init variables
		initFields(classType);

		// Init includes
		IComp.resetAndInitIncludes(headerOnly, [filename + UnboundCompiler.HeaderExt]);
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

		headerContent = ["", "", ""];

		// Meta
		final clsMeta = Main.compileMetadata(classType.meta, MetadataTarget.Class);
		headerContent[0] += clsMeta;

		// Template generics
		if(classType.params.length > 0) {
			headerOnly = true;
			headerContent[0] += "template<" + classType.params.map(p -> "typename " + p.name).join(", ") + ">\n";
		}

		// Class declaration
		headerContent[0] += "class " + className;

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

		headerContent[2] += " {\npublic:\n";

		// Instance vars
		for(v in varFields) {
			compileVar(v);
		}

		// Class functions
		for(f in funcFields) {
			compileFunction(f);
		}

		XComp.compilingInHeader = false;

		generateOutput();

		// Let the reflection compiler know this class was compiled.
		RComp.addCompiledModuleType(Main.getCurrentModule());

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

		fieldsCompiled = 0;

		classTypeRef = switch(Main.getCurrentModule()) {
			case TClassDecl(c): c;
			case _: throw "Impossible";
		}
		className = TComp.compileClassName(classTypeRef, classType.pos, null, false, true);
		classNameNS = TComp.compileClassName(classTypeRef, classType.pos, null, true, true);
		if(classNameNS.length > 0) classNameNS += "::";

		classNameWParams = className + if(classType.params.length > 0) {
			"<" + classType.params.map(p -> p.name).join(", ") + ">";
		} else {
			"";
		}

		filename = Main.getFileNameFromModuleData(classType);

		// Dependency tracker
		dep = DependencyTracker.make(TClassDecl(classTypeRef), filename);
		if(dep != null) Main.setCurrentDep(dep);

		headerOnly = classType.isHeaderOnly();
		noAutogen = classType.hasMeta(Meta.NoAutogen);
		hasConstructor = false;
	}

	// Compile class var
	function compileVar(v: { isStatic: Bool, read: VarAccess, write: VarAccess, field: ClassField }) {
		final field = v.field;
		final isStatic = v.isStatic;
		final addToCpp = !headerOnly && isStatic;
		final varName = Main.compileVarName(field.name, null, field);
		final cppVal = if(field.expr() != null) {
			XComp.compilingInHeader = headerOnly;
			XComp.compilingForTopLevel = addToCpp;

			// Note to self: should I be using: `Main.compileClassVarExpr(field.expr())`?
			final result = XComp.compileExpressionForType(field.expr(), field.type, true);

			XComp.compilingForTopLevel = false;

			result == null ? "" : result;
		} else {
			"";
		}

		Main.onTypeEncountered(field.type, true);

		final meta = Main.compileMetadata(field.meta, MetadataTarget.ClassField);
		final assign = (cppVal.length == 0 ? "" : (" = " + cppVal));
		final type = TComp.compileType(field.type, field.pos, false, true);
		var decl = meta + (isStatic ? "static " : "") + type + " " + varName;
		if(!addToCpp) {
			decl += assign;
		}
		variables.push(decl + ";");

		if(addToCpp) {
			cppVariables.push(type + " " + classNameNS + varName + assign + ";");
		}

		fieldsCompiled++;
	}

	// Compile class function
	function compileFunction(f: { isStatic: Bool, kind: MethodKind, data: ClassFuncData, field: ClassField }) {
		final field = f.field;
		final data = f.data;

		final isStatic = f.isStatic;
		final isDynamic = f.kind == MethDynamic;
		final isAbstract = field.isAbstract || classType.isInterface;
		final isInstanceFunc = !isStatic && !isDynamic;

		final isConstructor = isInstanceFunc && field.name == "new";
		final isDestructor = isInstanceFunc && field.name == "destructor";
		final useReturnType = !isConstructor && !isDestructor;
		final name = if(isConstructor) {
			hasConstructor = true;
			className;
		} else if(isDestructor) {
			"~" + className;
		} else {
			Main.compileVarName(field.name);
		}

		var addToCpp = !headerOnly && !isAbstract;

		// -----------------
		// Type encounters
		if(data.ret != null) {
			Main.onTypeEncountered(data.ret, true);
		}
		for(a in data.args) {
			Main.onTypeEncountered(a.t, true);
		}

		final meta = Main.compileMetadata(field.meta, MetadataTarget.ClassField);

		// -----------------
		// Compile return type
		final ret = if(data.ret == null) {
			"void";
		} else if(data.ret.isDynamic()) {
			"auto";
		} else {
			final covariant = ClassHierarchyTracker.funcGetCovariantBaseType(classType, field, isStatic);
			if(covariant != null) {
				TComp.compileType(covariant, field.pos, false, true);
			} else {
				TComp.compileType(data.ret, field.pos, false, true);
			}
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
		if(isAbstract || field.hasMeta(Meta.Virtual) || ClassHierarchyTracker.funcHasChildOverride(classType, field, isStatic)) {
			specifiers.push("virtual");
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
				#if eval
				final clsComplex = haxe.macro.ComplexTypeTools.toString(Context.toComplexType(TInst(classTypeRef, []))).split(".");
				final untypedExpr = if(data.args.length == 0) {
					macro $p{clsComplex}.$name();
				} else {
					// Check that the arguments match (Int, ucpp.CArray)
					// First check that there are no more than two required arguments.
					// Next check that the first two arguments match the required types.
					if(
						data.args.map(a -> !a.opt).length <= 2 &&
						Context.unify(data.args[0].t, Context.getType("Int")) &&
						Context.unify(data.args[1].t, Context.getType("ucpp.CArray"))
					) {
						macro $p{clsComplex}.$name(untyped argc, untyped argv);
					} else {
						pos.makeError(MainPrependWrongArguments);
					}
				}

				final typedExpr = Context.typeExpr(untypedExpr);
				Main.addMainPrependFunction(typedExpr);
				#end
			}
		}

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
			final callable = Main.compileClassVarExpr(field.expr());
			XComp.compilingForTopLevel = false;

			// -----------------
			// Compile declaration
			final assign = " = " + callable;
			final type = "std::function<" + ret + "(" + data.args.map(a -> {
				return TComp.compileType(a.t, field.pos, false, true);
			}).join(", ") + ")>";
			var decl = meta + prefix + type + " " + name;
			if(!dynAddToCpp) {
				decl += assign;
			}

			// -----------------
			// Add to output
			variables.push(decl + ";");

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
			// Add single space padding after return type
			final retDecl = (useReturnType ? (ret + " ") : "");

			// -----------------
			// Compile the function arguments
			TComp.enableDynamicToTemplate(classType.params.concat(field.params).map(p -> p.name));

			final argCpp = if(data.tfunc != null) {
				data.tfunc.args.map(a -> Main.compileFunctionArgument(a, field.pos, false, false, true));
			} else {
				data.args.map(a -> Main.compileFunctionArgumentData(a, null, field.pos, false, false, true));
			}
			final argDecl = "(" + argCpp.join(", ") + ")";

			// -----------------
			// Compile the type parameters
			final templateTypes = field.params.map(f -> f.name).concat(TComp.disableDynamicToTemplate());
			final templateDecl = if(templateTypes.length > 0) {
				addToCpp = false;
				"template<" + templateTypes.map(t -> "typename " + t).join(", ") + ">\n";
			} else {
				"";
			}

			// -----------------
			// Compile the function content
			XComp.pushReturnType(data.ret);
			final funcDeclaration = meta + (topLevel ? "" : prefix) + retDecl + name + argDecl;
			var content = if(data.expr != null) {
				XComp.compilingInHeader = !addToCpp;

				// Use initialization list to set _order_id in constructor.
				final constructorInitFields = if(isConstructor && !noAutogen) {
					": _order_id(generate_order_id())";
				} else {
					"";
				}

				constructorInitFields + suffixSpecifiers.join(" ") + " {\n" + Main.compileClassFuncExpr(data.expr).tab() + "\n}";
			} else {
				"";
			}
			XComp.popReturnType();

			// -----------------
			// Add to output
			if(addToCpp) {
				(topLevel ? topLevelFunctions : functions).push(funcDeclaration + ";");

				final argCpp = if(data.tfunc != null) {
					data.tfunc.args.map(a -> Main.compileFunctionArgument(a, field.pos, true));
				} else {
					data.args.map(a -> Main.compileFunctionArgumentData(a, null, field.pos, true));
				}
				final cppArgDecl = "(" + argCpp.join(", ") + ")";
				cppFunctions.push(retDecl + (topLevel ? "" : classNameNS) + name + cppArgDecl + content);
			} else {
				functions.push(templateDecl + funcDeclaration + (isAbstract ? " = 0;" : content));
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
			functions.push("HX_COMPARISON_OPERATORS(" + classNameWParams + ")");
		}

		addExtensionClasses();

		if(extendedFrom.length > 0) {
			headerContent[1] += ": " + extendedFrom.map(e -> "public " + e).join(", ");
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
			final srcFilename = UnboundCompiler.SourceFolder + "/" + filename + UnboundCompiler.SourceExt;
			Main.setExtraFileIfEmpty(srcFilename, "#include \"" + filename + UnboundCompiler.HeaderExt + "\"");

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
		final headerFilename = UnboundCompiler.HeaderFolder + "/" + filename + UnboundCompiler.HeaderExt;
		Main.setExtraFileIfEmpty(headerFilename, "#pragma once");

		IComp.appendIncludesToExtraFileWithoutRepeats(headerFilename, IComp.compileHeaderIncludes(), 1);

		if(classType.hasMeta(Meta.HeaderCode)) {
			final code = classType.meta.extractStringFromFirstMeta(Meta.HeaderCode);
			if(code != null) {
				Main.appendToExtraFile(headerFilename, code + "\n", 2);
			}
		}

		var result = "";

		if(fieldsCompiled > 0 || classType.hasMeta(":used")) {
			result += Main.compileNamespaceStart(classType);
			result += headerContent.join("");

			final varsExist = variables.length > 0;
			if(varsExist) {
				result += variables.join("\n\n").tab() + "\n";
			}

			if(functions.length > 0) {
				result += (varsExist ? "\n" : "") + functions.join("\n\n").tab() + "\n";
			}

			result += "};\n";

			result += Main.compileNamespaceEnd(classType);
		}

		if(topLevelFunctions.length > 0) {
			result += (result.length > 0 ? "\n\n" : "") + topLevelFunctions.join("\n\n");
		}

		final currentDep = dep;
		Main.addCompileEndCallback(function() {
			Main.appendToExtraFile(headerFilename, result + "\n", currentDep != null ? currentDep.getPriority() : DependencyTracker.minimum);
		});

		Main.addReflectionCpp(headerFilename, RComp.compileClassReflection(classTypeRef));
	}
}

#end
