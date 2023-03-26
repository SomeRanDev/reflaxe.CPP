// =======================================================
// * Compiler_Classes
//
// This sub-compiler is used to handle compiling of all
// class delcarations
// =======================================================

package unboundcompiler.subcompilers;

#if (macro || ucpp_runtime)

import haxe.macro.Type;

import haxe.display.Display.MetadataTarget;

import reflaxe.BaseCompiler;

import unboundcompiler.other.DependencyTracker;

using reflaxe.helpers.NameMetaHelper;
using reflaxe.helpers.NullableMetaAccessHelper;
using reflaxe.helpers.SyntaxHelper;
using reflaxe.helpers.TypeHelper;

using unboundcompiler.helpers.UError;
using unboundcompiler.helpers.UMeta;

@:allow(unboundcompiler.UnboundCompiler)
@:access(unboundcompiler.UnboundCompiler)
@:access(unboundcompiler.subcompilers.Compiler_Includes)
@:access(unboundcompiler.subcompilers.Compiler_Types)
class Compiler_Classes extends SubCompiler {
	public function compileClass(classType: ClassType, varFields: ClassFieldVars, funcFields: ClassFieldFuncs): Null<String> {
		// Init variables
		final variables = [];
		final functions = [];
		final topLevelFunctions = [];
		final cppVariables = [];
		final cppFunctions = [];
		final classTypeRef = switch(Main.getCurrentModule()) {
			case TClassDecl(c): c;
			case _: throw "Impossible";
		}
		final className = TComp.compileClassName(classTypeRef, classType.pos, null, false, true);
		var classNameNS = TComp.compileClassName(classTypeRef, classType.pos, null, true, true);
		if(classNameNS.length > 0) classNameNS += "::";

		final filename = Main.getFileNameFromModuleData(classType);

		final dep = DependencyTracker.make(TClassDecl(classTypeRef), filename);
		Main.setCurrentDep(dep);

		var headerOnly = classType.isHeaderOnly();

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

		var header = "";

		// Meta
		final clsMeta = Main.compileMetadata(classType.meta, MetadataTarget.Class);
		header += clsMeta;

		// Template generics
		if(classType.params.length > 0) {
			headerOnly = true;
			header += "template<" + classType.params.map(p -> "typename " + p.name).join(", ") + ">\n";
		}

		// Class declaration
		header += "class " + className;

		final extendedFrom = [];

		if(classType.superClass != null) {
			final superType = classType.superClass.t;
			Main.onModuleTypeEncountered(TClassDecl(superType), true);
			for(p in classType.superClass.params) {
				Main.onTypeEncountered(p, true);
			}
			Main.superTypeName = TComp.compileClassName(superType, classType.pos, classType.superClass.params, true, true);
			extendedFrom.push(Main.superTypeName);
		}

		for(i in classType.interfaces) {
			final interfaceType = i.t;
			Main.onModuleTypeEncountered(TClassDecl(interfaceType), true);
			for(p in i.params) {
				Main.onTypeEncountered(p, true);
			}
			extendedFrom.push(TComp.compileClassName(interfaceType, classType.pos, i.params, true, true));
		}

		if(extendedFrom.length > 0) {
			header += ": " + extendedFrom.map(e -> "public " + e).join(", ");
		}

		header += " {\npublic:\n";

		var fieldsCompiled = 0;

		// Instance vars
		for(v in varFields) {
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
			final type = TComp.compileType(field.type, field.pos);
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

		// Class functions
		for(f in funcFields) {
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
				className;
			} else if(isDestructor) {
				"~" + className;
			} else {
				Main.compileVarName(field.name);
			}

			var addToCpp = !headerOnly && !isAbstract;

			if(data.ret != null) {
				Main.onTypeEncountered(data.ret, true);
			}
			for(a in data.args) {
				Main.onTypeEncountered(a.t, true);
			}

			final meta = Main.compileMetadata(field.meta, MetadataTarget.ClassField);
			final ret = data.ret == null ? "void" : (data.ret.isDynamic() ? "auto" : TComp.compileType(data.ret, field.pos));

			var prefixNames = [];
			if(isStatic) prefixNames.push("static");
			if(isAbstract) prefixNames.push("virtual");
			final prefix = prefixNames.length > 0 ? (prefixNames.join(" ") + " ") : "";

			if(isDynamic) {
				IComp.addInclude("functional", true, true);

				final dynAddToCpp = !headerOnly && isStatic;
				XComp.compilingInHeader = !dynAddToCpp;
				XComp.compilingForTopLevel = true;
				final callable = Main.compileClassVarExpr(field.expr());
				XComp.compilingForTopLevel = false;
				final assign = " = " + callable;
				final type = "std::function<" + ret + "(" + data.args.map(a -> {
					return TComp.compileType(a.t, field.pos);
				}).join(", ") + ")>";
				var decl = meta + prefix + type + " " + name;
				if(!dynAddToCpp) {
					decl += assign;
				}
				variables.push(decl + ";");
	
				if(dynAddToCpp) {
					cppVariables.push(type + " " + classNameNS + name + assign);
				}

				fieldsCompiled++;
			} else {
				final topLevel = field.hasMeta(":topLevel");
				if(topLevel && !isStatic) {
					field.pos.makeError(TopLevelInstanceFunction);
				}

				final retDecl = (useReturnType ? (ret + " ") : "");

				TComp.enableDynamicToTemplate(classType.params.concat(field.params).map(p -> p.name));

				final argCpp = if(data.tfunc != null) {
					data.tfunc.args.map(a -> Main.compileFunctionArgument(a, field.pos));
				} else {
					data.args.map(a -> Main.compileFunctionArgumentData(a, null, field.pos));
				}
				final argDecl = "(" + argCpp.join(", ") + ")";

				final templateTypes = field.params.map(f -> f.name).concat(TComp.disableDynamicToTemplate());
				final templateDecl = if(templateTypes.length > 0) {
					addToCpp = false;
					"template<" + templateTypes.map(t -> "typename " + t).join(", ") + ">\n";
				} else {
					"";
				}

				XComp.pushReturnType(data.ret);
				final funcDeclaration = meta + (topLevel ? "" : prefix) + retDecl + name + argDecl;
				var content = if(data.expr != null) {
					XComp.compilingInHeader = !addToCpp;
					" {\n" + Main.compileClassFuncExpr(data.expr).tab() + "\n}";
				} else {
					"";
				}
				XComp.popReturnType();
				
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

		XComp.compilingInHeader = false;

		// Source file
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

		// Header file
		{
			final headerFilename = UnboundCompiler.HeaderFolder + "/" + filename + UnboundCompiler.HeaderExt;
			Main.setExtraFileIfEmpty(headerFilename, "#pragma once");

			IComp.appendIncludesToExtraFileWithoutRepeats(headerFilename, IComp.compileHeaderIncludes(), 1);

			if(classType.hasMeta(":headerCode")) {
				final code = classType.meta.extractStringFromFirstMeta(":headerCode");
				if(code != null) {
					Main.appendToExtraFile(headerFilename, code + "\n", 2);
				}
			}

			var result = "";

			if(fieldsCompiled > 0 || classType.hasMeta(":used")) {
				result += Main.compileNamespaceStart(classType);
				result += header;

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

			Main.addCompileEndCallback(function() {
				Main.appendToExtraFile(headerFilename, result + "\n", dep.getPriority());
			});

			Main.addReflectionCpp(headerFilename, RComp.compileClassReflection(classTypeRef));
		}

		// Let the reflection compiler know this class was compiled.
		RComp.addCompiledModuleType(Main.getCurrentModule());

		// Clear the dependency tracker.
		Main.clearDep();

		// We generated the files ourselves with "appendToExtraFile",
		// so we return null so Reflaxe doesn't generate anything itself.
		return null;
	}
}

#end
