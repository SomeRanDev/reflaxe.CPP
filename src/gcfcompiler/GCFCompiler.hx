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
using reflaxe.helpers.DynamicHelper;
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
		return expr + ";";
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
	// Functions for compiling type names.
	function compileModuleTypeName(typeData: { > NameAndMeta, pack: Array<String> }, pos: Position, params: Null<Array<Type>> = null, useNamespaces: Bool = true, asValue: Bool = false): String {
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
			final prefix = (useNamespaces ? typeData.pack.join("::") + (typeData.pack.length > 0 ? "::" : "") : "");
			final innerClass = compileTypeNameWithParams(prefix + typeData.getNameOrNativeName(), pos, params);
			if(asValue || typeData.hasMeta(":valueType")) {
				innerClass;
			} else {
				if(typeData.hasMeta(":rawPtrType")) {
					innerClass + "*";
				} else if(typeData.hasMeta(":uniquePtrType")) {
					"std::unique_ptr<" + innerClass + ">";
				} else {
					"std::shared_ptr<" + innerClass + ">";
				}
			}
		}
	}

	function compileClassName(classType: ClassType, pos: Position, params: Null<Array<Type>> = null, useNamespaces: Bool = true, asValue: Bool = false): String {
		return compileModuleTypeName(classType, pos, params, useNamespaces, asValue);
	}

	function compileEnumName(enumType: EnumType, pos: Position, params: Null<Array<Type>> = null, useNamespaces: Bool = true, asValue: Bool = false): String {
		return compileModuleTypeName(enumType, pos, params, useNamespaces, asValue);
	}

	function compileDefName(defType: DefType, pos: Position, params: Null<Array<Type>> = null, useNamespaces: Bool = true, asValue: Bool = false): String {
		return compileModuleTypeName(defType, pos, params, useNamespaces, asValue);
	}

	function compileTypeNameWithParams(name: String, pos: Position, params: Null<Array<Type>> = null): Null<String> {
		if(params == null || params.length == 0) {
			return name;
		}
		return name + "<" + params.map(p -> compileTypeSafe(p, pos)).join(", ") + ">";
	}

	function compileTypeSafe(t: Null<Type>, pos: Position, asValue: Bool = false): String {
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
	function compileType(t: Null<Type>, pos: Position, asValue: Bool = false): Null<String> {
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
							addInclude("optional", true, true);
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
			case TClassDecl(clsRef): {
				switch(clsRef.get().kind) {
					case KTypeParameter(_): true;
					case _: false;
				}
			}
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
			// Add our "main" include if @:noInclude is absent.
			// First look for and use @:include, otherwise, use default header include.
			final cd = mt.getCommonData();
			if(currentModule.getUniqueId() == mt.getUniqueId()) return;
			if(addIncludeFromMetaAccess(cd.meta, header)) {
				if(!cd.isExtern) {
					addInclude(getFileNameFromModuleData(cd) + headerExt, header, false);
				}
			}

			if(!cd.hasMeta(":valueType") && !cd.hasMeta(":rawPtrType")) {
				addInclude("memory", header, true);
			}
		}
	}

	// Add include from extracted metadata entry parameters.
	// Returns true if successful.
	function addMetaEntryInc(params: Array<Dynamic>, header: Bool): Bool {
		if(params != null && params.length > 0 && params[0].isString()) {
			addInclude(params[0], header, params[1] == true);
			return true;
		}
		return false;
	}

	// Adds includes introduced from MetaAccess.
	// Returns "true" if a default include was not added.
	function addIncludeFromMetaAccess(metaAccess: Null<MetaAccess>, header: Bool = false): Bool {
		if(metaAccess == null) return true;

		var defaultOverrided = false;

		if(!metaAccess.maybeHas(":noInclude")) {
			final includeOverride = metaAccess.extractParamsFromFirstMeta(":include");
			if(!addMetaEntryInc(includeOverride, header)) {
				defaultOverrided = true;
			}
		}
		
		// Additional header files can be added using @:addInclude.
		final additionalIncludes = metaAccess.extractParamsFromAllMeta(":addInclude");
		for(inc in additionalIncludes) {
			addMetaEntryInc(inc, header);
		}

		return defaultOverrided;
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
					if(!mt.isAbstract()) {
						addIncludeFromModuleType(mt, onlyHeader || level >= FunctionDeclaration);
					}
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
		final className = compileClassName(classType, classType.pos, null, false, true);
		var classNameNS = compileClassName(classType, classType.pos, null, true, true);
		if(classNameNS.length > 0) classNameNS += "::";

		var headerOnly = classType.hasMeta(":headerOnly");

		// Init includes
		resetAndInitIncludes(headerOnly);

		// Ensure no self-reference
		final isValueType = classType.hasMeta(":valueType");
		if(isValueType) {
			for(v in varFields) {
				if(isSameAsCurrentModule(v.field.type)) {
					Context.error("Types using @:valueType cannot reference themselves. Consider wrapping with SharedPtr<T>.", v.field.pos);
				}
			}
		}

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
					cppVariables.push(type + " " + classNameNS + name + assign);
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
					final cppArgDecl = "(" + tfunc.args.map(a -> compileFunctionArgument(a, field.pos, true)).join(", ") + ")";
					cppFunctions.push(retDecl + classNameNS + name + cppArgDecl + content);
				} else {
					functions.push(funcDeclaration + content);
				}
			}
		}

		final filename = getFileNameFromModuleData(classType);

		// Source file
		if(!headerOnly && (cppVariables.length > 0 || cppFunctions.length > 0)) {
			final srcFilename = "src/" + filename + ".cpp";
			setExtraFileIfEmpty(srcFilename, "#include \"" + filename + headerExt + "\"");

			appendToExtraFile(srcFilename, compileIncludes(cppIncludes), 1);
			
			var result = "";

			if(cppVariables.length > 0) {
				result += cppVariables.join("\n\n") + "\n\n";
			}

			if(cppFunctions.length > 0) {
				result += cppFunctions.join("\n\n") + "\n";
			}

			appendToExtraFile(srcFilename, result + "\n", 2);
		}

		// Header file
		{
			final headerFilename = "include/" + filename + headerExt;
			setExtraFileIfEmpty(headerFilename, "#pragma once");

			appendToExtraFile(headerFilename, compileIncludes(headerIncludes), 1);

			var result = "";
			result += compileNamespaceStart(classType);
			result += header;

			if(variables.length > 0) {
				result += variables.join("\n\n").tab() + "\n\n";
			}

			if(functions.length > 0) {
				result += functions.join("\n\n").tab() + "\n";
			}

			result += "};\n";

			result += compileNamespaceEnd(classType);

			appendToExtraFile(headerFilename, result + "\n", 2);
		}

		// We generated the files ourselves with "appendToExtraFile",
		// so we return null so Reflaxe doesn't generate anything itself.
		return null;
	}

	function compileNamespaceStart(md: CommonModuleTypeData): String {
		var result = "";
		for(p in md.pack) {
			result += "namespace " + p + " {\n";
		}
		if(md.pack.length > 0) result += "\n";
		return result;
	}

	function compileNamespaceEnd(md: CommonModuleTypeData): String {
		var result = "";
		if(md.pack.length > 0) result += "\n";
		for(p in md.pack) {
			result += "}\n";
		}
		return result;
	}

	function compileFunctionArgument(arg: { v: TVar, value: Null<TypedExpr> }, pos: Position, noDefaultValue: Bool = false) {
		var result = compileTypeSafe(arg.v.t, pos) + " " + compileVarName(arg.v.name);
		if(!noDefaultValue && arg.value != null) {
			result += " = " + compileExpression(arg.value);
		}
		return result;
	}

	// ----------------------------
	// Compiles an enum into C++.
	public function compileEnumImpl(enumType: EnumType, options: EnumOptions): Null<String> {
		// --------------------
		// Init includes (always headers = true)
		resetAndInitIncludes(true);

		// --------------------
		// Ensure no self-reference if value type.
		final isValueType = enumType.hasMeta(":valueType");
		if(isValueType) {
			for(o in options) {
				for(a in o.args) {
					if(isSameAsCurrentModule(a.t)) {
						Context.error("Types using @:valueType cannot reference themselves. Consider wrapping with SharedPtr<T>.", o.field.pos);
					}
				}
			}
		}

		// --------------------
		// Generate entire class declaration in "declaration"
		final enumName = compileEnumName(enumType, enumType.pos, null, false, true);
		var declaration = "class " + enumName + " {\npublic:\n";
		declaration += "\tint index;\n\n";

		var constructors = [];
		var destructInfo = [];
		var unionStructs = [];
		var unionContent = [];

		// --------------------
		// Iterate through options
		var index = 0;
		for(o in options) {
			final hasArgs = o.args.length > 0;
			final args = o.args.map(opt -> [compileType(opt.t, o.field.pos), opt.name]);

			// Generate static function "constructors"
			{
				final funcArgs = [];
				for(i in 0...args.length) {
					funcArgs.push(args[i][0] + " _" + args[i][1] + (o.args[i].opt ? " = std::nullopt" : ""));
				}
				var construct = "";
				construct += "static " + enumName + " " + o.name + "(" + funcArgs.join(", ") + ") {\n";
				construct += "\t" + enumName + " result;\n";
				construct += "\tresult.index = " + index + ";\n";
				if(hasArgs) {
					construct += "\tresult.data." + o.name + " = { " + args.map((tn) -> "_" + tn[1]).join(", ") + " };\n";
				}
				construct += "\treturn result;\n";
				construct += "}";
				constructors.push(construct);
			}

			// Generate private structs
			if(hasArgs) {
				var content = "";
				final structName = "d" + o.name + "Impl";
				content += "struct " + structName + " {\n";
				content += args.map((tn) -> "\t" + tn.join(" ") + ";").join("\n");
				content += "\n};";
				unionStructs.push(content.tab());
				destructInfo.push({ index: index, name: o.name, sname: structName });
				unionContent.push("\t" + structName + " " + o.name + ";");
			}

			index++;
		}

		// --------------------
		// Complete declaration

		// Only create union if we need to
		final requiresUnion = unionStructs.length > 0;
		if(requiresUnion) {
			declaration += unionStructs.join("\n\n") + "\n\n";

			final unionIntro = "union dData {\n\tdData() {}\n\t~dData() {}\n";
			final unionEnd = "\n};";
			declaration += (unionIntro + unionContent.join("\n") + unionEnd).tab() + "\n\n";

			declaration += "\tdData data;\n\n";
		}
		
		// Create default constructor
		declaration += (enumName + "() {\n\tindex = -1;\n}").tab() + "\n\n";

		// If we're using a union, we need a copy constructor and destructor
		if(requiresUnion) {
			// --------------------
			// Copy Constructor
			var copyCon = enumName + "(const " + enumName + "& other) {\n\tindex = other.index;\n";

			// Copy Constructor Body
			{
				var constructSwitch = "#define ConstructCase(index, cls) case index: { data.cls = other.data.cls; break; }\n";
				for(d in destructInfo) {
					constructSwitch += "ConstructCase(" + d.index + ", " + d.name + ")\n";
				}
				constructSwitch += "#undef ConstructCase";

				copyCon += "\tswitch(index) {\n";
				copyCon += constructSwitch.tab().tab();
				copyCon += "\n\t}\n";
			}

			copyCon += "}";

			// --------------------
			// Destructor
			var destruct = "~" + enumName + "() {\n";

			// Destructor body
			{
				var destructSwitch = "#define DestructCase(index, field, cls) case index: { data.field.~cls(); break; }\n";
				for(d in destructInfo) {
					destructSwitch += "DestructCase(" + d.index + ", " + d.name + ", " + d.sname + ")\n";
				}
				destructSwitch += "#undef DestructCase";

				destruct += "\tswitch(index) {\n";
				destruct += destructSwitch.tab().tab();
				destruct += "\n\t}\n";
			}

			destruct += "}";

			// --------------------
			// Add to declaration
			declaration += copyCon.tab() + "\n\n";
			declaration += destruct.tab() + "\n\n";
		}

		// Static function "constructors"
		declaration += constructors.join("\n\n").tab();
		declaration += "\n};";

		// Start output
		final filename = getFileNameFromModuleData(enumType);
		final headerFilename = "include/" + filename + headerExt;

		// pragma once
		setExtraFileIfEmpty(headerFilename, "#pragma once");

		// Compile headers
		appendToExtraFile(headerFilename, compileIncludes(headerIncludes), 1);

		// Output class
		var content = "";
		content += compileNamespaceStart(enumType);
		content += declaration;
		content += compileNamespaceEnd(enumType);

		appendToExtraFile(headerFilename, content, 2);

		return null;
	}

	// ----------------------------
	// Compiles an typedef into C++.
	public override function compileTypedef(defType: DefType): Null<String> {
		resetAndInitIncludes(true);

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
		final headerFilename = "include/" + filename + headerExt;

		setExtraFileIfEmpty(headerFilename, "#pragma once");
		appendToExtraFile(headerFilename, content, 2);

		return null;
	}

	public override function compileAbstract(ab: AbstractType): Null<String> {
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
			includeArr.map(i -> "#include " + i).join("\n");
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
				addIncludeFromMetaAccess(v.meta);
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
				result = "{" + el.map(e -> compileExpression(e)).join(", ") + "}";
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
				addIncludeFromMetaAccess(enumField.meta);
				result = compileExpression(expr);
				switch(enumField.type) {
					case TFun(args, _): {
						if(index < args.length) {
							result += (args.length == 1 ? ("." + enumField.name) : "") + "." + args[index].name;
						}
					}
					case _:
				}
			}
			case TEnumIndex(expr): {
				result = compileExpression(expr) + ".index";
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

		addIncludeFromMetaAccess(nameMeta.meta);

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
		addIncludeFromMetaAccess(m.getCommonData().meta);
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
