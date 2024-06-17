// =======================================================
// * Expressions
//
// This sub-compiler is used to handle compiling of all
// expressions.
// =======================================================

package cxxcompiler.subcompilers;

#if (macro || cxx_runtime)

import haxe.ds.Either;

import reflaxe.helpers.Context; // Use like haxe.macro.Context
import haxe.macro.Expr;
import haxe.macro.Type;

import reflaxe.input.ClassHierarchyTracker;
import reflaxe.compiler.EverythingIsExprSanitizer;

import cxxcompiler.subcompilers.Includes.ExtraFlag;
import cxxcompiler.config.Define;
import cxxcompiler.config.Meta;
import cxxcompiler.other.DependencyTracker;

using reflaxe.helpers.BaseTypeHelper;
using reflaxe.helpers.ClassFieldHelper;
using reflaxe.helpers.DynamicHelper;
using reflaxe.helpers.ModuleTypeHelper;
using reflaxe.helpers.OperatorHelper;
using reflaxe.helpers.NameMetaHelper;
using reflaxe.helpers.NullHelper;
using reflaxe.helpers.NullableMetaAccessHelper;
using reflaxe.helpers.PositionHelper;
using reflaxe.helpers.SyntaxHelper;
using reflaxe.helpers.TypedExprHelper;
using reflaxe.helpers.TypeHelper;

using cxxcompiler.helpers.DefineHelper;
using cxxcompiler.helpers.Error;
using cxxcompiler.helpers.MetaHelper;
using cxxcompiler.helpers.CppTypeHelper;

@:allow(cxxcompiler.Compiler)
@:access(cxxcompiler.Compiler)
@:access(cxxcompiler.subcompilers.Includes)
@:access(cxxcompiler.subcompilers.Types)
class Expressions extends SubCompiler {
	// ----------------------------
	// A public variable modified based on whether the
	// current expression is being compiled for a header file.
	public var compilingInHeader: Bool = false;
	public var compilingForTopLevel: Bool = false;
	function onModuleTypeEncountered(mt: ModuleType, pos: Position) Main.onModuleTypeEncountered(mt, compilingInHeader, pos);

	// ----------------------------
	// If true, `null` is explicitly cast in C++ output.
	public var explicitNull: Bool = false;
	public function setExplicitNull(newVal: Null<Bool>, cond: Bool = true): Null<Bool> {
		if(!cond) return null;
		final old = explicitNull;
		explicitNull = newVal ?? false;
		return old;
	}

	// ----------------------------
	// Track the intended return type using a "Stack" system.
	public var returnTypeStack: Array<Type> = [];
	public function pushReturnType(t: Type) returnTypeStack.push(t);
	public function popReturnType() returnTypeStack.pop();
	public function currentReturnType(): Null<Type> {
		return returnTypeStack.length == 0 ? null : returnTypeStack[returnTypeStack.length - 1];
	}

	// ----------------------------
	// Override the expression used for compiling "this".
	var thisOverride: Null<TypedExpr> = null;

	public function setThisOverride(thisExpr: TypedExpr) {
		thisOverride = thisExpr;
	}

	public function clearThisOverride() {
		thisOverride = null;
	}

	// ----------------------------
	// If `true`, indented scopes will assume a `haxe::NativeStackItem`
	// named `___s` exists and will update its Haxe line.
	var trackLinesCallStack: Bool = false;
	var trackLinesStack: Array<Bool> = [];

	public function pushTrackLines(b: Bool) {
		trackLinesStack.push(trackLinesCallStack);
		trackLinesCallStack = b;
	}

	public function popTrackLines(): Bool {
		return if(trackLinesStack.length > 0) {
			final old = trackLinesStack.pop() ?? false;
			trackLinesCallStack = trackLinesStack.length > 0 ? trackLinesStack[trackLinesStack.length - 1] : false;
			old;
		} else {
			false;
		}
	}

	// ----------------------------
	// Stores field-access expressions that access from `this`.
	// Used in the Class compiler to find fields assigned in the constructor.
	// See TODO in Classes.hx
	var thisFieldsAssigned: Null<Array<String>> = null;

	public function startTrackingThisFields() {
		thisFieldsAssigned = [];
	}

	public function extractThisFields() {
		final result = thisFieldsAssigned;
		thisFieldsAssigned = null;
		return result;
	}

	// ----------------------------
	// Small helper for wrapping C++ code to ensure it doesn't generate
	// an "unused" warning/error.
	function unusedCpp(cpp: Null<String>): Null<String> {
		return cpp != null ? 'static_cast<void>($cpp)' : null;
	}

	// ----------------------------
	// If the return of a field access or call is [[nodiscard]],
	// wrap or remove to avoid errors.
	function handleUnused(expr: TypedExpr, cpp: Null<String>, unwrapCall: Bool): Null<String> {
		final clsField = expr.getClassField(unwrapCall);
		if(clsField?.hasMeta(Meta.NoDiscard) ?? false) {
			if(clsField.trustMe().meta.extractPrimtiveFromFirstMeta(Meta.NoDiscard) == true) {
				return null;
			} else {
				return unusedCpp(cpp);
			}
		}
		return cpp;
	}

	// ----------------------------
	// Compiles an expression into C++.
	public function compileExpressionToCpp(expr: TypedExpr, topLevel: Bool): Null<String> {
		// cxx.Stynax.classicFor
		final classicForArgs = expr.isStaticCall("cxx.Syntax", "classicFor");
		if(classicForArgs != null) {
			function arg(i: Int) {
				final e = classicForArgs[i];
				return switch(e.expr) {
					case TIdent("_"): "";
					case _: Main.compileExpression(e);
				}
			}
			return 'for(${arg(0)}; ${arg(1)}; ${arg(2)}) {\n${toIndentedScope(classicForArgs[3])}\n}';
		}

		// Check TypedExprDef
		var result: Null<String> = null;
		switch(expr.expr) {
			case TConst(_) if(topLevel): {
				result = null;
			}
			case TConst(constant): {
				if(!topLevel) {
					result = constantToCpp(constant, expr);
				}
			}
			case TCall(callExpr, el) if(switch(callExpr.expr) { case TConst(TSuper): true; case _: false; }): {
				if(CComp.superConstructorCall == null) {
					CComp.superConstructorCall = compileCall(callExpr, el, expr);
				} else {
					throw "`super` constructor call made multiple times!";
				}
				result = null;
			}
			case TLocal(v): {
				if(!topLevel) {
					IComp.addIncludeFromMetaAccess(v.meta, compilingInHeader);
					result = Main.compileVarName(v.name, expr);
				}
			}
			case TIdent(s): {
				result = Main.compileVarName(s, expr);
			}
			case TArray(e1, e2): {
				result = compileExpressionNotNullAsValue(e1) + "[" + compileExpressionNotNull(e2) + "]";
			}
			case TBinop(op, { expr: TConst(TNull) }, nullCompExpr) |
			     TBinop(op, nullCompExpr, { expr: TConst(TNull) })
				 if(op == OpEq || op == OpNotEq):
			{
				result = Main.compileExpression(nullCompExpr);

				if(!Main.getExprType(nullCompExpr).isNull()) {
					// The type is non-nullable, so we'll just use the bool operator instead.
					switch(op) {
						case OpNotEq: {}
						case OpEq: {
							result = "!" + result;
						}
						case _: {}
					}
				} else {
					// The type is nullable, so we can use std::optional methods.
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
			}
			case TBinop(op, e1, e2): {
				result = binopToCpp(op, e1, e2, expr.pos);
			}
			case TField(e, fa): {
				result = fieldAccessToCpp(e, fa, expr);

				if(topLevel) {
					result = handleUnused(expr, result, false);
				}
			}
			case TTypeExpr(m): {
				IComp.addTypeUtilHeader(compilingInHeader);
				Main.onModuleTypeEncountered(m, compilingInHeader, expr.pos);
				result = "haxe::_class<" + moduleNameToCpp(m, expr.pos) + ">()";
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
				result = AComp.compileObjectDecl(Main.getExprType(expr), fields, expr, compilingInHeader);
			}
			case TArrayDecl(el): {
				Main.onTypeEncountered(expr.t, compilingInHeader, expr.pos);
				IComp.includeMMType(SharedPtr, compilingInHeader);
				final arrayType = Main.getExprType(expr).unwrapArrayType();
				final t = TComp.compileType(arrayType, expr.pos);
				final d = "std::deque<" + t + ">";
				result = Compiler.SharedPtrMakeCpp + "<" + d + ">(" + d + ({
					if(el.length > 0) {
						final cppList: Array<String> = el.map(e -> compileExpressionForType(e, arrayType).trustMe());
						var newLines = false;
						for(cpp in cppList) {
							if(cpp.length > 5) {
								newLines = true;
								break;
							}
						}
						newLines ? ("{\n\t" + cppList.join(",\n\t") + "\n}") : ("{ " + cppList.join(", ") + " }");
					} else {
						"{}";
					}
				}) + ")";
			}
			case TCall({ expr: TIdent("__include__") }, el): {
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
			case TCall({ expr: TIdent("__using_namespace__") }, el): {
				switch(el) {
					case [{ expr: TConst(TString(s)) }]: {
						IComp.addUsingNamespace(s);
					}
					case _: {}
				}
				result = null;
			}
			case TCall(callExpr, el): {
				result = compileCall(callExpr, el, expr);

				if(topLevel) {
					result = handleUnused(expr, result, false);
				}
			}
			case TNew(classTypeRef, params, el): {
				onModuleTypeEncountered(TClassDecl(classTypeRef), expr.pos);
				result = compileNew(expr, TInst(classTypeRef, params), el);
				if(topLevel && !Define.KeepUnusedLocals.defined()) {
					result = unusedCpp(result);
				}
			}
			case TUnop(op, postFix, e): {
				result = unopToCpp(op, e, postFix);
			}
			case TFunction(tfunc): {
				result = compileLocalFunction(null, expr, tfunc);
			}
			case TVar(tvar, maybeExpr) if(!Define.KeepUnusedLocals.defined() && tvar.meta.maybeHas("-reflaxe.unused")): {
				if(maybeExpr != null && maybeExpr.isMutator() && maybeExpr.isStaticCall("cxx.Syntax", "NoAssign", true) == null) {
					result = Main.compileExpression(maybeExpr);

					// C++ will complain about an object being created but not assigned,
					// so wrap with void cast to avoid.
					final noDiscard = switch(maybeExpr.unwrapParenthesis().expr) {
						case TNew(_, _, ): true; // constructing is inheritely no discard
						case _: {
							final clsField = maybeExpr.getClassField(true);
							clsField?.hasMeta(Meta.NoDiscard) ?? false;
						}
					}
					if(noDiscard) {
						result = unusedCpp(result);
					}
				} else {
					result = null;
				}
			}
			case TVar(tvar, maybeExpr): {
				result = compileLocalVariable(tvar, maybeExpr, expr, false);
			}
			case TBlock(_): {
				result = "{\n";
				result += toIndentedScope(expr);
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
				final nullableBoolT = TAbstract(Main.getNullType(), [Context.getType("Bool")]);
				final cppCond = XComp.compileExpressionForType(econd.unwrapParenthesis(), nullableBoolT);
				if(normalWhile) {
					result = "while(" + cppCond + ") {\n";
					result += toIndentedScope(blockExpr);
					result += "\n}";
				} else {
					result = "do {\n";
					result += toIndentedScope(blockExpr);
					result += "\n} while(" + cppCond + ")";
				}
			}
			case TSwitch(e, cases, edef): {
				result = compileSwitch(e, cases, edef);
			}
			case TTry(e, catches): {
				final tryContent = toIndentedScope(e);
				if(tryContent != null) {
					if(Define.ExceptionsDisabled.defined()) {
						e.pos.makeWarning(UsedTryWhenExceptionsDisabled);
						result = "{\n" + tryContent + "\n}";
					} else {
						result = "try {\n" + tryContent;
						for(c in catches) {
							// Get catch type
							final errType = Main.getTVarType(c.v);
							Main.onTypeEncountered(errType, compilingInHeader, c.expr.pos);

							// Compile as reference
							final refType = TType(Main.getRefType(), [errType]);
							result += "\n} catch(" + TComp.compileType(refType, expr.pos, true) + " " + c.v.name + ") {\n";

							// Compile catch expression content
							if(c.expr != null) {
								final cpp = toIndentedScope(c.expr);
								if(cpp != null) result += cpp;
							}
						}
						result += "\n}";
					}
				}
			}
			case TReturn(maybeExpr): {
				final cpp = maybeExpr != null ? {
					final rt = currentReturnType();
					if(rt != null) {
						compileExpressionForType(maybeExpr, rt);
					} else {
						Main.compileExpression(maybeExpr);
					}
				} : null;

				// Check if throw statement.
				var returnThrow = false;
				if(maybeExpr != null) {
					switch(maybeExpr.unwrapParenthesis().expr) {
						case TThrow(throwExpr):
							returnThrow = true;
						case _:
					}
				}

				if(returnThrow) {
					// `throw` can't be returned, so we'll just ignore the return.
					result = cpp;
				} else if(cpp != null) {
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
			case TThrow(thrownExpr): {
				var generateThrow = #if macro cxx.Compiler.exceptionHandlingEnabled #else true #end;
				if(Define.ExceptionsDisabled.defined()) {
					expr.pos.makeWarning(UsedTryWhenExceptionsDisabled);
					generateThrow = false;
				}
				
				if(generateThrow) {
					final e = Main.compileExpressionOrError(thrownExpr);
					result = if(Main.getExprType(thrownExpr).isString()) {
						Main.onTypeEncountered(Context.getType("haxe.Exception"), compilingInHeader, expr.pos);
						"throw haxe::Exception(" + e + ")";
					} else {
						"throw " + e;
					}
				} else {
					result = "exit(1)";
				}
			}
			case TCast(e, maybeModuleType): {
				result = compileCast(e, expr, maybeModuleType);
			}
			case TMeta(_, _): {
				final unwrappedInfo = unwrapMetaExpr(expr).trustMe();

				var ignore = false;
				for(m in unwrappedInfo.meta) {
					if(m.name == ":ignore") {
						ignore = true;
						break;
					}
				}

				if(!ignore) {
					final cpp = compileExprWithMultipleMeta(unwrappedInfo.meta, expr, unwrappedInfo.internalExpr);
					result = cpp ?? Main.compileExpression(unwrappedInfo.internalExpr);
				}
			}
			case TEnumParameter(expr, enumField, index): {
				IComp.addIncludeFromMetaAccess(enumField.meta, compilingInHeader);
				result = compileExpressionNotNull(expr);
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
				final cpp = compileExpressionNotNull(expr);
				result = switch(expr.t) {
					case TEnum(_.get() => e, _) if(e.hasMeta(Meta.CppEnum)): {
						"static_cast<int>(" + cpp + ")";
					}
					case _: {
						final access = isArrowAccessType(Main.getExprType(expr)) ? "->" : ".";
						cpp + access + "index";
					}
				}
			}
		}

		return result;
	}

	function compileExpressionNotNull(expr: TypedExpr): String {
		final unwrapOptional = switch(expr.expr) {
			case TLocal(_): true;
			case TIdent(_): true;
			case TField(_, _): true;
			case TCall(_, _): true;
			case _: false;
		}

		var result = Main.compileExpressionOrError(expr);

		if(unwrapOptional) {
			final t = Main.getExprType(expr);
			if(t.isNull() && !expr.isNullExpr()) {
				final isValue = t.getInternalType().isTypeParameter() || Types.getMemoryManagementTypeFromType(t) == Value;
				result = ensureSafeToAccess(result) + (isValue ? ".value()" : '.value_or(${Compiler.PointerNullCpp})');
			}
		}

		return result;
	}

	function compileExpressionAsValue(expr: TypedExpr): String {
		return compileMMConversion(expr, Right(Value), true);
	}

	function compileExpressionNotNullAsValue(expr: TypedExpr): String {
		return compileMMConversion(expr, Right(Value));
	}

	// ----------------------------
	// Compile expression, but take into account the target type
	// and apply additional conversions in the compiled code.
	public function compileExpressionForType(expr: TypedExpr, targetType: Null<Type>, allowNullReturn: Bool = false): Null<String> {
		var cpp = null;

		if(targetType != null) {
			expr = expr.unwrapUnsafeCasts();
			if(Main.getExprType(expr).shouldConvertMM(targetType)) {
				cpp = compileMMConversion(expr, Left(targetType));
			} else {
				// Unnamed anonymous structs are always `SharedPtr`s, we use applyMMConversion to 
				// format the generated C++ code from `Value` to `SharedPtr`.
				//
				// We don't need to worry about the memory management type of the input expression
				// since anonymous structs use `haxe::unwrap<T>` to access the fields of any type.
				final exprInternalType = Main.getExprType(expr).getInternalType();
				if(!exprInternalType.isAnonStruct() && targetType.isAnonStructOrNamedStruct()) {
					// In an earlier version, all expressions were converted to `Value`.
					// Here's the code needed to achieve that in case required in the future:
					// `compileMMConversion(expr, Right(Value));`
					final exprCpp = Main.compileExpressionOrError(expr);
					cpp = applyMMConversion(exprCpp, expr.pos, targetType, Value, SharedPtr);
				}
			}
		}
		if(cpp == null) {
			cpp = internal_compileExpressionForType(expr, targetType, allowNullReturn, true);
		}
		return cpp;
	}

	// ----------------------------
	// Internally compiles the expression for a type.
	// Used in multiple places where the special cases for the target type do not apply.
	function internal_compileExpressionForType(expr: TypedExpr, targetType: Null<Type>, allowNullReturn: Bool, allowNullValueUnwrap: Bool = false): Null<String> {
		var result = switch(expr.unwrapMeta().expr) {
			case TConst(TNull) if(targetType != null && !targetType.isNull() && !expr.hasMeta("-conflicting-default-value")): {
				if(Types.getMemoryManagementTypeFromType(targetType) == Value) {
					expr.pos.makeError(ValueAssignedNull);
				} else if(!Define.NoNullAssignWarnings.defined()) {
					expr.pos.makeWarning(UsedNullOnNonNullable);
				}
				constantToCpp(TNull, expr, true);
			}
			case TConst(TFloat(fStr)) if(targetType != null && targetType.getNumberTypeSize() == 32): {
				constantToCpp(TFloat(fStr), expr) + "f";
			}
			case TObjectDecl(fields) if(targetType != null): {
				AComp.compileObjectDecl(targetType, fields, expr, compilingInHeader);
			}

			// case TField(e, fa): {
			// 	fieldAccessToCpp(e, fa, expr, targetType);
			// }
			// case _: {
			// 	final old = setExplicitNull(true, targetType != null && targetType.isAmbiguousNullable());
			// 	final result = allowNullReturn ? Main.compileExpression(expr) : Main.compileExpressionOrError(expr);
			// 	setExplicitNull(old);
			// 	result;
			// }

			case exprDef: {
				final unwrapNullValue = (allowNullValueUnwrap && targetType != null) ? Main.getExprType(expr).isNullOfAssignable(targetType) : false;
				final old = setExplicitNull(true, targetType != null && targetType.isAmbiguousNullable());
				final result = switch(exprDef) {
					case TField(e, fa): fieldAccessToCpp(e, fa, expr, targetType);
					case _ if(allowNullReturn): Main.compileExpression(expr);
					case _: Main.compileExpressionOrError(expr);
				}
				setExplicitNull(old);
				if(result != null && unwrapNullValue) {
					ensureSafeToAccess(result) + ".value()";
				} else {
					result;
				}
			}
		}

		if(targetType != null) {
			if(!Define.DontCastNumComp.defined()) {
				final st = Main.getExprType(expr).unwrapNullTypeOrSelf();
				final tt = targetType.unwrapNullTypeOrSelf();
				if(tt.isCppNumberType() && st.isCppNumberType() && st.shouldCastNumber(tt)) {
					result = '(${TComp.compileType(tt, expr.pos)})($result)';
				}
			}
		}

		return result;
	}

	// ----------------------------
	// If the memory management type of the target type (or target memory management type)
	// is different from the provided expression, compile the expression and with additional
	// conversions in the generated code.
	function compileMMConversion(expr: TypedExpr, target: Either<Type, MemoryManagementType>, allowNull: Bool = false): String {
		final cmmt = Types.getMemoryManagementTypeFromType(Main.getExprType(expr));

		var tmmt;
		var targetType: Null<Type>;
		var exprIsNullable = Main.getExprType(expr).isNull();
		var nullToValue;
		switch(target) {
			case Left(tt): {
				tmmt = Types.getMemoryManagementTypeFromType(tt);
				targetType = tt;
				allowNull = tt.isNull();

				// TODO:
				// Only allow `null` conversion if the exact same type??
				// Currently testing without checking if types equal.
				// final sameValueType = Main.getExprType(expr).unwrapNullTypeOrSelf().valueTypesEqual(tt.unwrapNullTypeOrSelf());
				nullToValue = allowNull ? false : exprIsNullable; // (sameValueType ? exprIsNullable : false);
			}
			case Right(mmt): {
				tmmt = mmt;
				targetType = null;
				nullToValue = allowNull ? false : exprIsNullable;
			}
		}

		// If converting between memory management types AND both are nullable,
		// the source expression must still be unwrapped for proper conversion.
		final nullMMConvert = cmmt != tmmt && allowNull && exprIsNullable;

		// Store the result when possible
		var result = null;

		// Unwraps Null<T> (std::optional) if converting from optional -> not optional
		inline function convertCppNull(cpp: String, pointerType: Bool): String {
			// This is true if `null` is not allowed, but the source expression is nullable.
			final nullToNotNull = !allowNull && nullToValue && !expr.isNullExpr();
			if(nullMMConvert || nullToNotNull) {
				return ensureSafeToAccess(cpp) + (pointerType ? '.value_or(${Compiler.PointerNullCpp})' : ".value()");
			}
			return cpp;
		}

		// Convert between two shared pointers
		if(cmmt == SharedPtr && tmmt == SharedPtr && targetType != null) {
			if(Main.getExprType(expr).isDescendantOf(targetType)) {
				var cpp = internal_compileExpressionForType(expr, targetType, false);
				if(cpp != null) {
					IComp.addInclude("memory", compilingInHeader, true);
					cpp = convertCppNull(cpp, true);
					result = "std::static_pointer_cast<" + TComp.compileType(targetType, expr.pos, true) + ">(" + cpp + ")";
				}
			}
		}

		// Convert between two different memory management types (or nullable -> not nullable)
		if((cmmt != tmmt || nullToValue) && result == null) {
			switch(expr.expr) {
				case TConst(TThis) if(thisOverride == null && tmmt == SharedPtr): {
					IComp.setExtraFlag(ExtraFlag.SharedFromThis);
					result = "this->weak_from_this().expired() ? " + Compiler.SharedPtrMakeCpp + "<" + TComp.compileType(Main.getExprType(expr), expr.pos, true) + ">(*this) : this->shared_from_this()";
				}
				case TConst(TThis) if(thisOverride == null && tmmt == UniquePtr): {
					expr.pos.makeError(ThisToUnique);
				}
				case TNew(classTypeRef, params, el): {
					result = compileNew(expr, TInst(classTypeRef, params), el, tmmt);
				}
				case _: {
					var cpp = internal_compileExpressionForType(expr, targetType, true);
					if(cpp != null) {
						// If we converting between two different memory types that are both nullable,
						// let's create an alias (new variable) before checking whether a value exists.
						final hasAlias = nullMMConvert ? addPrefixExpression("auto v = " + cpp) : false;
						final code = hasAlias ? "v" : cpp;

						// Apply memory management conversion
						var pointerType = cmmt != Value;
						if(targetType == null || targetType.getInternalType().isTypeParameter()) {
							pointerType = false;
						}
						final newCpp = convertCppNull(code, pointerType);
						result = applyMMConversion(newCpp, expr.pos, Main.getExprType(expr), cmmt, tmmt);

						// If we converting between two different memory types that are both nullable,
						// lets first check that the source expression HAS a value.
						//
						// If it does, we use the conversion code. Otherwise we return `std::nullopt`.
						if(nullMMConvert) {
							// If we can successfully add the prefix expression, use `v`.
							// Otherwise, we have to repeat the `cpp` code when checking for value.
							final condVar = hasAlias ? "v" : cpp;
							final tCpp = TComp.compileType(targetType ?? Main.getExprType(expr), expr.pos, true);
							result = '${condVar}.has_value() ? (${tCpp})${result} : ${Compiler.OptionalNullCpp}';
						}
					}
				}
			}
		}
		
		if(result == null) {
			result = internal_compileExpressionForType(expr, targetType, false);
		}

		return result.trustMe();
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
					case SharedPtr: Compiler.SharedPtrMakeCpp + "<" + typeCpp() + ">(" + cpp + ")";
					case UniquePtr: Compiler.UniquePtrMakeCpp + "<" + typeCpp() + ">(" + cpp + ")";
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
		var el = switch(e.expr) {
			case TBlock(el): el;
			case _: [e];
		}

		if(!Define.KeepUselessExprs.defined()) {
			el = el.filter(TypedExprHelper.isMutator);
		}

		return if(el.length == 0) {
			"";
		} else {
			Main.compileExpressionsIntoLines(el).tab();
		}
	}

	function addPrefixExpression(cpp: String): Bool {
		return Main.injectExpressionPrefixContent(cpp);
	}

	function constantToCpp(constant: TConstant, originalExpr: TypedExpr, useUntypedNull: Bool = false): String {
		return switch(constant) {
			case TInt(i): Std.string(i);
			case TFloat(s): s;
			case TString(s): stringToCpp(s);
			case TBool(b): b ? "true" : "false";
			case TNull: {
				final nullExpr = useUntypedNull ? Compiler.PointerNullCpp : Compiler.OptionalNullCpp;
				final cppType = TComp.maybeCompileType(Main.getExprType(originalExpr), originalExpr.pos);
				if(explicitNull && cppType != null) {
					"static_cast<" + cppType + ">(" + nullExpr + ")";
				} else {
					nullExpr;
				}
			}
			case TThis: {
				if(thisOverride != null) {
					Main.compileExpressionOrError(thisOverride);
				} else {
					"this";
				}
			}
			case TSuper: {
				if(Main.superTypeName != null) {
					Main.superTypeName;
				} else {
					originalExpr.pos.makeError(NoSuperWithoutSuperClass);
				}
			}
			case _: "";
		}
	}

	function stringToLiteralCpp(s: String): String {
		var result = StringTools.replace(s, "\\", "\\\\");
		result = StringTools.replace(result, "\"", "\\\"");
		result = StringTools.replace(result, "\t", "\\t");
		result = StringTools.replace(result, "\n", "\\n");
		result = StringTools.replace(result, "\r", "\\r");
		return "\"" + result + "\"";
	}

	public function stringToCpp(s: String): String {
		// Add backslash to all quotes and backslashes.
		var result = stringToLiteralCpp(s);

		#if cxx_disable_haxe_std
		return result;
		#end

		if(#if macro cxx.Compiler.retainConstCharLiterals #else false #end) {
			return result;
		}

		final strCppOverride = NameMetaHelper.getNativeNameOverride("String");
		if(strCppOverride != null || compilingInHeader) {
			// If compiling in header, we don't want to taint the global namespace with "using namespace",
			// so we just wrap the const char* in std::string(...).
			final cppStringType = strCppOverride ?? "std::string";
			result = cppStringType + "(" + result + ")";
		} else {
			// If compiling in source file, std::string literal can be used with the "s" suffix.
			// Just make sure "using namespace std::string_literals" is added.
			IComp.addUsingNamespace("std::string_literals");
			result += "s";
		}

		// Ensure string is included
		IComp.addInclude(Includes.StringInclude, compilingInHeader, true);

		return result;
	}

	/**
		Generates the C++ code for a Haxe infix operator expression.
	**/
	function binopToCpp(op: Binop, e1: TypedExpr, e2: TypedExpr, opPos: Position): String {
		// Check for Dynamic property assignment
		if(op.isAssignDirect()) {
			final dynSetCpp = checkDynamicSet(e1, e2);
			if(dynSetCpp != null) {
				return dynSetCpp;
			}
		}

		var cppExpr1 = if(op.isAssignDirect()) {
			Main.compileExpressionOrError(e1);
		} else if(useEnumIndexEquality(e1)) {
			Main.compileExpressionOrError(e1) + "->index";
		} else if(op.isEqualityCheck()) {
			compileForEqualityBinop(e1);
		} else {
			compileExpressionNotNullAsValue(e1);
		}

		var cppExpr2 = if(op.isAssign()) {
			compileExpressionForType(e2, Main.getExprType(e1));
		} else if(useEnumIndexEquality(e2)) {
			Main.compileExpressionOrError(e2) + "->index";
		} else if(op.isEqualityCheck()) {
			compileForEqualityBinop(e2);
		} else {
			compileExpressionNotNullAsValue(e2);
		}

		// TODO: Is unsigned shift right is only generated for Int?
		final isUShrAssign = op.isAssignOp(OpUShr);
		if(isUShrAssign || op.isUnsignedShiftRight()) {
			var cpp = "static_cast<unsigned int>(" + cppExpr1 + ") >> " + cppExpr2;
			if(isUShrAssign) {
				cpp = cppExpr1 + " = " + cpp;
			}
			return cpp;
		}

		// Check if one of the numbers should be casted.
		// Certain C++ warnings require both numbers to be the same.
		if(!Define.DontCastNumComp.defined()) {
			final comparisonOp = switch(op) {
				case OpEq | OpNotEq | OpGt | OpGte | OpLt | OpLte: true;
				case _: false;
			}

			final t1 = Main.getExprType(e1).unwrapNullTypeOrSelf();
			final t2 = Main.getExprType(e2).unwrapNullTypeOrSelf();

			if(comparisonOp && t1.isCppNumberType() && t2.isCppNumberType()) {
				// If `true`, cast t2 to t1.
				// If `false`, cast t1 to t2.
				// If `null`, don't cast anything.
				final castBothToT1: Null<Bool> = {
					if(t1.equals(t2)) null;
					// Cast to type that is "float".
					else if(t1.isFloatType() != t2.isFloatType())
						t1.isFloatType();
					// Cast to type that is larger.
					else if(t1.getNumberTypeSize() != t2.getNumberTypeSize())
						t1.getNumberTypeSize() > t2.getNumberTypeSize();
					// Cast to type that is signed.
					else if(t1.isUnsignedType() != t2.isUnsignedType())
						!t1.isUnsignedType();
					else null;
				}

				if(castBothToT1 != null) {
					if(castBothToT1 == true) {
						cppExpr2 = '(${TComp.compileType(t1, e2.pos)})($cppExpr2)';
					} else if(castBothToT1 == false) {
						cppExpr1 = '(${TComp.compileType(t2, e2.pos)})($cppExpr1)';
					}
				}
			}
		}

		#if (cxx_disable_haxe_std || display)
		if(op.isEqualityCheck()) {
			if(Main.getExprType(e1).isString() || Main.getExprType(e2).isString()) {
				IComp.addInclude("cstring", compilingInHeader, true);
				return 'strcmp($cppExpr1, $cppExpr2)' + (op.isEquals() ? " == 0" : " != 0");
			}
		}
		#end

		final operatorStr = OperatorHelper.binopToString(op);

		// Wrap primitives with std::to_string(...) when added with String
		if(op.isAddition()) {
			#if (cxx_disable_haxe_std || display)
			if(Main.getExprType(e1).isString() || Main.getExprType(e2).isString()) {
				opPos.makeError(NoStringAddWOHaxeStd);
			}
			#end

			var usedToString = false;
			if(checkForPrimitiveStringAddition(e1, e2)) {
				cppExpr2 = Compiler.ToStringFromPrim + "(" + cppExpr2 + ")";
				usedToString = true;
			}
			if(checkForPrimitiveStringAddition(e2, e1)) {
				cppExpr1 = Compiler.ToStringFromPrim + "(" + cppExpr1 + ")";
				usedToString = true;
			}
			if(usedToString && Compiler.ToStringFromPrimInclude != null) {
				IComp.addInclude(Compiler.ToStringFromPrimInclude[0], compilingInHeader, Compiler.ToStringFromPrimInclude[1]);
			}
		}

		// Check if we need parenthesis. Used to fix some C++ warnings.
		// https://learn.microsoft.com/en-us/cpp/error-messages/compiler-warnings/compiler-warning-level-3-c4554
		{
			var parenthesis1 = false;
			var parenthesis2 = false;

			final opCombos = [
				[OpShl, OpShr, OpUShr],
				[OpBoolAnd, OpBoolOr],
				[OpAnd, OpOr, OpXor]
			];

			for(combo in opCombos) {
				final temp = checkIfBinopWrapNeeded(combo, op, e1, e2);
				if(temp.p1) parenthesis1 = true;
				if(temp.p2) parenthesis2 = true;
				if(parenthesis1 && parenthesis2) break;
			}

			// Wrap expressions
			if(parenthesis1)
				cppExpr1 = '($cppExpr1)';
			if(parenthesis2)
				cppExpr2 = '($cppExpr2)';
		}

		// Generate final C++ code!
		return cppExpr1 + " " + operatorStr + " " + cppExpr2;
	}

	/**
		The only time enum comparisons are allowed is for direct, no-argument enums.
		In these cases, all we need to do is compare the "index".

		The only exception is for `@:cppEnum` enums.
	**/
	function useEnumIndexEquality(expr: TypedExpr): Bool {
		final t = Main.getExprType(expr);
		return switch(t) {
			case TEnum(enmRef, _): !enmRef.get().hasMeta(Meta.CppEnum);
			case _: false;
		}
	}

	/**
		Quick helper to determine if parenthesis are needed for one
		or multiple infix operators. Used to avoid certain C++ warnings.
	**/
	function checkIfBinopWrapNeeded(operators: Array<Binop>, op: Binop, e1: TypedExpr, e2: TypedExpr): { p1: Bool, p2: Bool } {
		// Returns `true` if a Binop that should be wrapped with parenthesis.
		function isWrapOp(op: Null<Binop>)
			return op != null && operators.contains(op);

		final result = { p1: false, p2: false };

		final binop1 = switch(e1.expr) { case TBinop(op, _, _): op; case _: null; }
		final binop2 = switch(e2.expr) { case TBinop(op, _, _): op; case _: null; }
		if(isWrapOp(op)) {
			result.p1 = binop1 != null;
			result.p2 = binop2 != null;
		} else if(isWrapOp(binop1)) {
			result.p1 = true;
		} else if(isWrapOp(binop2)) {
			result.p2 = true;
		}

		return result;
	}

	/**
		Assuming there is a direct assignment between `e1` and `e2`,
		check if this is a `Dynamic` property assignment.

		Return the compiled C++ content if so; otherwise, return `null`.
	**/
	inline function checkDynamicSet(e1: TypedExpr, e2: TypedExpr): Null<String> {
		return switch(e1.unwrapParenthesis().expr) {
			case TField(dynExpr, fa) if(Main.getExprType(dynExpr).isDynamic()): {
				switch(fa) {
					case FDynamic(s):
						'${Main.compileExpressionOrError(dynExpr)}.setProp("$s", ${Main.compileExpressionOrError(e2)})';
					case _:
						null;
				}
			}
			case TArray(e1, eIndex) if(Main.getExprType(e1).isDynamic()): {
				'${Main.compileExpressionOrError(e1)}.setProp("[]", ${Main.compileExpressionOrError(eIndex)})(${Main.compileExpressionOrError(e2)})';
			}
			case _: null;
		}
	}

	inline function compileForEqualityBinop(e: TypedExpr) {
		return if(Main.getExprType(e).getMeta().maybeHas(Meta.DirectEquality)) {
			Main.compileExpressionOrError(e);
		} else {
			compileExpressionAsValue(e);
		}
	}

	inline function checkForPrimitiveStringAddition(strExpr: TypedExpr, primExpr: TypedExpr) {
		return Main.getExprType(strExpr).isString() && Main.getExprType(primExpr).isPrimitive();
	}

	function unopToCpp(op: Unop, e: TypedExpr, isPostfix: Bool): String {
		final cppExpr = compileExpressionNotNull(e);
		final operatorStr = OperatorHelper.unopToString(op);
		return isPostfix ? (cppExpr + operatorStr) : (operatorStr + cppExpr);
	}

	/**
		Used exclusively in `compileLocalFunction` to track the
		local function stack.
	**/
	var localFunctionStack: Array<String> = [];

	/**
		Compiles a `TFunction` `TypedExprDef`.
	**/
	function compileLocalFunction(name: Null<String>, expr: TypedExpr, tfunc: TFunc): String {
		IComp.addInclude("functional", compilingInHeader, true);
		final captureType = compilingForTopLevel ? "" : "&";
		var result = "[" + captureType + "](" + tfunc.args.map(a -> Main.compileFunctionArgument(a, expr.pos, false, true)).join(", ") + ") mutable {\n";
		
		// Setup call stack tracking for local function
		final localFuncName = name ?? "<unnamed>";
		if(Define.Callstack.defined()) {
			IComp.addNativeStackTrace(expr.pos);
			final functionName = CComp.currentFunction != null ? CComp.currentFunction.field.name : "<unknown>";
			final parentLocalNames = localFunctionStack.length > 0 ? (localFunctionStack.join(".") + ".") : "";
			final stackFuncName = functionName + "." + parentLocalNames + localFuncName;
			result += generateStackTrackCode(Main.currentModule?.getCommonData(), stackFuncName, expr.pos).tab() + ";\n";
		}

		localFunctionStack.push(localFuncName);
		pushReturnType(tfunc.t);
		result += toIndentedScope(tfunc.expr);
		popReturnType();
		localFunctionStack.pop();
		
		result += "\n}";

		return result;
	}

	/**
		Compiles a `TVar` `TypedExprDef`.
	**/
	function compileLocalVariable(tvar: TVar, maybeExpr: Null<TypedExpr>, originalExpr: TypedExpr, constexpr: Bool) {
		Main.determineTVarType(tvar, maybeExpr);
		final t = Main.getTVarType(tvar);
		Main.onTypeEncountered(t, compilingInHeader, originalExpr.pos);

		if(t.requiresValue() && maybeExpr == null) {
			originalExpr.pos.makeError(InitializedTypeRequiresValue);
		}

		final typeCpp = if(t.isUnresolvedMonomorph()) {
			// TODO: Why use std::any instead of auto?
			// I must have originally made this resolve to Any for a reason?
			// But Haxe's Any will only apply if explicitly typed as Any.
			//
			//IComp.addInclude("any", compilingInHeader, true);
			//"std::any";

			"auto";
		} else {
			TComp.compileType(t, originalExpr.pos);
		}

		// Generate attributes for the local variable
		final attributes = [];
		if(constexpr) {
			attributes.push("constexpr");
		}
		final prefix = attributes.length > 0 ? (attributes.join(" ") + " ") : "";

		// Generate variable declaration
		var result = prefix + typeCpp + " " + Main.compileVarName(tvar.name, originalExpr);

		// Generate expression assignment if it exists
		if(maybeExpr != null) {
			final isNoAssign = maybeExpr.isStaticCall("cxx.Syntax", "NoAssign", true);
			final cpp = switch(maybeExpr.expr) {
				case _ if(isNoAssign != null): {
					if(isNoAssign.length == 0) {
						"";
					} else {
						'(${isNoAssign.map(Main.compileExpressionOrError).join(", ")})';
					}
				}
				case TFunction(tfunc): {
					" = " + compileLocalFunction(tvar.name, originalExpr, tfunc);
				}
				case _: {
					" = " + compileExpressionForType(maybeExpr, t);
				}
			}
			result += cpp;
		} else if(t.isPtr()) {
			result += " = " + Compiler.PointerNullCpp;
		} else {
			#if !cxx_dont_default_assign_numbers
			final valString = t.getDefaultValue();
			if(valString != null) {
				result += " = " + valString;
			}
			#end
		}
		return result;
	}

	/**
		Checks if the `TypedExpr` is a representation of `this`.
	**/
	function isThisExpr(te: TypedExpr): Bool {
		return switch(te.expr) {
			case TConst(TThis) if(thisOverride == null): {
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

	/**
		Checks if the `haxe.macro.Type` should use the arrow operator
		for dot-access by default.
	**/
	function isArrowAccessType(t: Type): Bool {
		final ut = t.unwrapNullTypeOrSelf();

		// Unwrap cxx.Ref or cxx.ConstRef
		final unwrappedConst = ut.unwrapRefOrConstRef();
		if(unwrappedConst != null) {
			return isArrowAccessType(unwrappedConst);
		}

		// Check for @:arrowAccess
		final meta = ut.getMeta();
		if(meta.maybeHas(Meta.ArrowAccess)) return true;

		final mmt = Types.getMemoryManagementTypeFromType(ut);
		return mmt != Value;
	}

	function fieldAccessToCpp(e: TypedExpr, fa: FieldAccess, accessExpr: TypedExpr, targetType: Null<Type> = null): String {
		final nameMeta: NameAndMeta = switch(fa) {
			case FInstance(_, _, classFieldRef): classFieldRef.get();
			case FStatic(_, classFieldRef): classFieldRef.get();
			case FAnon(classFieldRef): classFieldRef.get();
			case FClosure(_, classFieldRef): classFieldRef.get();
			case FEnum(_, enumField): enumField;
			case FDynamic(s): {
				if(Main.getExprType(e).isDynamic()) {
					final e = Main.compileExpressionOrError(e);
					final name = s;
					return '$e.getProp("$name")';
				}
				{ name: s, meta: null };
			}
		}

		if(nameMeta.hasMeta(Meta.Uncompilable)) {
			accessExpr.pos.makeError(UncompilableField);
		}

		IComp.addIncludeFromMetaAccess(nameMeta.meta, compilingInHeader);

		return if(nameMeta.hasNativeMeta()) {
			// If this field is of a non-extern module type, let's encounter it.
			switch(fa) {
				case FInstance(clsRef, _, _) | FStatic(clsRef, _) if(!clsRef.get().isExtern): {
					onModuleTypeEncountered(TClassDecl(clsRef), accessExpr.pos);
				}
				case _:
			}

			// @:native
			nameMeta.getNameOrNative();
		} else {
			// C++ field access requires the type to be #included.
			IComp.addIncludeFromType(Main.getExprType(e), compilingInHeader);

			// Get name
			var name = Main.compileVarName(nameMeta.getNameOrNativeName());

			// If the field is covariant, but returning the child variant type,
			// call the class-specific implementation.
			switch(fa) {
				case FInstance(_.get() => cls, _, _.get() => cf) if(cf.isMethodKind()): { // Make sure is FMethod before calling "findFuncData".
					final fdata = cf.findFuncData(cls);
					if(fdata != null) {
						final baseCovariant = ClassHierarchyTracker.funcGetCovariantBaseType(cls, cf, false);
						if(baseCovariant != null) {
							if(targetType == null || fdata.ret.equals(targetType)) {
								name += "OG";
							}
						}
					}
				}
				case _:
			}

			// Check if this is a static variable,
			// and if so use singleton.
			final result = switch(fa) {
				case FStatic(clsRef, cfRef): {
					onModuleTypeEncountered(TClassDecl(clsRef), accessExpr.pos);

					final cf = cfRef.get();
					if(cf.hasMeta(Meta.TopLevel)) {
						name;
					} else {
						final className = TComp.compileClassName(clsRef, e.pos, null, true, true);
						className + "::" + name;
					}
				}
				case FEnum(enumRef, enumField): {
					onModuleTypeEncountered(TEnumDecl(enumRef), accessExpr.pos);

					final enumName = TComp.compileEnumName(enumRef, e.pos, null, true, true);
					final potentialArgs = enumField.type.getTFunArgs();

					// If there are no arguments, Haxe treats the enum case as
					// a static variable, rather than a function. However, all enum
					// cases in C++ are functions.
					//
					// Therefore, if there are no arguments, lets go ahead and
					// add a call operator to the end so the C++ function version
					// is properly called.
					//
					// HOWEVER, if the enum is a `@:cppEnum`, it should not have
					// a call operator.
					final end = if(enumRef.get().hasMeta(Meta.CppEnum)) {
						"";
					} else {
						potentialArgs != null && potentialArgs.length > 0 ? "" : "()";
					}
					enumName + "::" + name + end;
				}
				case _: {
					final eType = Main.getExprType(e);
					var useArrow = isThisExpr(e) || isArrowAccessType(eType);

					final nullType = eType.unwrapNullType();
					final cppExpr = if(nullType != null) {
						compileExpressionForType(e, nullType).trustMe();
					} else {
						Main.compileExpressionOrError(e);
					}

					// We need to include the "left type" to access its fields in C++.
					IComp.addIncludeFromType(eType, compilingInHeader);

					var accessOp = switch(e.expr) {
						case TConst(TSuper): "::";
						case _: (useArrow ? "->" : ".");
					}

					cppExpr + accessOp + name;
				}
			}

			// @:nativeVariableCode
			final nvc = Main.compileNativeVariableCodeMeta(accessExpr, result);
			final output = if(nvc != null) {
				nvc;
			} else {
				result;
			}

			if(thisFieldsAssigned != null && isThisExpr(e) && !thisFieldsAssigned.contains(name)) {
				thisFieldsAssigned.push(name);
			}

			return output;
		}
	}

	function moduleNameToCpp(m: ModuleType, pos: Position): String {
		IComp.addIncludeFromMetaAccess(m.getCommonData().meta, compilingInHeader);
		return TComp.compileType(TypeHelper.fromModuleType(m), pos, true);
	}

	function checkNativeCodeMeta(callExpr: TypedExpr, el: Array<TypedExpr>, typeParams: Null<Array<Type>> = null): Null<String> {
		final typeParamCallback = if(typeParams != null) {
			function(index: Int) {
				return if(index >= 0 && index < typeParams.length) {
					final t = typeParams[index];
					Main.onTypeEncountered(t, compilingInHeader, callExpr.pos);
					TComp.compileType(t, callExpr.pos);
				} else {
					null;
				}
			}
		} else {
			null;
		}
		return Main.compileNativeFunctionCodeMeta(callExpr, el, typeParamCallback);
	}

	function compileCall(callExpr: TypedExpr, el: Array<TypedExpr>, originalExpr: TypedExpr) {
		#if !cxx_inline_trace_disabled
		final inlineTrace = checkForInlinableTrace(callExpr, el);
		if(inlineTrace != null) return inlineTrace;
		#end

		final originalExprType = Main.getExprType(originalExpr);
		final nfc = checkNativeCodeMeta(callExpr, el, callExpr.getFunctionTypeParams(originalExprType));
		return if(nfc != null) {
			// Ensure we use potential #include
			final declaration = callExpr.getDeclarationMeta();
			if(declaration != null) {
				IComp.addIncludeFromMetaAccess(declaration.meta, compilingInHeader);
			}

			nfc;
		} else {
			// If this is a `@:constructor` call, compile as a "TNew".
			switch(callExpr.getFieldAccess(true)) {
				case FStatic(classTypeRef, cfRef) if(cfRef.get().hasMeta(Meta.Constructor)): {
					onModuleTypeEncountered(TClassDecl(classTypeRef), originalExpr.pos);
					return compileNew(originalExpr, TInst(classTypeRef, []), el);
				}
				case _:
			}

			var isOverload = false;

			switch(callExpr.expr) {
				case TField(_, fa): {
					// isOverload
					switch(fa) {
						case FInstance(_, _, cfRef): {
							isOverload = cfRef.get().overloads.get().length > 0;
						}
						case _:
					}

					// replace null pads with defaults
					switch(fa) {
						case FInstance(clsRef, _, _.get() => cf) | FStatic(clsRef, _.get() => cf) if(cf.isMethodKind()): {
							final funcData = cf.findFuncData(clsRef.get());
							if(funcData != null) {
								el = funcData.replacePadNullsWithDefaults(el, ":noNullPad", Main.generateInjectionExpression);
							}
						}
						case _:
					}
				}
				case _:
			}

			// Get list of function argument types
			var funcArgTypes = switch(Main.getExprType(callExpr)) {
				case TFun(args, _): {
					[for(i in 0...args.length) {
						var t = args[i].t;

						// If an expression is `null` for a conflicting default value,
						// we need to make sure its argument is typed as nullable.
						if(i < el.length) {
							if(!t.isNull()) {
								final e = el[i];
								if(e.hasMeta("-conflicting-default-value")) {
									t = t.wrapWithNull();
								}
							}
						}

						t;
					}];
				}
				case _: null;
			}

			// If this is an overloaded call, ensure `null` is explicit for argument expressions.
			final old = setExplicitNull(true, isOverload);

			// Get `ClassField`
			final cf = callExpr.getClassField();

			// Create array to store template arguments
			final templateArgs: Array<{ cpp: String, index: Int }> = [];

			// Extract tfunc to check the metadata for arguments
			final tfunc = if(cf != null) switch(cf.expr()?.expr) {
				case TFunction(tfunc): tfunc;
				case _: null;
			} else null;

			// Compile the arguments
			var cppArgs = [];
			for(i in 0...el.length) {
				final paramExpr = el[i];
				final cpp = if(funcArgTypes != null && i < funcArgTypes.length && funcArgTypes[i] != null) {
					compileExpressionForType(paramExpr, funcArgTypes[i]);
				} else {
					Main.compileExpressionOrError(paramExpr);
				}

				if(cpp == null) {
					paramExpr.pos.makeError(CouldNotCompileExpression(paramExpr));
					continue;
				}

				// Check if the argument has @:templateArg
				// If so, add to `templateArgs` instead of `cppArgs`.
				if(
					tfunc != null &&
					i < tfunc.args.length &&
					tfunc.args[i].v.meta.maybeHas(Meta.TemplateArg)
				) {
					templateArgs.push({
						cpp: cpp,
						index: -1
					});
					continue;
				}

				cppArgs.push(cpp);
			}

			// Revert "explictNull" state.
			setExplicitNull(old);

			// Handle type parameters if necessary
			final cppTemplateArgs = [];
			if(cf != null && cf.params.length > 0) {
				final resolvedParams = Main.getExprType(callExpr).findResolvedTypeParams(cf);
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
						for(p in compiledParams) cppTemplateArgs.push(p);
					}
				}
			}

			// Add normal arguments with @:templateArg to compiled template arguments
			for(a in templateArgs) {
				if(a.index != -1 && a.index < cppTemplateArgs.length) {
					cppTemplateArgs[a.index] = a.cpp;
				} else {
					cppTemplateArgs.push(a.cpp);
				}
			}

			// Generate template arguments for call
			final typeParamCpp = cppTemplateArgs.length > 0 ? '<${cppTemplateArgs.join(", ")}>' : "";

			// Compile final expression
			Main.compileExpressionOrError(callExpr) + typeParamCpp + "(" + cppArgs.join(", ") + ")";
		}
	}

	/**
		Note: `expr` is NOT guarenteed to be a `TNew`.
		It could be a static call to a function with a `@:constructor` metadata.
	**/
	function compileNew(expr: TypedExpr, type: Type, el: Array<TypedExpr>, overrideMMT: Null<MemoryManagementType> = null): String {
		Main.onTypeEncountered(type, compilingInHeader, expr.pos);

		final nfc = checkNativeCodeMeta(expr, el, type.getParams());
		if(nfc != null) {
			return nfc;
		}

		// Since we are constructing an object, it will never be null.
		// Therefore, we must remove any Null<T> from the type.
		type = type.unwrapNullTypeOrSelf();
		final meta = switch(type) {
			// Used for TObjectDecl of named anonymous struct.
			// See "XComp.compileNew" in Anon.compileObjectDecl to understand.
			case TType(typeDefRef, params): {
				typeDefRef.get().meta;
			}
			case _: {
				expr.getDeclarationMeta()?.meta;
			}
		}
		final native = { name: "", meta: meta }.getNameOrNative();
		
		// Replace `null`s with default values
		switch(type) {
			case TInst(clsRef, params): {
				final cls = clsRef.get();
				if(cls.constructor != null) {
					final cf = cls.constructor.get();
					final funcData = cf.findFuncData(cls);
					if(funcData != null) {
						el = funcData.replacePadNullsWithDefaults(el);
					}
				}
			}
			case _:
		}

		// Find argument types (if possible)
		var funcArgs = switch(type) {
			case TInst(clsRef, params): {
				final cls = clsRef.get();
				final c = cls.constructor;
				if(c != null) {
					final clsField = c.get();
					switch(clsField.type) {
						case TFun(args, ret): {
							#if macro args.map(a -> haxe.macro.TypeTools.applyTypeParameters(a.t, cls.params, params)) #else null #end;
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
		return if(native.length > 0) {
			native + "(" + args + ")";
		} else {
			final params = {
				type.getParams() ?? [];
			};
			final typeParams = params.map(p -> TComp.compileType(p, expr.pos)).join(", ");
			final cd = type.toModuleType().trustMe().getCommonData();

			// If the expression's type is different, this may be the result of an unsafe cast.
			// If so, let's use the memory management type from the cast.
			if(overrideMMT == null) {
				final exprMMT = Types.getMemoryManagementTypeFromType(Main.getExprType(expr));
				if(exprMMT != cd.getMemoryManagementType()) {
					overrideMMT = exprMMT;
				}
			}

			compileClassConstruction(type, cd, params ?? [], expr.pos, overrideMMT) + "(" + args + ")";
		}
	}

	function compileClassConstruction(type: Type, cd: BaseType, params: Array<Type>, pos: Position, overrideMMT: Null<MemoryManagementType> = null): String {
		var mmt = cd.getMemoryManagementType();
		var typeSource = if(cd.metaIsOverrideMemoryManagement()) {
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

		// We cannot compile value-type constructors in header if using forward declare
		if(compilingInHeader && mmt == Value) {
			final canUseInheader = Main.getCurrentDep()?.canUseInHeader(typeSource, false) ?? true;
			if(!canUseInheader) {
				Main.getCurrentDep()?.cannotConstructValueTypeError(typeSource, pos);
			}
		}

		IComp.includeMMType(mmt, compilingInHeader);

		final typeOutput = TComp.compileType(typeSource, pos, true);
		return switch(mmt) {
			case Value: typeOutput;
			case UnsafePtr: "new " + typeOutput;
			case SharedPtr: Compiler.SharedPtrMakeCpp + "<" + typeOutput + ">";
			case UniquePtr: Compiler.UniquePtrMakeCpp + "<" + typeOutput + ">";
		}
	}

	// Compiles if statement (TIf).
	function compileIf(econd: TypedExpr, ifExpr: TypedExpr, elseExpr: Null<TypedExpr>, constexpr: Bool = false): String {
		final nullableBoolT = TAbstract(Main.getNullType(), [Context.getType("Bool")]);
		var result = "if" + (constexpr ? " constexpr" : "") + "(" + XComp.compileExpressionForType(econd.unwrapParenthesis(), nullableBoolT) + ") {\n";
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

	function compileSwitch(e: TypedExpr, cases: Array<{ values:Array<TypedExpr>, expr:TypedExpr }>, edef: Null<TypedExpr>) {
		var result = "";
		final eType = Main.getExprType(e);
		final cpp = Main.compileExpressionOrError(e.unwrapParenthesis());

		// If switching on `@:cppEnum` enum, obtain relevant data.
		final cppEnumData = switch(e.unwrapParenthesis().expr) {
			case TEnumIndex(enumIndexExpr): {
				switch(Main.getExprType(enumIndexExpr)) {
					case TEnum(enumRef, _) if(enumRef.get().hasMeta(Meta.CppEnum)): {
						IComp.addIncludeFromModuleType(TEnumDecl(enumRef), compilingInHeader);
						{
							e: enumRef,
							prefix: TComp.compileType(TEnum(enumRef, []), e.pos, true) + "::"
						};
					}
					case _: null;
				}
			}
			case _: null;
		}

		if(eType.isCppNumberType()) {
			result = compileSwitchAsSwitch(cpp, cases, edef, cppEnumData);
		} else if(isStringLiteralSwitch(eType, cases)) {
			result = compileSwitchOptimizedForStrings(cpp, eType, cases, edef);
		} else {
			result = compileSwitchAsIfs(cpp, eType, cases, edef);
		}

		return result;
	}

	function isStringLiteralSwitch(type: Type, cases: Array<{ values:Array<TypedExpr>, expr:TypedExpr }>) {
		if(!type.isString()) {
			return false;
		}
		final stringLiteralCases = cases.filter(function(c) {
			return if(c.values.length == 1) {
				switch(c.values[0].expr) {
					case TConst(TString(_)): true;
					case _: false;
				}
			} else {
				false;
			}
		});
		return stringLiteralCases.length == cases.length;
	}

	function compileDefaultCase(edef: Null<TypedExpr>): String {
		if(edef != null) {
			var result = "\n";
			result += "\tdefault: {\n";
			result += toIndentedScope(edef).tab();
			result += "\n\t\tbreak;";
			result += "\n\t}";
			return result;
		} else {
			return "\n\tdefault: {}";
		}
	}

	/**
		Compiles a switch statement as a C++ switch statement.
		All the cases should be numerical values.

		If `cppEnum` is defined, the cases will try and be compiled
		using the enum value identifiers.
	**/
	function compileSwitchAsSwitch(cpp: String, cases: Array<{ values:Array<TypedExpr>, expr:TypedExpr }>, edef: Null<TypedExpr>, cppEnum: Null<{ e: Ref<EnumType>, prefix: String }>) {
		var result = "switch(" + cpp + ") {";
		for(c in cases) {
			final compiledValues = c.values.map(function(v) {
				if(cppEnum != null) {
					final names = cppEnum.e.get().names;
					final index = switch(v.expr) {
						case TConst(TInt(v)) if(v < names.length): {
							return cppEnum.prefix + names[v];
						}
						case _: null;
					}
				}
				return Main.compileExpressionOrError(v);
			});
			for(cpp in compiledValues) {
				result += "\n\tcase " + cpp + ":";
			}
			result += " {\n";
			result += toIndentedScope(c.expr).tab();
			result += "\n\t\tbreak;";
			result += "\n\t}";
		}
		result += compileDefaultCase(edef);
		result += "\n}";
		return result;
	}

	/**
		Generates the code to find the length of a `String`.

		This can change depending on whether `String` is supposed to be
		`const char*`, `std::string`, or some user-shadowed type.

		By default, if the `String` type is shadowed, this function
		will assume its `length` field has a `@:nativeName` with the
		correct C++ code.
	**/
	function generateCppForStringLength(lexprCpp: String): String {
		#if cxx_disable_haxe_std
		IComp.addInclude("cstring", compilingInHeader, true);
		return 'strlen($lexprCpp)';
		#else
		var fieldCpp = "size()";
		switch(TComp.getStringTypeOverride()) {
			case TInst(clsRef, _): {
				final c = clsRef.get();
				for(f in c.fields.get()) {
					if(f.name == "length") {
						final content = f.meta.extractStringFromFirstMeta(":nativeName");
						if(content != null) {
							fieldCpp = content;
						}
					}
				}
			}
			case _:
		}
		return '$lexprCpp.$fieldCpp';
		#end
	}

	function compileSwitchOptimizedForStrings(cpp: String, eType: Type, cases: Array<{ values:Array<TypedExpr>, expr:TypedExpr }>, edef: Null<TypedExpr>) {
		final lengths: Map<Int, Array<{ values:Array<TypedExpr>, expr:TypedExpr }>> = [];
		for(c in cases) {
			final str = switch(c.values[0].expr) {
				case TConst(TString(s)): s;
				case _: throw "Impossible";
			}
			
			if(!lengths.exists(str.length)) {
				lengths.set(str.length, []);
			}
			lengths.get(str.length)?.push(c);
		}

		var result = "auto __temp = " + cpp + ";\n";
		result += "switch(" + generateCppForStringLength("__temp") + ") {";
		for(length => lengthCases in lengths) {
			result += "\n\tcase " + length + ": {\n";
			result += compileSwitchAsIfs("__temp", eType, lengthCases, null, false).tab(2);
			result += "\n\t\tbreak;";
			result += "\n\t}";
		}
		result += compileDefaultCase(edef);
		result += "\n}";
		return result;
	}

	function compileSwitchAsIfs(cpp: String, eType: Type, cases: Array<{values:Array<TypedExpr>, expr:TypedExpr}>, edef: Null<TypedExpr>, initTemp: Bool = true) {
		var result = initTemp ? "auto __temp = " + cpp + ";\n" : "";
		for(i in 0...cases.length) {
			final c = cases[i];
			final isFirst = i == 0;
			final compCpp = c.values.map(function(v) {
				return binopToCpp(OpEq, { expr: TIdent("__temp"), pos: v.pos, t: eType }, v, v.pos);
			});
			result += (isFirst ? "" : " else ") + "if(" + compCpp.join(" && ") + ") {\n";
			result += toIndentedScope(c.expr);
			result += "\n}";
		}
		if(edef != null) {
			result += " else {\n";
			result += toIndentedScope(edef);
			result += "\n}";
		}
		return result;
	}

	function compileCast(castedExpr: TypedExpr, originalExpr: TypedExpr, maybeModuleType: Null<ModuleType>): Null<String> {
		var result = null;

		// If casting from Null<T> to <T>
		if(maybeModuleType == null && Main.getExprType(castedExpr, false).isNullOfType(Main.getExprType(originalExpr, false))) {
			result = compileExpressionNotNull(castedExpr);
		} else {
			// Find cast type
			var isAnyCast = false;
			if(maybeModuleType != null) {
				switch(Main.getExprType(castedExpr)) {
					case TAbstract(aRef, []) if(aRef.get().name == "Any" && aRef.get().module == "Any"):
						isAnyCast = true;
					case _:
				}
			}

			// Generate cast code
			final allowNullable = !isAnyCast;
			result = allowNullable ? Main.compileExpression(castedExpr) : compileExpressionNotNull(castedExpr);
			if(result != null) {
				if(maybeModuleType != null) {
					final mCpp = moduleNameToCpp(maybeModuleType, originalExpr.pos);
					if(isAnyCast) {
						// If casting from Any
						IComp.addInclude("any", compilingInHeader, true);
						result = "std::any_cast<" + mCpp + ">(" + result + ")";
					} else {
						// C-style case
						result = "((" + mCpp + ")(" + result + "))";
					}
				}
			}
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
			result = Main.compileExpressionOrError(internalExpr);
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
					case TVar(tvar, maybeExpr): compileLocalVariable(tvar, maybeExpr, internalExpr, true);
					case _: metaEntry.pos.makeError(ConstExprMetaInvalidUse);
				}
			}
			case ":cstr": {
				switch(internalExpr.expr) {
					case TConst(TString(s)): stringToLiteralCpp(s);
					case _: metaEntry.pos.makeError(InvalidCStr);
				}
			}
			case ":alloc": {
				switch(internalExpr.expr) {
					case TNew(classTypeRef, params, el): compileNew(internalExpr, TInst(classTypeRef, params), el, UnsafePtr);
					case _: metaEntry.pos.makeError(InvalidAlloc);
				}
			}
			case ":passConstTypeParam" /* Meta.PassConstTypeParam */: {
				switch(internalExpr.expr) {
					case TVar(tvar, _): {
						MetaHelper.applyPassConstTypeParam(Main.getTVarType(tvar), [metaEntry], metaEntry.pos);
						null;
					}
					case _: metaEntry.pos.makeError(InvalidPassConstTypeParam);
				}
			}
			case ":include": {
				switch(metaEntry.params) {
					case [{ expr: EConst(CString(s)) }]: {
						IComp.addInclude(s, compilingInHeader, false);
					}
					case [{ expr: EConst(CString(s)) }, { expr: EConst(CIdent(_ == "true" => b)) }]: {
						IComp.addInclude(s, compilingInHeader, b);
					}
					case _:
				}
				null;
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

	//functionName + "." + localFuncName
	public function generateStackTrackCode(bt: Null<BaseType>, funcName: String, pos: Position): String {
		final moduleName = {
			if(Main.currentModule != null) {
				final baseType = Main.currentModule.getCommonData();
				(baseType.pack.length > 0 ? baseType.pack.join(".") + "." : "") + baseType.name;
			 } else {
				"<unknown>";
			 }
		}
		final params: Array<String> = [
			XComp.stringToCpp(pos.getFile()),
			Std.string(pos.line()),
			Std.string(pos.column()),
			XComp.stringToCpp(moduleName),
			XComp.stringToCpp(funcName)
		];
		return 'HCXX_STACK_METHOD(${params.join(", ")})';
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
						final line = #if macro haxe.macro.PositionTools.toLocation(callExpr.pos).range.start.line #else 0 #end;
						final file = Context.getPosInfos(callExpr.pos).file;
						final clsConstruct = {
							final clsName = TComp.compileType(e1InternalType, callExpr.pos, true);
							final tmmt = Types.getMemoryManagementTypeFromType(e1InternalType);
							#if cxx_smart_ptr_disabled
							if(tmmt == SharedPtr || tmmt == UniquePtr) {
								callExpr.pos.makeError(DisallowedSmartPointers);
							}
							#end
							AComp.applyAnonMMConversion(clsName, ["\"\"", stringToCpp(file), Std.string(line), "\"\""], tmmt);
						};
						piCpp + ".value_or(" + clsConstruct + ")";
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
