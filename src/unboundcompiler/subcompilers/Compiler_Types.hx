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
				final internal = AComp.compileAnonType(anonRef);
				if(asValue) {
					internal;
				} else {
					UnboundCompiler.SharedPtrClassCpp + "<" + internal + ">";
				}
			}
			case TDynamic(t3): {
				if(t3 == null) {
					if(accumulateTemplateTypes) {
						final result = "Dyn" + (dynamicTemplates.length + 1);
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

					switch(abs.name) {
						case "Null" if(params.length == 1): {
							IComp.addInclude(UnboundCompiler.OptionalInclude[0], true, UnboundCompiler.OptionalInclude[1]);
							UnboundCompiler.OptionalClassCpp + "<" + compileType(params[0], pos) + ">";
						}
						case _: {
							final t = haxe.macro.TypeTools.applyTypeParameters(abs.type, abs.params, params);
							compileType(t, pos);
						}
					}
				}
			}
			case TType(defRef, params): {
				final def = defRef.get();
				final name = def.name;
				final module = def.module;

				if(name == "Class<" + module + ">") {
					"haxe::_class<" + module + ">";
				} else if(t.isRef()) {
					compileType(params[0], pos) + "&";
				} else {
					compileDefName(def, pos, params, true, asValue);
				}
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
		switch(classType.kind) {
			case KTypeParameter(_): {
				final result = classType.name;
				addDynamicTemplate(result);
				return result;
			}
			case _: {}
		}
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
			case UniquePtr: UnboundCompiler.UniquePtrClassCpp + "<" + inner + ">";
			case SharedPtr: UnboundCompiler.SharedPtrClassCpp + "<" + inner + ">";
		}
	}

	// ----------------------------
	// Returns the memory manage type
	// based on the meta of the Type.
	function getMemoryManagementTypeFromType(t: Type): MemoryManagementType {
		final mmt = switch(t) {
			case TAbstract(absRef, params) if(params.length == 0): {
				final abs = absRef.get();
				switch(abs.name) {
					case "Void": Value;
					case "Int": Value;
					case "Float": Value;
					case "Single": Value;
					case "Bool": Value;
					case "Any": Value;
					case "Class": Value;
					case _: null;
				}
			}
			case TAbstract(absRef, params) if(params.length == 1 && absRef.get().name == "Null"): {
				getMemoryManagementTypeFromType(params[0]);
			}
			case TType(defRef, params) if(t.isRef()): {
				getMemoryManagementTypeFromType(params[0]);
			}
			case TType(defRef, params) if(params.length == 1): {
				final def = defRef.get();
				switch(def.name) {
					case "Class": Value;
					case _: null;
				}
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
	var accumulateTemplateTypes: Bool = false;
	var existingTemplates: Array<String> = [];
	var dynamicTemplates: Null<Array<String>> = null;

	// ----------------------------
	// Once called, Dynamic types will be compiled
	// with new type names to be used in a template.
	function enableDynamicToTemplate(existingTemplates: Array<String>) {
		this.existingTemplates = existingTemplates;
		if(!accumulateTemplateTypes) {
			accumulateTemplateTypes = true;
			dynamicTemplates = [];
		}
	}

	// ----------------------------
	// Adds a dynamic template if it doesn't already exist.
	function addDynamicTemplate(t: String) {
		if(!existingTemplates.contains(t) && !dynamicTemplates.contains(t)) {
			dynamicTemplates.push(t);
		}
	}

	// ----------------------------
	// Disables this feature and returns a list
	// of all the new "template type names" created.
	function disableDynamicToTemplate(): Array<String> {
		return if(accumulateTemplateTypes) {
			final result = dynamicTemplates;
			accumulateTemplateTypes = false;
			dynamicTemplates = [];
			result;
		} else {
			[];
		}
	}
}

#end
