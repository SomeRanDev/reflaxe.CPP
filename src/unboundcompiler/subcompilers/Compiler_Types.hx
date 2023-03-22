// =======================================================
// * Compiler_Types
//
// This sub-compiler is used to handle compiling of all
// type related objects such as haxe.macro.Type and
// haxe.macro.ClassType/EnumType/DefType/etc.
// =======================================================

package unboundcompiler.subcompilers;

#if (macro || ucpp_runtime)

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using reflaxe.helpers.NameMetaHelper;
using reflaxe.helpers.SyntaxHelper;
using reflaxe.helpers.TypeHelper;

using unboundcompiler.helpers.UError;
using unboundcompiler.helpers.UMeta;
using unboundcompiler.helpers.UType;

@:allow(unboundcompiler.UnboundCompiler)
@:access(unboundcompiler.UnboundCompiler)
@:access(unboundcompiler.subcompilers.Compiler_Includes)
class Compiler_Types extends SubCompiler {
	// ----------------------------
	// Compiles the provided type.
	// Position must be provided for error reporting.
	public function compileType(t: Null<Type>, pos: Position, asValue: Bool = false): String {
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
	public function maybeCompileType(t: Null<Type>, pos: Position, asValue: Bool = false): Null<String> {
		if(t == null) {
			return null;
		}

		// Check if this type is Class<T>.
		// (It can be either TAbstract or TType,
		// so faster to just check here).
		final clsParamMt = t.getClassParameter();
		if(clsParamMt != null) {
			return "haxe::_class<" + compileType(TypeHelper.fromModuleType(clsParamMt), pos, true) + ">";
		}

		return switch(t) {
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
				final internal = AComp.compileAnonType(anonRef);
				if(asValue) {
					internal;
				} else {
					UnboundCompiler.SharedPtrClassCpp + "<" + internal + ">";
				}
			}
			case TDynamic(t3): {
				if(t3 == null) {
					if(isAccumulatingDynamicToTemplate()) {
						final result = generateDynamicTemplateName();
						addDynamicTemplate(result);
						result;
					} else {
						pos.makeError(DynamicUnsupported);
					}
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
						case "Any": {
							IComp.addInclude("any", true, true);
							"std::any";
						}
						case _: null;
					}
				} else {
					null;
				}

				if(prim != null) {
					prim;
				} else {
					if(abs.isOverrideMemoryManagement() && params.length == 1) {
						return applyMemoryManagementWrapper(compileType(params[0], pos, true), abs.getMemoryManagementType());
					}

					if(abs.hasMeta(":native")) {
						return compileModuleTypeName(abs, pos, params, true, asValue ? Value : getMemoryManagementTypeFromType(abs.type));
					}

					switch(abs.name) {
						case "Null" if(params.length == 1): {
							IComp.addInclude(UnboundCompiler.OptionalInclude[0], true, UnboundCompiler.OptionalInclude[1]);
							UnboundCompiler.OptionalClassCpp + "<" + compileType(params[0], pos) + ">";
						}
						case _: {
							final inner = Main.getAbstractInner(t);
							final newType = haxe.macro.TypeTools.applyTypeParameters(inner, abs.params, params);

							if(t.equals(newType)) {
								compileModuleTypeName(abs, pos, params, true, asValue ? Value : null);
							} else {
								compileType(newType, pos);
							}
						}
					}
				}
			}
			case TType(defRef, params): {
				if(t.isRef()) {
					compileType(params[0], pos) + "&";
				} else {
					compileDefName(defRef.get(), pos, params, true, asValue);
				}
			}
		}
	}

	// ----------------------------
	// Compile internal field of all ModuleTypes.
	function compileModuleTypeName(typeData: { > NameAndMeta, pack: Array<String> }, pos: Position, params: Null<Array<Type>> = null, useNamespaces: Bool = true, overrideMM: Null<MemoryManagementType> = null): String {
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
			final mmType = overrideMM != null ? overrideMM : typeData.getMemoryManagementType();
			applyMemoryManagementWrapper(innerClass, mmType);
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
	public function compileClassName(classType: ClassType, pos: Position, params: Null<Array<Type>> = null, useNamespaces: Bool = true, asValue: Bool = false): String {
		switch(classType.kind) {
			case KTypeParameter(_): {
				final result = classType.name;
				addDynamicTemplate(result);
				return result;
			}
			case _: {}
		}
		return compileModuleTypeName(classType, pos, params, useNamespaces, asValue ? Value : null);
	}

	// ----------------------------
	// Compile EnumType.
	public function compileEnumName(enumType: EnumType, pos: Position, params: Null<Array<Type>> = null, useNamespaces: Bool = true, asValue: Bool = false): String {
		return compileModuleTypeName(enumType, pos, params, useNamespaces, asValue ? Value : null);
	}

	// ----------------------------
	// Compile DefType.
	public function compileDefName(defType: DefType, pos: Position, params: Null<Array<Type>> = null, useNamespaces: Bool = true, asValue: Bool = false): String {
		return compileModuleTypeName(defType, pos, params, useNamespaces, asValue ? Value : null);
	}

	// ----------------------------
	// Wrap compiled type based on the
	// provided memory management type.
	function applyMemoryManagementWrapper(inner: String, mmType: MemoryManagementType): String {
		return switch(mmType) {
			case Value: inner;
			case UnsafePtr: inner + "*";
			case UniquePtr: UnboundCompiler.UniquePtrClassCpp + "<" + inner + ">";
			case SharedPtr: UnboundCompiler.SharedPtrClassCpp + "<" + inner + ">";
		}
	}

	// ----------------------------
	// Returns the memory manage type
	// based on the meta of the Type.
	function getMemoryManagementTypeFromType(t: Type): MemoryManagementType {
		if(t.isClass()) {
			return Value;
		}

		final mmt = switch(t) {
			case TAbstract(absRef, params) if(params.length == 1 && absRef.get().name == "Null"): {
				getMemoryManagementTypeFromType(params[0]);
			}
			case TAbstract(absRef, params) if(!absRef.get().isOverrideMemoryManagement()): {
				final abs = absRef.get();
				final result = if(params.length == 0) {
					switch(abs.name) {
						case "Void": Value;
						case "Int": Value;
						case "Float": Value;
						case "Single": Value;
						case "Bool": Value;
						case "Any": Value;
						case _: null;
					}
				} else {
					null;
				}

				if(result != null) {
					result;
				} else {
					final inner = Main.getAbstractInner(t);
					getMemoryManagementTypeFromType(inner);
				}
			}
			case TType(defRef, params) if(t.isRef()): {
				getMemoryManagementTypeFromType(params[0]);
			}
			case TType(defRef, params): {
				getMemoryManagementTypeFromType(Main.getTypedefInner(t));
			}
			case TAnonymous(a): {
				SharedPtr;
			}
			case TDynamic(t): {
				if(t == null) {
					Value;
				} else {
					getMemoryManagementTypeFromType(t);
				}
			}
			case _: null;
		}
		return if(mmt != null) {
			mmt;
		} else {
			{ name: "", meta: t.getMeta() }.getMemoryManagementType();
		}
	}

	// ----------------------------
	// Fields used for system for converting
	// Dynamic types into generic types.
	var templateState: Array<{ existingTemplates: Array<String>, dynamicTemplates: Array<String> }> = [];

	function isAccumulatingDynamicToTemplate(): Bool {
		return templateState.length > 0;
	}

	// ----------------------------
	// Once called, Dynamic types will be compiled
	// with new type names to be used in a template.
	function enableDynamicToTemplate(existingTemplates: Array<String>) {
		templateState.push({
			existingTemplates: existingTemplates,
			dynamicTemplates: []
		});
	}

	// ----------------------------
	// Adds a dynamic template if it doesn't already exist.
	public function addDynamicTemplate(t: String) {
		if(templateState.length > 0) {
			final state = templateState[templateState.length - 1];
			final d = state.dynamicTemplates;
			if(!state.existingTemplates.contains(t) && !d.contains(t)) {
				d.push(t);
			}
		}
	}

	// ----------------------------
	// Disables this feature and returns a list
	// of all the new "template type names" created.
	function disableDynamicToTemplate(): Array<String> {
		return if(templateState.length > 0) {
			templateState.pop().dynamicTemplates;
		} else {
			[];
		}
	}

	// ----------------------------
	// Generate name for type parameter from Dynamic.
	function generateDynamicTemplateName(): String {
		return if(templateState.length > 0) {
			final state = templateState[templateState.length - 1];
			"Dyn" + (state.dynamicTemplates.length + 1);
		} else {
			"DynNone";
		}
	}
}

#end
