// =======================================================
// * GCFCompiler_Types
//
// This sub-compiler is used to handle compiling of all
// type related objects such as haxe.macro.Type and
// haxe.macro.ClassType/EnumType/DefType/etc.
// =======================================================

package gcfcompiler.subcompilers;

#if (macro || gcf_runtime)

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using reflaxe.helpers.NameMetaHelper;
using reflaxe.helpers.SyntaxHelper;

using gcfcompiler.helpers.GCFError;
using gcfcompiler.helpers.GCFMeta;

@:allow(gcfcompiler.GCFCompiler)
@:access(gcfcompiler.GCFCompiler)
@:access(gcfcompiler.subcompilers.GCFCompiler_Includes)
class GCFCompiler_Types extends GCFSubCompiler {
	// ----------------------------
	// Compiles the provided type.
	// Position must be provided for error reporting.
	function compileType(t: Null<Type>, pos: Position, asValue: Bool = false): String {
		if(t == null) {
			pos.makeError(CannotCompileNullType);
		}
		final result = maybeCompileType(t, pos, asValue);
		if(result == null) {
			Context.error("Could not compile type: " + t, pos);
		}
		return result;
	}

	// ----------------------------
	// The function that actually compiles Types.
	// Does not cause error if Type compiles to null.
	// Can be safely passed null.
	function maybeCompileType(t: Null<Type>, pos: Position, asValue: Bool = false): Null<String> {
		return switch(t) {
			case null: {
				null;
			}
			case TMono(t3): {
				if(t3.get() != null) {
					compileType(t3.get(), pos, asValue);
				} else {
					null;
				}
			}
			case TEnum(enumRef, params): {
				compileEnumName(enumRef.get(), pos, params, true, asValue);
			}
			case TInst(clsRef, params): {
				compileClassName(clsRef.get(), pos, params, true, asValue);
			}
			case TFun(args, ret): {
				"std::function<" + compileType(ret, pos) + "(" + args.map(a -> compileType(a.t, pos)).join(", ") + ")>";
			}
			case TAnonymous(anonRef): {
				"struct {\n" + anonRef.get().fields.map(f -> (compileType(f.type, pos) + " " + Main.compileVarName(f.name) + ";").tab()).join("\n") + "\n}";
			}
			case TDynamic(t3): {
				if(t3 == null) {
					pos.makeError(DynamicUnsupported);
				} else {
					compileType(t3, pos, asValue);
				}
			}
			case TLazy(f): {
				compileType(f(), pos, asValue);
			}
			case TAbstract(absRef, params): {
				final abs = absRef.get();
				final prim = if(params.length == 0) {
					switch(abs.name) {
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
					if(abs.isOverrideMemoryManagement() && params.length == 1) {
						return applyMemoryManagementWrapper(compileType(params[0], pos), abs.getMemoryManagementType());
					}

					switch(abs.name) {
						case "Null" if(params.length == 1): {
							IComp.addInclude("optional", true, true);
							"std::optional<" + compileType(params[0], pos) + ">";
						}
						case _: {
							final t = haxe.macro.TypeTools.applyTypeParameters(abs.type, abs.params, params);
							compileType(t, pos);
						}
					}
				}
			}
			case TType(defRef, params): {
				compileDefName(defRef.get(), pos, params, true, asValue);
			}
		}
	}

	// ----------------------------
	// Compile internal field of all ModuleTypes.
	function compileModuleTypeName(typeData: { > NameAndMeta, pack: Array<String> }, pos: Position, params: Null<Array<Type>> = null, useNamespaces: Bool = true, asValue: Bool = false): String {
		return if(typeData.hasNativeMeta()) {
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
			final mmType = typeData.getMemoryManagementType();
			applyMemoryManagementWrapper(innerClass, asValue ? Value : mmType);
		}
	}

	// ----------------------------
	// Compiles type params.
	function compileTypeNameWithParams(name: String, pos: Position, params: Null<Array<Type>> = null): Null<String> {
		if(params == null || params.length == 0) {
			return name;
		}
		return name + "<" + params.map(p -> compileType(p, pos)).join(", ") + ">";
	}

	// ----------------------------
	// Compile ClassType.
	function compileClassName(classType: ClassType, pos: Position, params: Null<Array<Type>> = null, useNamespaces: Bool = true, asValue: Bool = false): String {
		return compileModuleTypeName(classType, pos, params, useNamespaces, asValue);
	}

	// ----------------------------
	// Compile EnumType.
	function compileEnumName(enumType: EnumType, pos: Position, params: Null<Array<Type>> = null, useNamespaces: Bool = true, asValue: Bool = false): String {
		return compileModuleTypeName(enumType, pos, params, useNamespaces, asValue);
	}

	// ----------------------------
	// Compile DefType.
	function compileDefName(defType: DefType, pos: Position, params: Null<Array<Type>> = null, useNamespaces: Bool = true, asValue: Bool = false): String {
		return compileModuleTypeName(defType, pos, params, useNamespaces, asValue);
	}

	// ----------------------------
	// Wrap compiled type based on the
	// provided memory management type.
	function applyMemoryManagementWrapper(inner: String, mmType: MemoryManagementType): String {
		return switch(mmType) {
			case Value: inner;
			case UnsafePtr: inner + "*";
			case UniquePtr: "std::unique_ptr<" + inner + ">";
			case SharedPtr: "std::shared_ptr<" + inner + ">";
		}
	}
}

#end
