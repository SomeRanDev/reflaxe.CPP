// =======================================================
// * Compiler_Exprs
//
// This sub-compiler is used to handle compiling of all
// expressions.
// =======================================================

package unboundcompiler.subcompilers;

#if (macro || ucpp_runtime)

import haxe.ds.Either;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

import reflaxe.compiler.EverythingIsExprSanitizer;

using reflaxe.helpers.BaseCompilerHelper;
using reflaxe.helpers.DynamicHelper;
using reflaxe.helpers.ModuleTypeHelper;
using reflaxe.helpers.OperatorHelper;
using reflaxe.helpers.NameMetaHelper;
using reflaxe.helpers.SyntaxHelper;
using reflaxe.helpers.TypedExprHelper;
using reflaxe.helpers.TypeHelper;

using unboundcompiler.helpers.UError;
using unboundcompiler.helpers.UMeta;
using unboundcompiler.helpers.UType;

@:allow(unboundcompiler.UnboundCompiler)
@:access(unboundcompiler.UnboundCompiler)
@:access(unboundcompiler.subcompilers.Compiler_Includes)
@:access(unboundcompiler.subcompilers.Compiler_Types)
class Compiler_Exprs extends SubCompiler {
	// ----------------------------
	// A public variable modified based on whether the
	// current expression is being compiled for a header file.
	public var compilingInHeader: Bool = false;
	public var compilingForTopLevel: Bool = false;
	function onModuleTypeEncountered(mt: ModuleType) Main.onModuleTypeEncountered(mt, compilingInHeader);

	// ----------------------------
	// Compiles an expression into C++.
	public function compileExpressionToCpp(expr: TypedExpr): Null<String> {
		var result: Null<String> = null;
		switch(expr.expr) {
			case TConst(constant): {
				result = constantToCpp(constant);
			}
			case TLocal(v): {
				IComp.addIncludeFromMetaAccess(v.meta, compilingInHeader);
				result = Main.compileVarName(v.name, expr);
			}
			case TIdent(s): {
				result = Main.compileVarName(s, expr);
			}
			case TArray(e1, e2): {
				result = compileExpressionNotNullAsValue(e1) + "[" + compileExpressionNotNull(e2) + "]";
			}
			case TBinop(op, { expr: TConst(TNull) }, nullCompExpr) |
			     TBinop(op, nullCompExpr, { expr: TConst(TNull) })
				 if(op == OpEq || op == OpNotEq): {
				result = Main.compileExpression(nullCompExpr);
				switch(op) {
					case OpNotEq: {
						result += ".has_value()";
					}
					case OpEq: {
						result = "!" + result + ".has_value()";
					}
					case _: {}
				}
			}
			case TBinop(op, e1, e2): {
				result = binopToCpp(op, e1, e2);
			}
			case TField(e, fa): {
				result = fieldAccessToCpp(e, fa, expr);
			}
			case TTypeExpr(m): {
				result = moduleNameToCpp(m, expr.pos);
			}
			case TParenthesis(e): {
				final compiled = Main.compileExpression(e);
				if(compiled != null) {
					final expr = if(!EverythingIsExprSanitizer.isBlocklikeExpr(e)) {
						"(" + compiled + ")";
					} else {
						compiled;
					}
					result = expr;
				}
			}
			case TObjectDecl(fields): {
				result = AComp.compileObjectDecl(Main.getExprType(expr), fields);
			}
			case TArrayDecl(el): {
				final arrayType = Main.getExprType(expr).unwrapArrayType();
				result = "std::deque<" + TComp.compileType(arrayType, expr.pos, true) + ">{" + el.map(e -> compileExpressionForType(e, arrayType)).join(", ") + "}";
			}
			case TCall({ expr: TIdent("__uinclude__") }, el): {
				switch(el) {
					case [{ expr: TConst(TString(s)) }]: {
						IComp.addInclude(s, compilingInHeader, false);
					}
					case [{ expr: TConst(TString(s)) }, { expr: TConst(TBool(b)) }]: {
						IComp.addInclude(s, compilingInHeader, b);
					}
					case _: {}
				}
				result = null;
			}
			case TCall(callExpr, el): {
				result = compileCall(callExpr, el);
			}
			case TNew(classTypeRef, params, el): {
				onModuleTypeEncountered(TClassDecl(classTypeRef));
				result = compileNew(expr, TInst(classTypeRef, params), el);
			}
			case TUnop(op, postFix, e): {
				result = unopToCpp(op, e, postFix);
			}
			case TFunction(tfunc): {
				IComp.addInclude("functional", compilingInHeader, true);
				final captureType = compilingForTopLevel ? "" : "&";
				result = "[" + captureType + "](" + tfunc.args.map(a -> Main.compileFunctionArgument(a, expr.pos, false, true)).join(", ") + ") mutable {\n";
				result += toIndentedScope(tfunc.expr);
				result += "\n}";
			}
			case TVar(tvar, maybeExpr): {
				final t = Main.getTVarType(tvar);
				final typeCpp = if(t.isUnresolvedMonomorph()) {
					// TODO: Why use std::any instead of auto?
					// I must have originally made this resolve to Any for a reason?
					// But Haxe's Any will only apply if explicitly typed as Any.
					//
					//IComp.addInclude("any", compilingInHeader, true);
					//"std::any";

					"auto";
				} else {
					TComp.compileType(t, expr.pos);
				}
				result = typeCpp + " " + Main.compileVarName(tvar.name, expr);
				if(maybeExpr != null) {
					result += " = " + compileExpressionForType(maybeExpr, t);
				}
			}
			case TBlock(el): {
				result = "{\n";
				result += el.map(e -> {
					final e = Main.compileExpression(e);
					return e == null ? null : (e.tab() + ";");
				}).filter(s -> s != null).join("\n");
				result += "\n}";
			}
			case TFor(tvar, iterExpr, blockExpr): {
				result = "for(auto& " + tvar.name + " : " + Main.compileExpressionOrError(iterExpr) + ") {\n";
				result += toIndentedScope(blockExpr);
				result += "\n}";
			}
			case TIf(econd, ifExpr, elseExpr): {
				result = compileIf(econd, ifExpr, elseExpr);
			}
			case TWhile(econd, blockExpr, normalWhile): {
				final gdCond = Main.compileExpressionOrError(econd.unwrapParenthesis());
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
				result = "switch(" + Main.compileExpressionOrError(e.unwrapParenthesis()) + ") {\n";
				for(c in cases) {
					result += "\n";
					result += "\tcase " + c.values.map(v -> Main.compileExpressionOrError(v)).join(", ") + ": {\n";
					result += toIndentedScope(c.expr).tab();
					result += "\n\t\tbreak;";
					result += "\n\t}";
				}
				if(edef != null) {
					result += "\n";
					result += "\t_:\n";
					result += toIndentedScope(edef).tab();
					result += "\n\t\tbreak;";
					result += "\n\t}";
				}
				result += "\n}";
			}
			case TTry(e, catches): {
				final tryContent = Main.compileExpression(e);
				if(tryContent != null) {
					result = "try {\n" + tryContent.tab();
					for(c in catches) {
						result += "\n} catch(" + TComp.compileType(Main.getTVarType(c.v), expr.pos) + " " + c.v.name + ") {\n";
						if(c.expr != null) {
							final cpp = Main.compileExpression(c.expr);
							if(cpp != null) result += cpp.tab();
						}
					}
					result += "\n}";
				}
			}
			case TReturn(maybeExpr): {
				final cpp = maybeExpr != null ? Main.compileExpression(maybeExpr) : null;
				if(cpp != null) {
					result = "return " + cpp;
				} else {
					result = "return";
				}
			}
			case TBreak: {
				result = "break";
			}
			case TContinue: {
				result = "continue";
			}
			case TThrow(expr): {
				result = "throw " + Main.compileExpressionOrError(expr);
			}
			case TCast(e, maybeModuleType): {
				final cpp = Main.compileExpression(e);
				if(cpp != null) {
					result = cpp;
					if(maybeModuleType != null) {
						final mCpp = moduleNameToCpp(maybeModuleType, expr.pos);
						switch(e.t) {
							case TAbstract(aRef, []) if(aRef.get().name == "Any" && aRef.get().module == "Any"): {
								result = "std::any_cast<" + mCpp + ">(" + result + ")";
							}
							case _: {
								result = "((" + mCpp + ")(" + result + "))";
							}
						}
					}
				}
			}
			case TMeta(metadataEntry, nextExpr): {
				final unwrappedInfo = unwrapMetaExpr(expr);
				final cpp = compileExprWithMultipleMeta(unwrappedInfo.meta, expr, unwrappedInfo.internalExpr);
				result = cpp != null ? cpp : Main.compileExpression(unwrappedInfo.internalExpr);
			}
			case TEnumParameter(expr, enumField, index): {
				IComp.addIncludeFromMetaAccess(enumField.meta, compilingInHeader);
				result = Main.compileExpressionOrError(expr);
				switch(enumField.type) {
					case TFun(args, _): {
						if(index < args.length) {
							final access = (isArrowAccessType(Main.getExprType(expr)) ? "->" : ".");
							result = result + access + "get" + enumField.name + "()." + args[index].name;
						}
					}
					case _:
				}
			}
			case TEnumIndex(expr): {
				final access = isArrowAccessType(Main.getExprType(expr)) ? "->" : ".";
				result = Main.compileExpressionOrError(expr) + access + "index";
			}
		}
		return result;
	}

	function compileExpressionNotNull(expr: TypedExpr): Null<String> {
		final unwrapOptional = switch(expr.expr) {
			case TLocal(_): true;
			case TIdent(_): true;
			case TField(_, _): true;
			case TCall(_, _): true;
			case _: false;
		}

		var result = Main.compileExpression(expr);

		if(unwrapOptional) {
			if(expr.t.isNull()) {
				result = result + ".value()";
			}
		}

		return result;
	}

	function compileExpressionNotNullAsValue(expr: TypedExpr): Null<String> {
		final result = compileExpressionNotNull(expr);

		final isValue = switch(TComp.getMemoryManagementTypeFromType(expr.t)) {
			case Value: true;
			case _: false;
		}

		return if(result != null) {
			isValue ? result : "(*" + result + ")";
		} else {
			null;
		}
	}

	// ----------------------------
	// Compile expression, but take into account the target type
	// and apply additional conversions in the compiled code.
	function compileExpressionForType(expr: TypedExpr, targetType: Null<Type>, allowNullReturn: Bool = false): Null<String> {
		var cpp = null;
		if(targetType != null) {
			expr = expr.unwrapUnsafeCasts();
			if(expr.t.valueTypesEqual(targetType)) {
				cpp = compileMMConversion(expr, Left(targetType));
			} else {
				// If converting from a normal type to an anonymous struct, we must first convert the
				// object to `Value` memory management since the generated anon struct constructors expect value types.
				//
				// Next, since unnamed anonymous structs are always `SharedPtr`s, we use applyMMConversion to 
				// format the generated C++ code from `Value` to `SharedPtr`.
				if(!Main.getExprType(expr).getInternalType().isAnonStruct() && targetType.getInternalType().isAnonStruct()) {
					cpp = applyMMConversion(compileMMConversion(expr, Right(Value)), expr.pos, targetType, Value, SharedPtr);
				}
			}
		}
		if(cpp == null) {
			switch(expr.expr) {
				case TObjectDecl(fields): {
					cpp = AComp.compileObjectDecl(targetType, fields);
				}
				case _: {
					cpp = allowNullReturn ? Main.compileExpression(expr) : Main.compileExpressionOrError(expr);
				}
			}
		}
		return cpp;
	}

	// ----------------------------
	// If the memory management type of the target type (or target memory management type)
	// is different from the provided expression, compile the expression and with additional
	// conversions in the generated code.
	function compileMMConversion(expr: TypedExpr, targetType: Either<Null<Type>, MemoryManagementType>): Null<String> {
		final cmmt = TComp.getMemoryManagementTypeFromType(Main.getExprType(expr));
		final tmmt = switch(targetType) {
			case Left(tt): TComp.getMemoryManagementTypeFromType(tt);
			case Right(mmt): mmt;
		}

		final nullToValue = switch(targetType) {
			case Left(tt): Main.getExprType(expr).isNullOfType(tt);
			case Right(_): Main.getExprType(expr).isNull();
		}

		var result = null;
		if(cmmt != tmmt || nullToValue) {
			switch(expr.expr) {
				case TNew(classTypeRef, params, el): {
					result = compileNew(expr, TInst(classTypeRef, params), el, tmmt);
				}
				case _: {
					var cpp = Main.compileExpression(expr);
					if(cpp != null) {
						if(nullToValue) {
							cpp = ensureSafeToAccess(cpp) + ".value()";
						}
						result = applyMMConversion(cpp, expr.pos, Main.getExprType(expr), cmmt, tmmt);
					}
				}
			}
		}

		return result;
	}

	// ----------------------------
	// Given some generated C++ output, this function wraps the output
	// in parenthesis if the output is not an identifier or simple access chain.
	function ensureSafeToAccess(cpp: String): String {
		return if(!~/[a-z0-9_\.(?:::)(?:->)]+/.match(cpp)) {
			"(" + cpp + ")";
		} else {
			cpp;
		}
	}

	// ----------------------------
	// Given two memory management types, generate code that would convert
	// the compiled C++ code from the current type to the target type.
	function applyMMConversion(cpp: String, epos: Position, type: Type, current: MemoryManagementType, target: MemoryManagementType): Null<String> {
		function typeCpp() return TComp.compileType(type, epos, true);

		return switch(current) {
			case Value: {
				switch(target) {
					case Value: cpp;
					case UnsafePtr: "&" + cpp;
					case SharedPtr: "std::make_shared<" + typeCpp() + ">(" + cpp + ")";
					case UniquePtr: "std::make_unique<" + typeCpp() + ">(" + cpp + ")";
				}
			}
			case UnsafePtr: {
				switch(target) {
					case Value: "(*" + cpp + ")";
					case UnsafePtr: cpp;
					case SharedPtr: epos.makeError(UnsafeToShared);
					case UniquePtr: epos.makeError(UnsafeToUnique);
				}
			}
			case SharedPtr: {
				switch(target) {
					case Value: "(*" + cpp + ")";
					case UnsafePtr: cpp + ".get()";
					case SharedPtr: cpp;
					case UniquePtr: epos.makeError(SharedToUnique);
				}
			}
			case UniquePtr: {
				switch(target) {
					case Value: "(*" + cpp + ")";
					case UnsafePtr: cpp + ".get()";
					case SharedPtr: epos.makeError(UniqueToShared);
					case UniquePtr: epos.makeError(UniqueToUnique);
				}
			}
		}
	}

	// ----------------------------
	// Compile and indent the TypedExpr.
	function toIndentedScope(e: TypedExpr): String {
		return switch(e.expr) {
			case TBlock(el): {
				el.map(e -> {
					final cpp = Main.compileExpression(e);
					return cpp == null ? null : (cpp.tab() + ";");
				}).filter(s -> s != null).join("\n");
			}
			case _: {
				final cpp = Main.compileExpression(e);
				cpp == null ? null : cpp.tab() + ";";
			}
		}
	}

	function constantToCpp(constant: TConstant): String {
		return switch(constant) {
			case TInt(i): Std.string(i);
			case TFloat(s): s;
			case TString(s): stringToCpp(s);
			case TBool(b): b ? "true" : "false";
			case TNull: "std::nullopt";
			case TThis: "this";
			case TSuper: Main.superTypeName;
			case _: "";
		}
	}

	function stringToCpp(s: String): String {
		return "\"" + StringTools.replace(StringTools.replace(s, "\\", "\\\\"), "\"", "\\\"") + "\"";
	}

	function binopToCpp(op: Binop, e1: TypedExpr, e2: TypedExpr): String {
		var gdExpr1 = if(!op.isAssign() && !op.isEqualityCheck()) {
			compileExpressionNotNull(e1);
		} else {
			Main.compileExpressionOrError(e1);
		}

		var gdExpr2 = if(op.isAssign()) {
			compileExpressionForType(e2, Main.getExprType(e1));
		} else {
			compileExpressionNotNull(e2);
		}

		final operatorStr = OperatorHelper.binopToString(op);

		// Wrap primitives with std::to_string(...) when added with String
		if(op.isAddition()) {
			if(checkForPrimitiveStringAddition(e1, e2)) gdExpr2 = "std::to_string(" + gdExpr2 + ")";
			if(checkForPrimitiveStringAddition(e2, e1)) gdExpr1 = "std::to_string(" + gdExpr1 + ")";
		}

		return gdExpr1 + " " + operatorStr + " " + gdExpr2;
	}

	inline function checkForPrimitiveStringAddition(strExpr: TypedExpr, primExpr: TypedExpr) {
		return Main.getExprType(strExpr).isString() && Main.getExprType(primExpr).isPrimitive();
	}

	function unopToCpp(op: Unop, e: TypedExpr, isPostfix: Bool): String {
		final gdExpr = compileExpressionNotNull(e);
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
		final ut = t.unwrapNullTypeOrSelf();
		final mmt = TComp.getMemoryManagementTypeFromType(ut);

		final mt = ut.toModuleType();
		if(mt != null) {
			final cd = mt.getCommonData();
			final mmt = cd.getMemoryManagementType();
			if(cd.isArrowAccess()) {
				return true;
			}
		}

		return mmt != Value;
	}

	function fieldAccessToCpp(e: TypedExpr, fa: FieldAccess, accessExpr: TypedExpr): String {
		final nameMeta: NameAndMeta = switch(fa) {
			case FInstance(_, _, classFieldRef): classFieldRef.get();
			case FStatic(_, classFieldRef): classFieldRef.get();
			case FAnon(classFieldRef): classFieldRef.get();
			case FClosure(_, classFieldRef): classFieldRef.get();
			case FEnum(_, enumField): enumField;
			case FDynamic(s): { name: s, meta: null };
		}

		IComp.addIncludeFromMetaAccess(nameMeta.meta, compilingInHeader);

		return if(nameMeta.hasNativeMeta()) {
			nameMeta.getNameOrNative();
		} else {
			final name = Main.compileVarName(nameMeta.getNameOrNativeName());

			// Check if this is a static variable,
			// and if so use singleton.
			switch(fa) {
				case FStatic(clsRef, cfRef): {
					onModuleTypeEncountered(TClassDecl(clsRef));

					final cf = cfRef.get();
					return if(cf.hasMeta(":topLevel")) {
						name;
					} else {
						final className = TComp.compileClassName(clsRef.get(), e.pos, null, true, true);
						className + "::" + name;
					}
				}
				case FEnum(enumRef, enumField): {
					onModuleTypeEncountered(TEnumDecl(enumRef));

					final enumName = TComp.compileEnumName(enumRef.get(), e.pos, null, true, true);
					final potentialArgs = enumField.type.getTFunArgs();

					// If there are no arguments, Haxe treats the enum case as
					// a static variable, rather than a function. However, all enum
					// cases in C++ are functions.
					//
					// Therefore, if there are no arguments, lets go ahead and
					// add a call operator to the end so the C++ function version
					// is properly called.
					final end = potentialArgs != null && potentialArgs.length > 0 ? "" : "()";
					return enumName + "::" + name + end;
				}
				case _:
			}

			var useArrow = isThisExpr(e) || isArrowAccessType(Main.getExprType(e));

			final nullType = Main.getExprType(e).unwrapNullType();
			final gdExpr = if(nullType != null) {
				compileExpressionForType(e, nullType);
			} else {
				Main.compileExpressionOrError(e);
			}
			return gdExpr + (useArrow ? "->" : ".") + name;
		}
	}

	function moduleNameToCpp(m: ModuleType, pos: Position): String {
		IComp.addIncludeFromMetaAccess(m.getCommonData().meta, compilingInHeader);
		return TComp.compileType(TypeHelper.fromModuleType(m), pos, true);
	}

	function checkNativeCodeMeta(callExpr: TypedExpr, el: Array<TypedExpr>, typeParams: Null<Array<Type>> = null): Null<String> {
		//final typeParams = type.getParams();
		final params = if(typeParams != null) {
			typeParams.map(t -> function() {
				return TComp.compileType(t, callExpr.pos);
			});
		} else {
			null;
		}
		return Main.compileNativeFunctionCodeMeta(callExpr, el, params);
	}

	function compileCall(callExpr: TypedExpr, el: Array<TypedExpr>, originalExpr: TypedExpr) {
		final inlineTrace = checkForInlinableTrace(callExpr, el);
		if(inlineTrace != null) return inlineTrace;

		final nfc = checkNativeCodeMeta(callExpr, el, callExpr.getFunctionTypeParams(originalExpr.t));
		return if(nfc != null) {
			// Ensure we use potential #include
			final declaration = callExpr.getDeclarationMeta();
			if(declaration != null) {
				IComp.addIncludeFromMetaAccess(declaration.meta, compilingInHeader);
			}

			nfc;
		} else {
			// Get list of function argument types
			var funcArgs = switch(Main.getExprType(callExpr)) {
				case TFun(args, ret): {
					args.map(a -> a.t);
				}
				case _: null;
			}

			// Compile the parameters
			var cppArgs = [];
			for(i in 0...el.length) {
				final paramExpr = el[i];
				final cpp = if(funcArgs != null && i < funcArgs.length && funcArgs[i] != null) {
					compileExpressionForType(paramExpr, funcArgs[i]);
				} else {
					Main.compileExpressionOrError(paramExpr);
				}
				cppArgs.push(cpp);
			}

			// Handle type parameters if necessary
			var typeParamCpp = "";
			final cf = callExpr.getClassField();
			if(cf != null && cf.params.length > 0) {
				final resolvedParams = callExpr.t.findResolvedTypeParams(cf);
				if(resolvedParams != null) {
					var compileSuccess = true;
					final compiledParams = resolvedParams.map(t -> {
						final result = TComp.maybeCompileType(t, callExpr.pos);
						if(result == null) {
							compileSuccess = false;
						}
						result;
					});
					if(compileSuccess) {
						typeParamCpp = "<" + compiledParams.join(", ") + ">";
					}
				}
			}

			// Compile final expression
			Main.compileExpressionOrError(callExpr) + typeParamCpp + "(" + cppArgs.join(", ") + ")";
		}
	}

	function compileNew(expr: TypedExpr, type: Type, el: Array<TypedExpr>, overrideMMT: Null<MemoryManagementType> = null): String {
		final nfc = checkNativeCodeMeta(expr, el, type.getParams());
		return if(nfc != null) {
			nfc;
		} else {
			// Since we are constructing an object, it will never be null.
			// Therefore, we must remove any Null<T> from the type.
			type = type.unwrapNullTypeOrSelf();
			final meta = switch(type) {
				// Used for TObjectDecl of named anonymous struct.
				// See "XComp.compileNew" in Compiler_Anon.compileObjectDecl to understand.
				case TType(typeDefRef, params): {
					typeDefRef.get().meta;
				}
				case _: {
					expr.getDeclarationMeta().meta;
				}
			}
			final native = { name: "", meta: meta }.getNameOrNative();

			// Find argument types (if possible)
			var funcArgs = switch(type) {
				case TInst(clsRef, params): {
					final cls = clsRef.get();
					final c = cls.constructor;
					if(c != null) {
						final clsField = c.get();
						switch(clsField.type) {
							case TFun(args, ret): {
								args.map(a -> haxe.macro.TypeTools.applyTypeParameters(a.t, cls.params, params));
							}
							case _: null;
						}
					} else {
						null;
					}
				}
				case _: null;
			}

			// Compile the arguments
			var cppArgs = [];
			for(i in 0...el.length) {
				final paramExpr = el[i];
				final cpp = if(funcArgs != null && i < funcArgs.length && funcArgs[i] != null) {
					compileExpressionForType(paramExpr, funcArgs[i]);
				} else {
					Main.compileExpressionOrError(paramExpr);
				}
				cppArgs.push(cpp);
			}

			final args = cppArgs.join(", ");
			if(native.length > 0) {
				native + "(" + args + ")";
			} else {
				final params = {
					final temp = type.getParams();
					temp != null ? temp : [];
				};
				final typeParams = params.map(p -> TComp.compileType(p, expr.pos)).join(", ");
				final cd = type.toModuleType().getCommonData();

				// If the expression's type is different, this may be the result of an unsafe cast.
				// If so, let's use the memory management type from the cast.
				if(overrideMMT == null) {
					final exprMMT = TComp.getMemoryManagementTypeFromType(Main.getExprType(expr));
					if(exprMMT != cd.getMemoryManagementType()) {
						overrideMMT = exprMMT;
					}
				}

				compileClassConstruction(type, cd, params != null ? params : [], expr.pos, overrideMMT) + "(" + args + ")";
			}
		}
	}

	function compileClassConstruction(type: Type, cd: CommonModuleTypeData, params: Array<Type>, pos: Position, overrideMMT: Null<MemoryManagementType> = null): String {
		var mmt = cd.getMemoryManagementType();
		var typeSource = if(cd.isOverrideMemoryManagement()) {
			if(params.length != 1) {
				pos.makeError(OMMIncorrectParamCount);
			}
			params[0];
		} else {
			if(overrideMMT != null) {
				mmt = overrideMMT;
			}
			null;
		}

		if(typeSource == null) {
			typeSource = type;
		}

		final typeOutput = TComp.compileType(typeSource, pos, true);
		return switch(mmt) {
			case Value: typeOutput;
			case UnsafePtr: "new " + typeOutput;
			case UniquePtr: "std::make_unique<" + typeOutput + ">";
			case SharedPtr: "std::make_shared<" + typeOutput + ">";
		}
	}

	// Compiles if statement (TIf).
	function compileIf(econd: TypedExpr, ifExpr: TypedExpr, elseExpr: TypedExpr, constexpr: Bool = false): String {
		var result = "if" + (constexpr ? " constexpr" : "") + "(" + Main.compileExpressionOrError(econd.unwrapParenthesis()) + ") {\n";
		result += toIndentedScope(ifExpr);
		if(elseExpr != null) {
			switch(elseExpr.expr) {
				case TIf(econd2, eif2, eelse2): {
					result += "\n} else " + compileIf(econd2, eif2, eelse2, constexpr);
				}
				case _: {
					result += "\n} else {\n";
					result += toIndentedScope(elseExpr);
					result += "\n}";
				}
			}
		} else {
			result += "\n}";
		}
		return result;
	}

	// Recursively unwrap an expression contained within one or more TMeta.
	function unwrapMetaExpr(expr: TypedExpr): Null<{ meta: Array<MetadataEntry>, internalExpr: TypedExpr }> {
		return switch(expr.expr) {
			case TMeta(m, e): {
				final metadata = unwrapMetaExpr(e);
				if(metadata == null) {
					return { meta: [m], internalExpr: e };
				} else {
					metadata.meta.push(m);
					return metadata;
				}
			}
			case _: null;
		}
	}

	// Compiles an expression wrapped by one or more metadata entries.
	function compileExprWithMultipleMeta(metadata: Array<MetadataEntry>, metaExpr: TypedExpr, internalExpr: TypedExpr): Null<String> {
		if(metadata.length == 0) return null;

		// Try and compile the expression.
		// The first "modifying" meta is used.
		var result = null;
		for(m in metadata) {
			final cpp = compileExprWithMeta(m, internalExpr);
			if(cpp != null) {
				result = cpp;
				break;
			}
		}

		// If no meta that modify how the original expression are found,
		// just compile the expression like normal.
		if(result == null) {
			result = Main.compileExpression(internalExpr);
		}

		// Now we check the metadata again for any "wrapper" metadata.
		for(m in metadata) {
			final cpp = wrapExprWithMeta(m, result);
			if(cpp != null) {
				result = cpp;
			}
		}

		return result;
	}

	// Checks for metadata that modifies the original expression.
	// If found, returns the compiled expression based on the metadata.
	function compileExprWithMeta(metaEntry: MetadataEntry, internalExpr: TypedExpr): Null<String> {
		final name = metaEntry.name;
		return switch(name) {
			case ":constexpr": {
				switch(internalExpr.expr) {
					case TIf(econd, eif, eelse): compileIf(econd, eif, eelse, true);
					case _: metaEntry.pos.makeError(ConstExprMetaInvalidUse);
				}
			}
			case _: null;
		}
	}

	// Some metadata may not modify the original expression.
	// Rather, they may need to "wrap" or make some modification post compilation.
	// Such metadata should be implemented here.
	function wrapExprWithMeta(metaEntry: MetadataEntry, cpp: String): Null<String> {
		final name = metaEntry.name;
		return switch(name) {
			case _: null;
		}
	}

	// Checks a TCall expression to see if it is a `trace` call that
	// can be converted to an inline C++ print.
	//
	// (GEEEZZZ this function is too long; that's why its at the bottom.)
	function checkForInlinableTrace(callExpr: TypedExpr, el: Array<TypedExpr>): Null<String> {
		final isTrace = switch(callExpr.expr) {
			case TField(e1, fa): {
				switch(fa) {
					case FStatic(clsRef, cfRef): {
						final cls = clsRef.get();
						final cf = cfRef.get();
						cf.name == "trace" && cls.name == "Log" && cls.module == "haxe.Log";
					}
					case _: false;
				}
			}
			case _: false;
		}
		return if(isTrace && el.length == 2) {
			final inputParams = [el[0]];
			var fileName = "";
			var lineNumber = "";
			var intro = null;
			var posInfosCpp = null;
			switch(el[1].expr) {
				case TObjectDecl(fields): {
					for(f in fields) {
						if(f.name == "customParams") {
							switch(f.expr.expr) {
								case TArrayDecl(el): {
									for(e in el) {
										inputParams.push(e);
									}
								}
								case _: {}
							}
						} else if(f.name == "fileName") {
							fileName = switch(f.expr.expr) {
								case TConst(TString(s)): s;
								case _: "<unknown>";
							}
						} else if(f.name == "lineNumber") {
							lineNumber = switch(f.expr.expr) {
								case TConst(TInt(i)): Std.string(i);
								case _: "0";
							}
						}
					}
				}
				case _: {
					final e1Type = Main.getExprType(el[1]);
					final e1InternalType = e1Type.unwrapNullTypeOrSelf();
					final isPosInfos = switch(e1InternalType) {
						case TType(typeRef, []): {
							final ttype = typeRef.get();
							ttype.name == "PosInfos" && ttype.module == "haxe.PosInfos";
						}
						case _: false;
					}
					if(!isPosInfos) {
						return null;
					}
					final isNull = e1Type.isNull();
					final piCpp = Main.compileExpressionOrError(el[1]);
					final accessCpp = 'temp${isArrowAccessType(e1Type) ? "->" : "."}';
					intro = "auto temp = " + (isNull ? {
						final line = haxe.macro.PositionTools.toLocation(callExpr.pos).range.start.line;
						final file = Context.getPosInfos(callExpr.pos).file;
						final clsConstruct = compileClassConstruction(e1InternalType, e1Type.toModuleType().getCommonData(), [], callExpr.pos);
						(piCpp + ".value_or(" + clsConstruct + "(\"\", " + stringToCpp(file) + "," + line + ", \"\"))");
					} : piCpp) + ";";
					posInfosCpp = '${accessCpp}fileName << ":" << ${accessCpp}lineNumber << ": "';
				}
			}

			var allConst = true;
			var lastString: Null<String> = posInfosCpp != null ? null : (fileName + ":" + lineNumber + ": ");
			var prefixAdded = false;
			final validParams = [];
			function addLastString() {
				prefixAdded = true;
				if(lastString != null) {
					validParams.push(stringToCpp(lastString));
					lastString = null;
				}
			}
			for(e in inputParams) {
				switch(e.expr) {
					case TConst(TInt(_) | TFloat(_)): {
						addLastString();
						validParams.push(Main.compileExpressionOrError(e));
					}
					case TConst(TString(s)): {
						if(lastString == null) {
							lastString = s;
						} else {
							if(!prefixAdded) lastString += s;
							else lastString += ", " + s;
							prefixAdded = true;
						}
					}
					case _: {
						allConst = false;
						break;
					}
				}
			}
			if(allConst) {
				IComp.addInclude("iostream", compilingInHeader, true);
				addLastString();
				final result = if(posInfosCpp != null) {
					"std::cout << " + posInfosCpp + " << " + validParams.join("<< \", \" << ") + " << std::endl";
				} else {
					"std::cout << " + validParams.join("<< \", \" << ") + " << std::endl";
				}
				if(intro != null) {
					"{\n\t" + intro + "\n\t" + result + ";\n}";
				} else {
					result;
				}
			} else {
				null;
			}
		} else {
			null;
		}
	}
}

#end
