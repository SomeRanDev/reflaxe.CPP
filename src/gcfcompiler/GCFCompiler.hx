package gcfcompiler;

#if (macro || gcf_runtime)

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

import haxe.display.Display.MetadataTarget;

import reflaxe.BaseCompiler;
import reflaxe.compiler.EverythingIsExprSanitizer;
import reflaxe.helpers.OperatorHelper;

using reflaxe.helpers.BaseCompilerHelper;
using reflaxe.helpers.ClassTypeHelper;
using reflaxe.helpers.SyntaxHelper;
using reflaxe.helpers.ModuleTypeHelper;
using reflaxe.helpers.NameMetaHelper;
using reflaxe.helpers.NullableMetaAccessHelper;
using reflaxe.helpers.OperatorHelper;
using reflaxe.helpers.TypedExprHelper;
using reflaxe.helpers.TypeHelper;

class GCFCompiler extends reflaxe.BaseCompiler {
	static final headerExt: String = ".h";

	// ----------------------------
	// Required for adding semicolons at the end of each line.
	override function formatExpressionLine(expr: String): String {
		return if(!StringTools.endsWith(StringTools.trim(expr), "}")) {
			expr + ";";
		} else {
			expr;
		}
	}

	// ----------------------------
	// Functions for compiling type names.
	function compileModuleTypeName(typeData: { > NameAndMeta, pack: Array<String> }, pos: Position, params: Null<Array<Type>> = null, useNamespaces: Bool = true): String {
		return if(typeData.hasMeta(":native")) {
			var result = typeData.getNameOrNative();
			result = StringTools.replace(result, "{this}", typeData.name);
			if(params != null && params.length > 0) {
				for(i in 0...params.length) {
					result = StringTools.replace(result, "{arg" + i + "}", compileType(params[i], pos));
				}
			}
			result;
		} else {
			final prefix = (useNamespaces ? typeData.pack.join("::") + "::" : "");
			compileTypeNameWithParams(prefix + typeData.getNameOrNativeName(), pos, params);
		}
	}

	function compileClassName(classType: ClassType, pos: Position, params: Null<Array<Type>> = null, useNamespaces: Bool = true): String {
		return compileModuleTypeName(classType, pos, params, useNamespaces);
	}

	function compileEnumName(enumType: EnumType, pos: Position, params: Null<Array<Type>> = null, useNamespaces: Bool = true): String {
		return compileModuleTypeName(enumType, pos, params, useNamespaces);
	}

	function compileDefName(defType: DefType, pos: Position, params: Null<Array<Type>> = null, useNamespaces: Bool = true): String {
		return compileModuleTypeName(defType, pos, params, useNamespaces);
	}

	function compileTypeNameWithParams(name: String, pos: Position, params: Null<Array<Type>> = null): Null<String> {
		if(params == null || params.length == 0) {
			return name;
		}
		return name + "<" + params.map(p -> compileTypeSafe(p, pos)).join(", ") + ">";
	}

	function compileTypeSafe(t: Null<Type>, pos: Position): String {
		if(t == null) {
			Context.error("GCFCompiler.compileTypeSafe was passed 'null'. Unknown type detected??", pos);
		}
		final result = compileType(t, pos);
		if(result == null) {
			Context.error("Could not compile type: " + t, pos);
		}
		return result;
	}

	// ----------------------------
	// Compiles the provided type.
	// Position must be provided for error reporting.
	function compileType(t: Null<Type>, pos: Position): Null<String> {
		return switch(t) {
			case null: {
				null;
			}
			case TMono(t3): {
				if(t3.get() != null) {
					compileTypeSafe(t3.get(), pos);
				} else {
					null;
				}
			}
			case TEnum(enumRef, params): {
				compileEnumName(enumRef.get(), pos, params);
			}
			case TInst(clsRef, params): {
				compileClassName(clsRef.get(), pos, params);
			}
			case TFun(args, ret): {
				"std::function<" + compileTypeSafe(ret, pos) + "(" + args.map(a -> compileTypeSafe(a.t, pos)).join(", ") + ")>";
			}
			case TAnonymous(anonRef): {
				"struct {\n" + anonRef.get().fields.map(f -> (compileTypeSafe(f.type, pos) + " " + compileVarName(f.name) + ";").tab()).join("\n") + "\n}";
			}
			case TDynamic(t3): {
				if(t3 == null) {
					Context.error("Dynamic not supported", pos);
				} else {
					compileTypeSafe(t3, pos);
				}
			}
			case TLazy(f): {
				compileTypeSafe(f(), pos);
			}
			case TAbstract(absRef, params): {
				final prim = if(params.length == 0) {
					switch(absRef.get().name) {
						case "Void": "void";
						case "Int": "int";
						case "Float": "double";
						case "Single": "float";
						case "Bool": "bool";
						case "Any": "void*";
						case _: null;
					}
				} else {
					null;
				}

				if(prim != null) {
					prim;
				} else {
					switch(absRef.get().name) {
						case "Null" if(params.length == 1): {
							"std::optional<" + compileTypeSafe(params[0], pos) + ">";
						}
						case _: {
							compileTypeSafe(absRef.get().type, pos);
						}
					}
				}
			}
			case TType(defRef, params): {
				compileDefName(defRef.get(), pos, params);
			}
		}
	}

	// ----------------------------
	// Store list of includes.
	var headerIncludes: Array<String>;
	var cppIncludes: Array<String>;

	// ----------------------------
	// Add include while compiling code.
	function addInclude(include: String, header: Bool, triangleBrackets: Bool = false) {
		function add(arr: Array<String>, inc: String) {
			if(!arr.contains(inc)) {
				arr.push(inc);
			}
		}

		final includeStr = if(!triangleBrackets) { "\"" + include + "\""; } else { "<" + include + ">"; }
		add(header ? headerIncludes : cppIncludes, includeStr);
	}

	// ----------------------------
	// Returns true if the provided ModuleType should
	// not generate an include when used.
	function isNoIncludeType(mt: ModuleType): Bool {
		return switch(mt) {
			case TAbstract(_): true;
			case _: false;
		}
	}

	// ----------------------------
	// Add include based on the provided Type.
	function addIncludeFromType(t: Type, header: Bool) {
		addIncludeFromModuleType(t.toModuleType(), header);
	}

	function addIncludeFromModuleType(mt: Null<ModuleType>, header: Bool) {
		if(isNoIncludeType(mt)) return;

		if(mt != null) {
			// Add include from extracted metadata entry parameters.
			// Returns true if successful.
			function addMetaEntryInc(params: Array<Dynamic>): Bool {
				if(params != null && params.length > 0 && Std.isOfType(params[0], String)) {
					addInclude(params[0], header, params[1] == true);
					return true;
				}
				return false;
			}

			// Add our "main" include if @:noInclude is absent.
			// First look for and use @:include, otherwise, use default header include.
			final cd = mt.getCommonData();
			if(!cd.hasMeta(":noInclude")) {
				final includeOverride = cd.meta.extractParamsFromFirstMeta(":include");
				if(!addMetaEntryInc(includeOverride)) {
					if(!cd.isExtern) {
						addInclude(getFileNameFromModuleData(cd) + headerExt, header, false);
					}
				}
			}

			// Additional header files can be added using @:addInclude.
			final additionalIncludes = cd.meta.extractParamsFromAllMeta(":addInclude");
			for(inc in additionalIncludes) {
				addMetaEntryInc(inc);
			}
		}
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
		return md.moduleId();
	}

	// ----------------------------
	// Clears include arrays and fills
	// them with the current type usage data.
	function resetAndInitIncludes(onlyHeader: Bool = false) {
		// Reset include lists
		headerIncludes = [];
		cppIncludes = [];

		// "getTypeUsage" returns information on all
		// the types used by this ClassType.
		// Let's add them to our includes.
		final typeUsage = getTypeUsage();
		for(level => moduleTypes in typeUsage) {
			if(level >= Constructed) {
				for(mt in moduleTypes) {
					addIncludeFromModuleType(mt, onlyHeader || level >= FunctionDeclaration);
				}
			}
		}
	}

	// ----------------------------
	// Stores the super class's name so we can use
	// it when calling "super" functions.
	var superTypeName: String = "";

	// ----------------------------
	// Compiles a class into C++.
	public function compileClassImpl(classType: ClassType, varFields: ClassFieldVars, funcFields: ClassFieldFuncs): Null<String> {
		// Init variables
		final variables = [];
		final functions = [];
		final cppVariables = [];
		final cppFunctions = [];
		final className = compileClassName(classType, classType.pos, null, false);
		final classNameNS = compileClassName(classType, classType.pos, null, true);

		var headerOnly = classType.hasMeta(":headerOnly");

		// Init includes
		resetAndInitIncludes(headerOnly);

		var header = "";

		// Meta
		final clsMeta = compileMetadata(classType.meta, MetadataTarget.Class);
		header += clsMeta;

		// Template generics
		if(classType.params.length > 0) {
			headerOnly = true;
			header += "template<" + classType.params.map(p -> "typename " + p.name).join(", ") + ">\n";
		}

		// Class declaration
		header += "class " + className;

		if(classType.superClass != null) {
			superTypeName = compileClassName(classType.superClass.t.get(), classType.pos, classType.superClass.params);
			header += ": public " + superTypeName;
		}

		header += " {\npublic:\n";

		// Instance vars
		for(v in varFields) {
			final field = v.field;
			final isStatic = v.isStatic;
			final varName = compileVarName(field.name, null, field);
			final cppVal = if(field.expr() != null) {
				compileClassVarExpr(field.expr());
			} else {
				"";
			}
			
			final addToCpp = !headerOnly && isStatic;

			final meta = compileMetadata(field.meta, MetadataTarget.ClassField);
			final assign = (cppVal.length == 0 ? "" : (" = " + cppVal));
			final type = compileTypeSafe(field.type, field.pos);
			var decl = meta + (isStatic ? "static " : "") + type + " " + varName;
			if(!addToCpp) {
				decl += assign;
			}
			variables.push(decl);

			if(addToCpp) {
				cppVariables.push(type + " " + classNameNS + "::" + varName + assign);
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
				compileVarName(field.name);
			}

			final addToCpp = !headerOnly;

			final meta = compileMetadata(field.meta, MetadataTarget.ClassField);
			final ret = tfunc.t == null ? "void" : compileTypeSafe(tfunc.t, field.pos);
			final prefix = isStatic ? "static " : "";

			if(isDynamic) {
				final dynAddToCpp = !headerOnly && isStatic;
				final callable = compileClassVarExpr(field.expr());
				final assign = " = " + callable;
				final type = "std::function<" + ret + "(" + tfunc.args.map(a -> {
					return compileTypeSafe(a.v.t, field.pos);
				}).join(", ") + ")>";
				var decl = meta + prefix + type + " " + name;
				if(!dynAddToCpp) {
					decl += assign;
				}
				variables.push(decl);
	
				if(dynAddToCpp) {
					cppVariables.push(type + " " + classNameNS + "::" + name + assign);
				}
			} else {
				final retDecl = (useReturnType ? (ret + " ") : "");
				final argDecl = "(" + tfunc.args.map(a -> compileFunctionArgument(a, field.pos)).join(", ") + ")";
				final funcDeclaration = meta + prefix + retDecl + name + argDecl;
				var content = if(tfunc.expr != null) {
					" {\n" + compileClassFuncExpr(tfunc.expr).tab() + "\n}";
				} else {
					"";
				}
				
				if(addToCpp) {
					functions.push(funcDeclaration + ";");
					cppFunctions.push(retDecl + classNameNS + "::" + name + argDecl + content);
				} else {
					functions.push(funcDeclaration + content);
				}
			}
		}

		final filename = getFileNameFromModuleData(classType);

		// Source file
		if(!headerOnly && (cppVariables.length > 0 || cppFunctions.length > 0)) {
			var result = "#include \"" + filename + headerExt + "\"\n\n";

			result += compileIncludes(cppIncludes);

			if(cppVariables.length > 0) {
				result += cppVariables.join("\n\n") + "\n\n";
			}

			if(cppFunctions.length > 0) {
				result += cppFunctions.join("\n\n") + "\n";
			}

			setExtraFile("src/" + filename + ".cpp", result);
		}

		// Header file
		{
			var result = "#pragma once\n\n";

			result += compileIncludes(headerIncludes);

			for(p in classType.pack) {
				result += "namespace " + p + " {\n";
			}
			if(classType.pack.length > 0) result += "\n";

			result += header;

			if(variables.length > 0) {
				result += variables.join("\n\n").tab() + "\n\n";
			}

			if(functions.length > 0) {
				result += functions.join("\n\n").tab() + "\n";
			}

			result += "};\n";

			if(classType.pack.length > 0) result += "\n";
			for(p in classType.pack) {
				result += "}\n";
			}

			setExtraFile("include/" + filename + headerExt, result);
		}

		// We generated the files ourselves with "setExtraFile",
		// so we return null so Reflaxe doesn't generate anything itself.
		return null;
	}

	function compileFunctionArgument(arg: { v: TVar, value: Null<TypedExpr> }, pos: Position) {
		var result = compileTypeSafe(arg.v.t, pos) + " " + compileVarName(arg.v.name);
		if(arg.value != null) {
			result += " = " + compileExpression(arg.value);
		}
		return result;
	}

	// ----------------------------
	// Compiles an enum into C++.
	public function compileEnumImpl(enumType: EnumType, constructs: Map<String, haxe.macro.EnumField>): Null<String> {
		return null;
	}

	// ----------------------------
	// Compiles an typedef into C++.
	public override function compileTypedef(defType: DefType): Null<String> {
		resetAndInitIncludes();

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

		final filename = getFileNameFromModuleData(defType);
		final content = "typedef " + compileType(defType.type, defType.pos) + " " + defType.getNameOrNative() + ";";
		setExtraFile("include/" + filename + headerExt, "#pragma once\n\n" + content);

		return null;
	}

	// ----------------------------
	// Unwraps parenthesis from a TypeExpr for scenarios where the expression
	// is already going to be wrapped (i.e: if statement conditions).
	function upwrapParenthesis(expr: TypedExpr): TypedExpr {
		return switch(expr.expr) {
			case TParenthesis(e): {
				upwrapParenthesis(e);
			}
			case e: expr;
		}
	}

	// Take one of the include arrays and
	// compile/format for the output.
	function compileIncludes(includeArr: Array<String>): String {
		return if(includeArr.length > 0) {
			includeArr.map(i -> "#include " + i).join("\n") + "\n\n";
		} else {
			"";
		}
	}

	// ----------------------------
	// Compiles an expression into C++.
	public function compileExpressionImpl(expr: TypedExpr): Null<String> {
		var result = "";
		switch(expr.expr) {
			case TConst(constant): {
				result = constantToGDScript(constant);
			}
			case TLocal(v): {
				result = compileVarName(v.name, expr);
			}
			case TIdent(s): {
				result = compileVarName(s, expr);
			}
			case TArray(e1, e2): {
				result = compileExpression(e1) + "[" + compileExpression(e2) + "]";
			}
			case TBinop(op, e1, e2): {
				result = binopToGDScript(op, e1, e2);
			}
			case TField(e, fa): {
				result = fieldAccessToGDScript(e, fa);
			}
			case TTypeExpr(m): {
				result = moduleNameToGDScript(m, expr.pos);
			}
			case TParenthesis(e): {
				final compiled = compileExpression(e);
				final expr = if(!EverythingIsExprSanitizer.isBlocklikeExpr(e)) {
					"(" + compiled + ")";
				} else {
					compiled;
				}
				result = expr;
			}
			case TObjectDecl(fields): {
				result = "{\n";
				for(i in 0...fields.length) {
					final field = fields[i];
					result += "\t." + field.name + " = " + compileExpression(field.expr) + (i < fields.length - 1 ? "," : "") + "\n"; 
				}
				result += "}";
			}
			case TArrayDecl(el): {
				result = "[" + el.map(e -> compileExpression(e)).join(", ") + "]";
			}
			case TCall(e, el): {
				final nfc = this.compileNativeFunctionCodeMeta(e, el);
				result = if(nfc != null) {
					nfc;
				} else {
					final enumCall = compileEnumFieldCall(e, el);
					if(enumCall != null) {
						enumCall;
					} else {
						compileExpression(e) + "(" + el.map(e -> compileExpression(e)).join(", ") + ")";
					}
				}
			}
			case TNew(classTypeRef, _, el): {
				final nfc = this.compileNativeFunctionCodeMeta(expr, el);
				result = if(nfc != null) {
					nfc;
				} else {
					final meta = expr.getDeclarationMeta().meta;
					final native = { name: "", meta: meta }.getNameOrNative();
					final args = el.map(e -> compileExpression(e)).join(", ");
					if(native.length > 0) {
						native + "(" + args + ")";
					} else {
						final className = compileClassName(classTypeRef.get(), expr.pos);
						className + "(" + args + ")";
					}
				}
			}
			case TUnop(op, postFix, e): {
				result = unopToGDScript(op, e, postFix);
			}
			case TFunction(tfunc): {
				result = "[=](" + tfunc.args.map(a -> compileFunctionArgument(a, expr.pos)).join(", ") + ") {\n";
				result += toIndentedScope(tfunc.expr);
				result += "\n}";
			}
			case TVar(tvar, maybeExpr): {
				result = compileType(tvar.t, expr.pos) + " " + compileVarName(tvar.name, expr);
				if(maybeExpr != null) {
					result += " = " + compileExpression(maybeExpr);
				}
			}
			case TBlock(el): {
				result = "{";
				result += el.map(e -> compileExpression(e).tab() + ";").join("\n");
				result += "\n}";
			}
			case TFor(tvar, iterExpr, blockExpr): {
				result = "for(auto& " + tvar.name + " : " + compileExpression(iterExpr) + ") {\n";
				result += toIndentedScope(blockExpr);
				result += "\n}";
			}
			case TIf(econd, ifExpr, elseExpr): {
				result = "if(" + compileExpression(upwrapParenthesis(econd)) + ") {\n";
				result += toIndentedScope(ifExpr);
				if(elseExpr != null) {
					result += "\n} else {\n";
					result += toIndentedScope(elseExpr);
					result += "\n}";
				} else {
					result += "\n}";
				}
			}
			case TWhile(econd, blockExpr, normalWhile): {
				final gdCond = compileExpression(upwrapParenthesis(econd));
				if(normalWhile) {
					result = "while(" + gdCond + ") {\n";
					result += toIndentedScope(blockExpr);
					result += "\n}";
				} else {
					result = "do {\n";
					result += toIndentedScope(blockExpr);
					result += "\n} while(" + gdCond + ");";
				}
			}
			case TSwitch(e, cases, edef): {
				result = "switch(" + compileExpression(upwrapParenthesis(e)) + ") {\n";
				for(c in cases) {
					result += "\n";
					result += "\tcase " + c.values.map(v -> compileExpression(v)).join(", ") + ": {\n";
					result += toIndentedScope(c.expr).tab();
					result += "\n\t}";
				}
				if(edef != null) {
					result += "\n";
					result += "\t_:\n";
					result += toIndentedScope(edef).tab();
					result += "\n\t}";
				}
				result += "\n}";
			}
			case TTry(e, catches): {
				result = "try {\n" + compileExpression(e).tab();
				for(c in catches) {
					result += "\n} catch(" + compileType(c.v.t, expr.pos) + " " + c.v.name + ") {\n";
					if(c.expr != null) {
						result += compileExpression(c.expr).tab();
					}
				}
				result += "\n}";
			}
			case TReturn(maybeExpr): {
				if(maybeExpr != null) {
					result = "return " + compileExpression(maybeExpr);
				} else {
					result = "return";
				}
			}
			case TBreak: {
				result = "break;";
			}
			case TContinue: {
				result = "continue;";
			}
			case TThrow(expr): {
				result = "throw " + compileExpression(expr) + ";";
			}
			case TCast(e, maybeModuleType): {
				result = compileExpression(e);
				if(maybeModuleType != null) {
					result = "((" + moduleNameToGDScript(maybeModuleType, expr.pos) + ")(" + result + "))";
				}
			}
			case TMeta(metadataEntry, expr): {
				result = compileExpression(expr);
			}
			case TEnumParameter(expr, enumField, index): {
				result = compileExpression(expr);
				switch(enumField.type) {
					case TFun(args, _): {
						if(index < args.length) {
							result += "." + args[index].name;
						}
					}
					case _:
				}
			}
			case TEnumIndex(expr): {
				result = compileExpression(expr) + "._index";
			}
		}
		return result;
	}

	function toIndentedScope(e: TypedExpr): String {
		return switch(e.expr) {
			case TBlock(el): {
				el.map(e -> compileExpression(e).tab() + ";").join("\n");
			}
			case _: {
				compileExpression(e).tab() + ";";
			}
		}
	}

	function constantToGDScript(constant: TConstant): String {
		switch(constant) {
			case TInt(i): return Std.string(i);
			case TFloat(s): return s;
			case TString(s): return "\"" + StringTools.replace(StringTools.replace(s, "\\", "\\\\"), "\"", "\\\"") + "\"";
			case TBool(b): return b ? "true" : "false";
			case TNull: return "std::nullopt";
			case TThis: return "this";
			case TSuper: return superTypeName;
			case _: {}
		}
		return "";
	}

	function binopToGDScript(op: Binop, e1: TypedExpr, e2: TypedExpr): String {
		var gdExpr1 = compileExpression(e1);
		var gdExpr2 = compileExpression(e2);
		final operatorStr = OperatorHelper.binopToString(op);

		// Wrap primitives with std::to_string(...) when added with String
		if(op.isAddition()) {
			if(checkForPrimitiveStringAddition(e1, e2)) gdExpr2 = "std::to_string(" + gdExpr2 + ")";
			if(checkForPrimitiveStringAddition(e2, e1)) gdExpr1 = "std::to_string(" + gdExpr1 + ")";
		}

		return gdExpr1 + " " + operatorStr + " " + gdExpr2;
	}

	inline function checkForPrimitiveStringAddition(strExpr: TypedExpr, primExpr: TypedExpr) {
		return strExpr.t.isString() && primExpr.t.isPrimitive();
	}

	function unopToGDScript(op: Unop, e: TypedExpr, isPostfix: Bool): String {
		final gdExpr = compileExpression(e);
		final operatorStr = OperatorHelper.unopToString(op);
		return isPostfix ? (gdExpr + operatorStr) : (operatorStr + gdExpr);
	}

	function isThisExpr(te: TypedExpr): Bool {
		return switch(te.expr) {
			case TConst(TThis): {
				true;
			}
			case TParenthesis(te2): {
				isThisExpr(te2);
			}
			case _: {
				false;
			}
		}
	}

	function isArrowAccessType(t: Type): Bool {
		return switch(t) {
			case TInst(clsRef, params) if(params.length == 1): {
				clsRef.get().hasMeta(":arrowAccess");
			}
			case _: false;
		}
	}

	function fieldAccessToGDScript(e: TypedExpr, fa: FieldAccess): String {
		final nameMeta: NameAndMeta = switch(fa) {
			case FInstance(_, _, classFieldRef): classFieldRef.get();
			case FStatic(_, classFieldRef): classFieldRef.get();
			case FAnon(classFieldRef): classFieldRef.get();
			case FClosure(_, classFieldRef): classFieldRef.get();
			case FEnum(_, enumField): enumField;
			case FDynamic(s): { name: s, meta: null };
		}

		return if(nameMeta.hasMeta(":native")) {
			nameMeta.getNameOrNative();
		} else {
			final name = compileVarName(nameMeta.getNameOrNativeName());

			// Check if this is a static variable,
			// and if so use singleton.
			switch(fa) {
				case FStatic(clsRef, cfRef): {
					final cf = cfRef.get();
					final className = compileClassName(clsRef.get(), e.pos);
					return className + "::" + name;
				}
				case FEnum(_, enumField): {
					return "{ \"_index\": " + enumField.index + " }";
				}
				case _:
			}

			var useArrow = isThisExpr(e) || isArrowAccessType(e.t);

			final gdExpr = compileExpression(e);
			return gdExpr + (useArrow ? "->" : ".") + name;
		}
	}

	function moduleNameToGDScript(m: ModuleType, pos: Position): String {
		switch(m) {
			case TClassDecl(clsRef): compileClassName(clsRef.get(), pos);
			case _:
		}
		return m.getNameOrNative();
	}

	// This is called for called expressions.
	// If the typed expression is an enum field, transpile as a
	// Dictionary with the enum data.
	function compileEnumFieldCall(e: TypedExpr, el: Array<TypedExpr>): Null<String> {
		final ef = switch(e.expr) {
			case TField(_, fa): {
				switch(fa) {
					case FEnum(_, ef): ef;
					case _: null;
				}
			}
			case _: null;
		}

		return if(ef != null) {
			var result = "";
			switch(ef.type) {
				case TFun(args, _): {
					result = "{ \"_index\": " + ef.index + ", ";
					final fields = [];
					for(i in 0...el.length) {
						if(args[i] != null) {
							fields.push("\"" + args[i].name + "\": " + compileExpression(el[i]));
						}
					}
					result += fields.join(", ") + " }";
				}
				case _:
			}
			result;
		} else {
			null;
		}
	}
}

#end
