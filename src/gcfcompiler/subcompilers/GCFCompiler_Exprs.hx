// =======================================================
// * GCFCompiler_Exprs
//
// This sub-compiler is used to handle compiling of all
// expressions.
// =======================================================

package gcfcompiler.subcompilers;

#if (macro || gcf_runtime)

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

using gcfcompiler.helpers.GCFError;
using gcfcompiler.helpers.GCFMeta;

@:allow(gcfcompiler.GCFCompiler)
@:access(gcfcompiler.GCFCompiler)
@:access(gcfcompiler.subcompilers.GCFCompiler_Includes)
@:access(gcfcompiler.subcompilers.GCFCompiler_Types)
class GCFCompiler_Exprs extends GCFSubCompiler {
	// ----------------------------
	// Compiles an expression into C++.
	public function compileExpression(expr: TypedExpr): Null<String> {
		var result = "";
		switch(expr.expr) {
			case TConst(constant): {
				result = constantToCpp(constant);
			}
			case TLocal(v): {
				IComp.addIncludeFromMetaAccess(v.meta);
				result = Main.compileVarName(v.name, expr);
			}
			case TIdent(s): {
				result = Main.compileVarName(s, expr);
			}
			case TArray(e1, e2): {
				result = compileExpression(e1) + "[" + compileExpression(e2) + "]";
			}
			case TBinop(op, e1, e2): {
				result = binopToCpp(op, e1, e2);
			}
			case TField(e, fa): {
				result = fieldAccessToCpp(e, fa);
			}
			case TTypeExpr(m): {
				result = moduleNameToCpp(m, expr.pos);
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
				final arrayType = expr.t.unwrapArrayType();
				result = "{" + el.map(e -> compileExpressionForType(e, arrayType)).join(", ") + "}";
			}
			case TCall(e, el): {
				final nfc = Main.compileNativeFunctionCodeMeta(e, el);
				result = if(nfc != null) {
					nfc;
				} else {
					compileExpression(e) + "(" + el.map(e -> compileExpression(e)).join(", ") + ")";
				}
			}
			case TNew(classTypeRef, params, el): {
				result = compileNew(expr, classTypeRef, params, el);
			}
			case TUnop(op, postFix, e): {
				result = unopToCpp(op, e, postFix);
			}
			case TFunction(tfunc): {
				result = "[=](" + tfunc.args.map(a -> Main.compileFunctionArgument(a, expr.pos)).join(", ") + ") {\n";
				result += toIndentedScope(tfunc.expr);
				result += "\n}";
			}
			case TVar(tvar, maybeExpr): {
				result = TComp.compileType(tvar.t, expr.pos) + " " + Main.compileVarName(tvar.name, expr);
				if(maybeExpr != null) {
					result += " = " + compileExpressionForType(maybeExpr, tvar.t);
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
					result += "\n} catch(" + TComp.compileType(c.v.t, expr.pos) + " " + c.v.name + ") {\n";
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
				result = "break";
			}
			case TContinue: {
				result = "continue";
			}
			case TThrow(expr): {
				result = "throw " + compileExpression(expr) + ";";
			}
			case TCast(e, maybeModuleType): {
				result = compileExpression(e);
				if(maybeModuleType != null) {
					result = "((" + moduleNameToCpp(maybeModuleType, expr.pos) + ")(" + result + "))";
				}
			}
			case TMeta(metadataEntry, expr): {
				result = compileExpression(expr);
			}
			case TEnumParameter(expr, enumField, index): {
				IComp.addIncludeFromMetaAccess(enumField.meta);
				result = compileExpression(expr);
				switch(enumField.type) {
					case TFun(args, _): {
						if(index < args.length) {
							result += (isArrowAccessType(expr.t) ? "->" : ".") + "data." + enumField.name + "." + args[index].name;
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

	function compileExpressionForType(expr: TypedExpr, targetType: Null<Type>): Null<String> {
		final cpp = compileExpression(expr);
		if(targetType != null) {

		}
		return cpp;
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

	// ----------------------------
	// Compile and indent the TypedExpr.
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

	function constantToCpp(constant: TConstant): String {
		switch(constant) {
			case TInt(i): return Std.string(i);
			case TFloat(s): return s;
			case TString(s): return "\"" + StringTools.replace(StringTools.replace(s, "\\", "\\\\"), "\"", "\\\"") + "\"";
			case TBool(b): return b ? "true" : "false";
			case TNull: return "std::nullopt";
			case TThis: return "this";
			case TSuper: return Main.superTypeName;
			case _: {}
		}
		return "";
	}

	function binopToCpp(op: Binop, e1: TypedExpr, e2: TypedExpr): String {
		var gdExpr1 = compileExpression(e1);
		var gdExpr2 = if(op.isAssign()) {
			compileExpressionForType(e2, e1.t);
		} else {
			compileExpression(e2);
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
		return strExpr.t.isString() && primExpr.t.isPrimitive();
	}

	function unopToCpp(op: Unop, e: TypedExpr, isPostfix: Bool): String {
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
		final mt = t.toModuleType();
		return if(mt != null) {
			final cd = mt.getCommonData();
			final mmt = cd.getMemoryManagementType();
			mmt != Value || cd.isArrowAccess();
		} else {
			false;
		}
	}

	function fieldAccessToCpp(e: TypedExpr, fa: FieldAccess): String {
		final nameMeta: NameAndMeta = switch(fa) {
			case FInstance(_, _, classFieldRef): classFieldRef.get();
			case FStatic(_, classFieldRef): classFieldRef.get();
			case FAnon(classFieldRef): classFieldRef.get();
			case FClosure(_, classFieldRef): classFieldRef.get();
			case FEnum(_, enumField): enumField;
			case FDynamic(s): { name: s, meta: null };
		}

		IComp.addIncludeFromMetaAccess(nameMeta.meta);

		return if(nameMeta.hasNativeMeta()) {
			nameMeta.getNameOrNative();
		} else {
			final name = Main.compileVarName(nameMeta.getNameOrNativeName());

			// Check if this is a static variable,
			// and if so use singleton.
			switch(fa) {
				case FStatic(clsRef, cfRef): {
					final cf = cfRef.get();
					final className = TComp.compileClassName(clsRef.get(), e.pos, null, true, true);
					return className + "::" + name;
				}
				case FEnum(enumRef, enumField): {
					final enumName = TComp.compileEnumName(enumRef.get(), e.pos, null, true, true);
					return enumName + "::" + name;
				}
				case _:
			}

			var useArrow = isThisExpr(e) || isArrowAccessType(e.t);

			final gdExpr = compileExpression(e);
			return gdExpr + (useArrow ? "->" : ".") + name;
		}
	}

	function moduleNameToCpp(m: ModuleType, pos: Position): String {
		IComp.addIncludeFromMetaAccess(m.getCommonData().meta);
		return TComp.compileModuleTypeName(m.getCommonData(), pos, null, true, true);
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

	function compileNew(expr: TypedExpr, clsRef: Ref<ClassType>, params: Array<Type>, el: Array<TypedExpr>): String {
		final nfc = Main.compileNativeFunctionCodeMeta(expr, el);
		return if(nfc != null) {
			nfc;
		} else {
			final meta = expr.getDeclarationMeta().meta;
			final native = { name: "", meta: meta }.getNameOrNative();
			final args = el.map(e -> compileExpression(e)).join(", ");
			if(native.length > 0) {
				native + "(" + args + ")";
			} else {
				final typeParams = params.map(p -> TComp.compileType(p, expr.pos)).join(", ");
				//final className = TComp.compileClassName(clsRef.get(), expr.pos);
				compileClassConstruction(clsRef, params, expr.pos) + "(" + args + ")";
			}
		}
	}

	function compileClassConstruction(clsRef: Ref<ClassType>, params: Array<Type>, pos: Position): String {
		final cls = clsRef.get();
		var typeSource = if(cls.isOverrideMemoryManagement()) {
			if(params.length != 1) {
				pos.makeError(OMMIncorrectParamCount);
			}
			params[0];
		} else {
			null;
		}

		if(typeSource == null) {
			typeSource = TInst(clsRef, params);
		}

		final typeOutput = TComp.compileType(typeSource, pos, true);
		return switch(cls.getMemoryManagementType()) {
			case Value: typeOutput;
			case UnsafePtr: "new " + typeOutput;
			case UniquePtr: "std::make_unique<" + typeOutput + ">";
			case SharedPtr: "std::make_shared<" + typeOutput + ">";
		}
	}
}

#end
