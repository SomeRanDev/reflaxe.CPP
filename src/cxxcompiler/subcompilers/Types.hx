// =======================================================
// * Types
//
// This sub-compiler is used to handle compiling of all
// type related objects such as haxe.macro.Type and
// haxe.macro.ClassType/EnumType/DefType/etc.
// =======================================================

package cxxcompiler.subcompilers;

#if (macro || cxx_runtime)

import reflaxe.helpers.Context; // Use like haxe.macro.Context
import haxe.macro.Expr;
import haxe.macro.Type;

import cxxcompiler.config.Meta;

using reflaxe.helpers.NameMetaHelper;
using reflaxe.helpers.NullableMetaAccessHelper;
using reflaxe.helpers.NullHelper;
using reflaxe.helpers.SyntaxHelper;
using reflaxe.helpers.TypeHelper;

using cxxcompiler.helpers.Error;
using cxxcompiler.helpers.MetaHelper;
using cxxcompiler.helpers.CppTypeHelper;

@:allow(cxxcompiler.Compiler)
@:access(cxxcompiler.Compiler)
@:access(cxxcompiler.subcompilers.Includes)
class Types extends SubCompiler {
	/**
		If defined, only type parameters with these names will be compiled.
		The rest are compiled as `Dynamic`. Used when compiling expressions
		for Dynamic wrappers to support functions with type parameters.
	**/
	var allowedTypeParamNames: Null<Array<String>> = null;

	/**
		See `allowedTypeParamNames`.
	**/
	public function setAllowedTypeParamNames(names: Array<String>) {
		allowedTypeParamNames = names;
	}

	/**
		Clears `allowedTypeParamNames`, enabling all type parameters.
	**/
	public function allowAllTypeParamNames() {
		allowedTypeParamNames = null;
	}

	// ----------------------------
	// Compiles the provided type.
	// Position must be provided for error reporting.
	public function compileType(t: Null<Type>, pos: Position, asValue: Bool = false, dependent: Bool = false): String {
		if(t == null) {
			pos.makeError(CannotCompileNullType);
		}
		final result = maybeCompileType(t, pos, asValue, dependent);
		if(result == null) {
			pos.makeError(CouldNotCompileType(t));
		}
		return result.trustMe();
	}

	// ----------------------------
	// This function applies typePreix() to maybeCompileTypeImpl()
	public function maybeCompileType(t: Null<Type>, pos: Position, asValue: Bool = false, dependent: Bool = false): Null<String> {
		final result = maybeCompileTypeImpl(t, pos, asValue, dependent);
		if(result != null) {
			return typePrefix(t) + result;
		}
		return result;
	}

	// ----------------------------
	// Compiles any content required prior to the C++ type.
	function typePrefix(t: Null<Type>): String {
		if(t != null) {
			final meta = t.getMeta();

			// @:typenamePrefixIfDependentScope
			if(meta.maybeHas(Meta.TypenamePrefixIfDependentScope)) {
				final params = t.getParams();
				if(params != null && params.filter(p -> p.isTypeParameter()).length > 0) {
					return "typename ";
				}
			}
		}

		return "";
	}

	// ----------------------------
	// The function that actually compiles Types.
	// Does not cause error if Type compiles to null.
	// Can be safely passed null.
	public function maybeCompileTypeImpl(t: Null<Type>, pos: Position, asValue: Bool = false, dependent: Bool = false): Null<String> {
		if(t == null) {
			return null;
		}

		// @:nativeTypeCode
		final ntc = compileNativeTypeCode(t, pos, asValue);
		if(ntc != null) {
			return ntc;
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
				compileEnumName(enumRef, pos, params, true, asValue, dependent);
			}
			#if (cxx_disable_haxe_std || display)
			case TInst(_.get() => { name: "String", module: "String" }, []): {
				return "const char*";
			}
			#end
			case TInst(clsRef, params): {
				switch(clsRef.get().kind) {
					case KExpr(e): {
						return haxe.macro.ExprTools.toString(e);
					}
					case _:
				}
				compileClassName(clsRef, pos, params, true, asValue, dependent);
			}
			case TFun(args, ret): {
				"std::function<" + compileType(ret, pos) + "(" + args.map(a -> compileType(a.t, pos)).join(", ") + ")>";
			}
			case TAnonymous(anonRef): {
				final internal = AComp.compileAnonType(anonRef);
				if(asValue) {
					internal;
				} else {
					#if cxx_smart_ptr_disabled
					internal;
					#else
					Compiler.SharedPtrClassCpp + "<" + internal + ">";
					#end
				}
			}
			case TDynamic(t3): {
				if(t3 == null) {
					#if (macro || display)
					if(!cxx.Compiler.dynamicTypeEnabled) {
						pos.makeError(DisallowedDynamic);
					} else
					#end
					if(isAccumulatingDynamicToTemplate()) {
						final result = generateDynamicTemplateName();
						addDynamicTemplate(result);
						result;
					} else {
						// pos.makeError(DynamicUnsupported);
						DComp.enableDynamic(pos);
						IComp.addTypeUtilHeader(true);
						IComp.addInclude("dynamic/Dynamic.h", true, true);
						DComp.compileDynamicTypeName();
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
					if(abs.hasMeta(":native") || abs.hasMeta(Meta.NativeName)) {
						final inner = Compiler.getAbstractInner(t);
						return compileModuleTypeName(abs, pos, params, true, asValue ? Value : getMemoryManagementTypeFromType(inner));
					}

					if(!asValue && abs.isOverrideMemoryManagement() && params.length == 1) {
						return applyMemoryManagementWrapper(compileType(params[0], pos, true, dependent), abs.getMemoryManagementType());
					}

					switch(abs.name) {
						case "Null" if(params.length == 1): {
							IComp.addInclude(Compiler.OptionalInclude[0], true, Compiler.OptionalInclude[1]);
							Compiler.OptionalClassCpp + "<" + compileType(params[0], pos) + ">";
						}
						case _: {
							final inner = Compiler.getAbstractInner(t);
							final newType = #if macro haxe.macro.TypeTools.applyTypeParameters(inner, abs.params, params) #else inner #end;

							if(t.equals(newType)) {
								compileModuleTypeName(abs, pos, params, true, asValue ? Value : null);
							} else {
								compileType(newType, pos, asValue, dependent);
							}
						}
					}
				}
			}
			case TType(defRef, params) if(t.isAnonStructOrNamedStruct()): {
				compileDefName(defRef, pos, params, true, asValue);
			}
			case TType(defRef, params) if(t.isMultitype()): {
				compileType(Context.follow(t), pos, asValue, dependent);
			}
			case TType(defRef, params): {
				if(t.isRefOrConstRef()) {
					(t.isConstRef() ? "const " : "") + compileType(params[0], pos) + "&";
				} else {
					compileDefName(defRef, pos, params, true, asValue);
				}
			}
		}
	}

	// ----------------------------
	// Compiles the type based on the @:nativeTypeCode meta
	// if it exists on the type's declaration.
	function compileNativeTypeCode(t: Null<Type>, pos: Position, asValue: Bool): Null<String> {
		if(t == null) return null;
		final meta = t.getMeta();
		return if(meta.maybeHas(Meta.NativeTypeCode)) {
			final params = t.getParams();
			final paramCallbacks = if(params != null && params.length > 0) {
				params.map(paramType -> function() {
					return compileType(paramType, pos);
				});
			} else {
				[];
			}

			final cpp = Main.compileNativeTypeCodeMeta(t, paramCallbacks);
			if(cpp != null) {
				final mmt = asValue ? Value : { name: "", meta: meta }.getMemoryManagementType();
				applyMemoryManagementWrapper(cpp, mmt);
			} else {
				null;
			}
		} else {
			null;
		}
	}

	// ----------------------------
	// Compile internal field of all ModuleTypes.
	function compileModuleTypeName(typeData: { > NameAndMeta, pack: Array<String> }, pos: Position, params: Null<Array<Type>> = null, useNamespaces: Bool = true, overrideMM: Null<MemoryManagementType> = null): String {
		if(typeData.hasMeta(Meta.NativeTypeCode)) {
			throw "@:nativeTypeCode detected on ModuleType being compiled on compileModuleTypeName.\nThis is a bug with Reflaxe/C++, please report!";
		}
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
			final useNS = useNamespaces && (!typeData.hasMeta(Meta.NoHaxeNamespaces));
			final prefix = (useNS ? typeData.pack.join("::") + (typeData.pack.length > 0 ? "::" : "") : "");
			final innerClass = compileTypeNameWithParams(prefix + typeData.getNameOrNativeName(), pos, params);
			final mmType = overrideMM ?? typeData.getMemoryManagementType();
			#if cxx_smart_ptr_disabled
			if(mmType == SharedPtr || mmType == UniquePtr) {
				pos.makeError(DisallowedSmartPointerTypeName(innerClass));
			}
			#end
			applyMemoryManagementWrapper(innerClass, mmType);
		}
	}

	// ----------------------------
	// Compiles type params.
	function compileTypeNameWithParams(name: String, pos: Position, params: Null<Array<Type>> = null): String {
		if(params == null || params.length == 0) {
			return name;
		}
		return name + "<" + params.map(p -> compileType(p, pos)).join(", ") + ">";
	}

	// ----------------------------
	// Compile ClassType.
	public function compileClassName(classType: Ref<ClassType>, pos: Position, params: Null<Array<Type>> = null, useNamespaces: Bool = true, asValue: Bool = false, dependent: Bool = false): String {
		final cls = classType.get();
		switch(cls.kind) {
			case KTypeParameter(_): {
				final result = cls.name;
				if(allowedTypeParamNames != null) {
					if(!allowedTypeParamNames.contains(result)) {
						return DComp.compileDynamicTypeName();
					}
				}
				addDynamicTemplate(result);
				return result;
			}
			case _: {}
		}

		function asType() return TInst(classType, params ?? []);

		var prefix = typePrefix(asType());

		// There are some instances where compileClassName is called outside
		// of "compileType", so we must check for @:nativeTypeCode again.
		if(classType.get().hasMeta(Meta.NativeTypeCode)) {
			final r = compileNativeTypeCode(asType(), pos, asValue);
			if(r != null) return prefix + r;
		}

		// if(dependent) {
		// 	final dep = Main.getCurrentDep();
		// 	if(dep != null) {
		// 		if(dep.isThisDepOfType(asType())) {
		// 			prefix = "class " + prefix;
		// 		} else {
		// 			Main.addDep(asType());
		// 		}
		// 	}
		// }

		final mmt = asValue ? Value : getMemoryManagementTypeFromType(asType());
		return prefix + compileModuleTypeName(cls, pos, params, useNamespaces, mmt);
	}

	// ----------------------------
	// Compile EnumType.
	public function compileEnumName(enumType: Ref<EnumType>, pos: Position, params: Null<Array<Type>> = null, useNamespaces: Bool = true, asValue: Bool = false, dependent: Bool = false): String {
		function asType() return TEnum(enumType, params ?? []);

		var prefix = typePrefix(asType());

		// There are some instances where compileEnumName is called outside
		// of "compileType", so we must check for @:nativeTypeCode again.
		if(enumType.get().hasMeta(Meta.NativeTypeCode)) {
			final r = compileNativeTypeCode(asType(), pos, asValue);
			if(r != null) return prefix + r;
		}
		
		if(dependent) {
			final dep = Main.getCurrentDep();
			if(dep != null) {
				if(dep.isThisDepOfType(asType())) {
					prefix = "class " + prefix;
				} else {
					Main.addDep(asType(), pos);
				}
			}
		}

		final mmt = asValue ? Value : getMemoryManagementTypeFromType(asType());
		return prefix + compileModuleTypeName(enumType.get(), pos, params, useNamespaces, mmt);
	}

	// ----------------------------
	// Compile DefType.
	public function compileDefName(defType: Ref<DefType>, pos: Position, params: Null<Array<Type>> = null, useNamespaces: Bool = true, asValue: Bool = false): String {
		function asType() return TType(defType, params ?? []);

		final mmt = asValue ? Value : getMemoryManagementTypeFromType(asType());
		return typePrefix(asType()) + compileModuleTypeName(defType.get(), pos, params, useNamespaces, mmt);
	}

	// ----------------------------
	// Wrap compiled type based on the
	// provided memory management type.
	function applyMemoryManagementWrapper(inner: String, mmType: MemoryManagementType): String {
		return switch(mmType) {
			case Value: inner;
			case UnsafePtr: inner + "*";
			case UniquePtr: Compiler.UniquePtrClassCpp + "<" + inner + ">";
			case SharedPtr: Compiler.SharedPtrClassCpp + "<" + inner + ">";
		}
	}

	// ----------------------------
	// Returns the memory manage type
	// based on the meta of the Type.
	public static function getMemoryManagementTypeFromType(t: Type): MemoryManagementType {
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
					final inner = Compiler.getAbstractInner(t);
					if(t.equals(inner)) {
						Value;
					} else {
						getMemoryManagementTypeFromType(inner);
					}
				}
			}
			case TType(defRef, params) if(t.isRefOrConstRef()): {
				getMemoryManagementTypeFromType(params[0]);
			}
			case TType(defRef, params): {
				getMemoryManagementTypeFromType(Compiler.getTypedefInner(t));
			}
			case TAnonymous(a): {
				#if cxx_smart_ptr_disabled
				Value;
				#else
				SharedPtr;
				#end
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
			templateState.pop().trustMe().dynamicTemplates;
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
