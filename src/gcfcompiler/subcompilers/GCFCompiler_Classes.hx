// =======================================================
// * GCFCompiler_Classes
//
// This sub-compiler is used to handle compiling of all
// class delcarations
// =======================================================

package gcfcompiler.subcompilers;

#if (macro || gcf_runtime)

// import haxe.macro.Context;
// import haxe.macro.Expr;
import haxe.macro.Type;

import haxe.display.Display.MetadataTarget;

import reflaxe.BaseCompiler;

// using reflaxe.helpers.NameMetaHelper;
using reflaxe.helpers.SyntaxHelper;

using gcfcompiler.helpers.GCFError;
using gcfcompiler.helpers.GCFMeta;

@:allow(gcfcompiler.GCFCompiler)
@:access(gcfcompiler.GCFCompiler)
@:access(gcfcompiler.subcompilers.GCFCompiler_Includes)
@:access(gcfcompiler.subcompilers.GCFCompiler_Types)
class GCFCompiler_Classes extends GCFSubCompiler {
	public function compileClass(classType: ClassType, varFields: ClassFieldVars, funcFields: ClassFieldFuncs): Null<String> {
		// Init variables
		final variables = [];
		final functions = [];
		final cppVariables = [];
		final cppFunctions = [];
		final className = TComp.compileClassName(classType, classType.pos, null, false, true);
		var classNameNS = TComp.compileClassName(classType, classType.pos, null, true, true);
		if(classNameNS.length > 0) classNameNS += "::";

		var headerOnly = classType.isHeaderOnly();

		// Init includes
		IComp.resetAndInitIncludes(headerOnly);

		// Ensure no self-reference
		final isValueType = classType.getMemoryManagementType() == Value;
		if(isValueType) {
			for(v in varFields) {
				if(Main.isSameAsCurrentModule(v.field.type)) {
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

		if(classType.superClass != null) {
			Main.superTypeName = TComp.compileClassName(classType.superClass.t.get(), classType.pos, classType.superClass.params);
			header += ": public " + Main.superTypeName;
		}

		header += " {\npublic:\n";

		// Instance vars
		for(v in varFields) {
			final field = v.field;
			final isStatic = v.isStatic;
			final varName = Main.compileVarName(field.name, null, field);
			final cppVal = if(field.expr() != null) {
				Main.compileClassVarExpr(field.expr());
			} else {
				"";
			}
			
			final addToCpp = !headerOnly && isStatic;

			final meta = Main.compileMetadata(field.meta, MetadataTarget.ClassField);
			final assign = (cppVal.length == 0 ? "" : (" = " + cppVal));
			final type = TComp.compileType(field.type, field.pos);
			var decl = meta + (isStatic ? "static " : "") + type + " " + varName;
			if(!addToCpp) {
				decl += assign;
			}
			variables.push(decl);

			if(addToCpp) {
				cppVariables.push(type + " " + classNameNS + varName + assign);
			}
		}

		// Class functions
		for(f in funcFields) {
			final field = f.field;
			final tfunc = f.tfunc;

			final isStatic = f.isStatic;
			final isDynamic = f.kind == MethDynamic;
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

			final addToCpp = !headerOnly;

			final meta = Main.compileMetadata(field.meta, MetadataTarget.ClassField);
			final ret = tfunc.t == null ? "void" : TComp.compileType(tfunc.t, field.pos);
			final prefix = isStatic ? "static " : "";

			if(isDynamic) {
				IComp.addInclude("functional", true, true);

				final dynAddToCpp = !headerOnly && isStatic;
				final callable = Main.compileClassVarExpr(field.expr());
				final assign = " = " + callable;
				final type = "std::function<" + ret + "(" + tfunc.args.map(a -> {
					return TComp.compileType(a.v.t, field.pos);
				}).join(", ") + ")>";
				var decl = meta + prefix + type + " " + name;
				if(!dynAddToCpp) {
					decl += assign;
				}
				variables.push(decl + ";");
	
				if(dynAddToCpp) {
					cppVariables.push(type + " " + classNameNS + name + assign);
				}
			} else {
				final retDecl = (useReturnType ? (ret + " ") : "");
				final argDecl = "(" + tfunc.args.map(a -> Main.compileFunctionArgument(a, field.pos)).join(", ") + ")";
				final funcDeclaration = meta + prefix + retDecl + name + argDecl;
				var content = if(tfunc.expr != null) {
					" {\n" + Main.compileClassFuncExpr(tfunc.expr).tab() + "\n}";
				} else {
					"";
				}
				
				if(addToCpp) {
					functions.push(funcDeclaration + ";");
					final cppArgDecl = "(" + tfunc.args.map(a -> Main.compileFunctionArgument(a, field.pos, true)).join(", ") + ")";
					cppFunctions.push(retDecl + classNameNS + name + cppArgDecl + content);
				} else {
					functions.push(funcDeclaration + content);
				}
			}
		}

		final filename = Main.getFileNameFromModuleData(classType);

		// Source file
		if(!headerOnly && (cppVariables.length > 0 || cppFunctions.length > 0)) {
			final srcFilename = "src/" + filename + GCFCompiler.SourceExt;
			Main.setExtraFileIfEmpty(srcFilename, "#include \"" + filename + GCFCompiler.HeaderExt + "\"");

			Main.appendToExtraFile(srcFilename, IComp.compileCppIncludes(), 1);
			
			var result = "";

			if(cppVariables.length > 0) {
				result += cppVariables.join("\n\n") + "\n\n";
			}

			if(cppFunctions.length > 0) {
				result += cppFunctions.join("\n\n") + "\n";
			}

			Main.appendToExtraFile(srcFilename, result + "\n", 2);
		}

		// Header file
		{
			final headerFilename = "include/" + filename + GCFCompiler.HeaderExt;
			Main.setExtraFileIfEmpty(headerFilename, "#pragma once");

			Main.appendToExtraFile(headerFilename, IComp.compileHeaderIncludes(), 1);

			var result = "";
			result += Main.compileNamespaceStart(classType);
			result += header;

			if(variables.length > 0) {
				result += variables.join("\n\n").tab() + "\n\n";
			}

			if(functions.length > 0) {
				result += functions.join("\n\n").tab() + "\n";
			}

			result += "};\n";

			result += Main.compileNamespaceEnd(classType);

			Main.appendToExtraFile(headerFilename, result + "\n", 2);
		}

		// We generated the files ourselves with "appendToExtraFile",
		// so we return null so Reflaxe doesn't generate anything itself.
		return null;
	}
}

#end
