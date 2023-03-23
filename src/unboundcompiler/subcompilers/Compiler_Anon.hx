// =======================================================
// * Compiler_Anon
//
// This sub-compiler is used to handle compiling of all
// anonymous structure expressions and classes.
// =======================================================

package unboundcompiler.subcompilers;

#if (macro || ucpp_runtime)

import haxe.macro.Expr;
import haxe.macro.Type;

using reflaxe.helpers.PositionHelper;
using reflaxe.helpers.SyntaxHelper;
using reflaxe.helpers.TypeHelper;

using unboundcompiler.helpers.USort;

import unboundcompiler.helpers.UMeta.MemoryManagementType;

typedef AnonField = { name: String, type: Type, optional: Bool, ?pos: Position };
typedef AnonStruct = { name: String, constructorOrder: Array<AnonField>, templates: Array<String>, cpp: String };

@:allow(unboundcompiler.UnboundCompiler)
@:access(unboundcompiler.UnboundCompiler)
@:access(unboundcompiler.subcompilers.Compiler_Includes)
@:access(unboundcompiler.subcompilers.Compiler_Exprs)
@:access(unboundcompiler.subcompilers.Compiler_Types)
class Compiler_Anon extends SubCompiler {
	var anonId: Int = 0;
	var anonStructs: Map<String, AnonStruct> = [];
	var namedAnonStructs: Map<String, AnonStruct> = [];

	public function compileObjectDecl(type: Type, fields: Array<{ name: String, expr: TypedExpr }>, originalExpr: TypedExpr, compilingInHeader: Bool = false): String {
		final anonFields: Array<AnonField> = [];
		final anonMap: Map<String, TypedExpr> = [];
		for(f in fields) {
			final ft = Main.getExprType(f.expr);
			Main.onTypeEncountered(ft, compilingInHeader);
			final field = {
				name: f.name,
				type: ft,
				optional: ft.isNull()
			};
			anonFields.push(field);
			anonMap.set(f.name, f.expr);
		}

		var isNamed = false;
		final t = type.unwrapNullTypeOrSelf();
		var as: Null<AnonStruct> = switch(t) {
			case TType(defTypeRef, params): {
				final inner = Main.getTypedefInner(t);
				switch(inner) {
					case TAnonymous(a): {
						isNamed = true;
						getNamedAnonStruct(defTypeRef.get(), a);
					}
					case _: null;
				}
			}
			case _: null;
		}

		if(as == null) {
			as = findAnonStruct(anonFields);
		}

		final el = [];
		final elType = [];
		for(field in as.constructorOrder) {
			final e = anonMap.get(field.name);
			if(e != null) {
				el.push(e);
				elType.push(field.type);
			}
		}

		final internalType = type.unwrapNullTypeOrSelf();

		var name = if(isNamed) {
			TComp.compileType(internalType, originalExpr.pos, true);
		} else {
			"haxe::" + as.name;
		}

		if(!isNamed && as.templates.length > 0) {
			name += "<" + as.templates.join(", ") + ">";
		}

		IComp.addAnonTypeInclude(compilingInHeader);
		final cppArgs = [];
		for(i in 0...el.length) {
			cppArgs.push(XComp.compileExpressionForType(el[i], elType[i]));
		}
		final tmmt = TComp.getMemoryManagementTypeFromType(internalType);
		return applyAnonMMConversion(name, cppArgs, tmmt);
	}

	public function applyAnonMMConversion(cppName: String, cppArgs: Array<String>, tmmt: MemoryManagementType): String {
		return switch(tmmt) {
			case Value: cppName + "::make(" + cppArgs.join(", ") + ")";
			case UnsafePtr: throw "Unable to construct.";
			case SharedPtr: "haxe::shared_anon<" + cppName + ">(" + cppArgs.join(", ") + ")";
			case UniquePtr: "haxe::unique_anon<" + cppName + ">(" + cppArgs.join(", ") + ")";
		}
	}

	public function compileAnonType(anonRef: Ref<AnonType>): String {
		final anonFields: Array<AnonField> = [];
		for(f in anonRef.get().fields) {
			anonFields.push({
				name: f.name,
				type: f.type,
				optional: f.type.isNull()
			});
		}
		final as = findAnonStruct(anonFields);
		return "haxe::" + as.name + {
			if(as.templates.length > 0) {
				for(t in as.templates) {
					TComp.addDynamicTemplate(t);
				}
				"<" + as.templates.join(", ") + ">";
			} else {
				"";
			}
		};
	}

	public function compileNamedAnonTypeDefinition(defType: DefType, anonRef: Ref<AnonType>): String {
		final anonStruct = getNamedAnonStruct(defType, anonRef);
		return anonStruct.cpp;
	}

	function makeAnonTypeDecl(name: String, anonFields: Array<AnonField>): { templates: Array<String>, cpp: String } {
		final fields = [];
		final constructorParams = [];
		final constructorAssigns = [];
		final templateConstructorAssigns = [];
		final templateFunctionAssigns = [];
		final extractorFuncs = [];

		TComp.enableDynamicToTemplate([]);

		for(f in anonFields) {
			Main.onTypeEncountered(f.type, true);
			final t = TComp.compileType(f.type, f.pos);
			final v = t + " " + f.name;
			fields.push(v);
			constructorParams.push(v + (f.optional ? " = std::nullopt" : ""));
			constructorAssigns.push("result." + f.name + " = " + f.name);
			switch(f.type) {
				case TFun(args, ret): {
					final declArgs = args.map(a -> {
						Main.onTypeEncountered(a.t, true);
						return TComp.compileType(a.t, PositionHelper.unknownPos()) + " " + a.name;
					}).join(", ");
					final callArgs = args.map(a -> a.name).join(", ");
					templateFunctionAssigns.push(f.name + " = [&o](" + declArgs + ") { return o." + f.name + "(" + callArgs + "); };");
				}
				case _: {
					templateConstructorAssigns.push(f.name + "(" + (f.optional ? ("extract_" + f.name + "(o)") : ("o." + f.name)) + ")");
				}
			}
			if(f.optional) {
				extractorFuncs.push(f.name);
			}
		}

		final templates = TComp.disableDynamicToTemplate();

		var decl = "";

		decl += "// { " + anonFields.map(f -> f.name + ": " + haxe.macro.TypeTools.toString(f.type)).join(", ") + " }\n";

		if(templates.length > 0) {
			decl += "template<" + templates.map(t -> "typename " + t).join(", ") + ">\n";
		}

		decl += "struct " + name + " {";
		
		decl += "\n\n\t// default constructor\n\t" + name + "() {}\n";

		if(templateConstructorAssigns.length > 0 || templateFunctionAssigns.length > 0) {
			final templateFuncs = templateFunctionAssigns.length > 0 ? ("{\n" + templateFunctionAssigns.map(a -> a.tab()).join("\n") + "\n}") : "\n{}";
			final templateAssigns = templateConstructorAssigns.length > 0 ? (":\n\t" + templateConstructorAssigns.join(", ")) : " ";
			
			var autoConstructTypeParamName = "T";
			while(templates.contains(autoConstructTypeParamName)) {
				autoConstructTypeParamName += "_";
			}
			
			var constructor = "\n// auto-construct from any object's fields\n";
			constructor += "template<typename " + autoConstructTypeParamName + ">\n";
			constructor += name + "(" + autoConstructTypeParamName + " o)" + templateAssigns + templateFuncs;
			decl += constructor.tab() + "\n";
		}

		if(constructorParams.length > 0) {
			final constructor = "\n// construct fields directly\nstatic " + name + " make(" + constructorParams.join(", ") + ") {\n\t" +
				name + " result;\n\t" +
				constructorAssigns.join(";\n\t") + ";" + 
				"\n\treturn result;\n}";
			decl += constructor.tab() + "\n";
		}

		if(fields.length > 0) {
			decl += "\n\t// fields\n" + fields.map(f -> f.tab() + ";").join("\n") + "\n";
		}

		if(extractorFuncs.length > 0) {
			decl += "\n" + extractorFuncs.map(f -> ("GEN_EXTRACTOR_FUNC(" + f + ")").tab()).join("\n") + "\n";
		}

		decl += "};\n";

		return { templates: templates, cpp: decl };
	}

	function getNamedAnonStruct(defType: DefType, anonRef: Ref<AnonType>): AnonStruct {
		final key = generateAccessNameFromDefType(defType);
		final anonFields = anonRef.get().fields.map(classFieldToAnonField);
		final sortedAnonFields = anonFields.sorted(orderFields);
		final decl = makeAnonTypeDecl(defType.name, sortedAnonFields);
		final result = {
			name: key,
			constructorOrder: sortedAnonFields,
			templates: decl.templates,
			cpp: decl.cpp
		};
		namedAnonStructs.set(key, result);
		return result;
	}

	function generateAccessNameFromDefType(defType: DefType): String {
		return StringTools.replace(defType.module, ".", "::") + "::" + defType.name;
	}

	function classFieldToAnonField(clsField: ClassField): AnonField {
		return {
			name: clsField.name,
			type: clsField.type,
			optional: clsField.type.isNull(),
			pos: clsField.pos
		};
	}

	function findAnonStruct(anonFields: Array<AnonField>): AnonStruct {
		final key = makeAnonStructKey(anonFields);
		if(!anonStructs.exists(key)) {
			final name = "AnonStruct" + (anonId++);
			final decl = makeAnonTypeDecl(name, anonFields);
			anonStructs.set(key, {
				name: name,
				constructorOrder: anonFields,
				templates: decl.templates,
				cpp: decl.cpp
			});
		}
		return anonStructs.get(key);
	}

	function makeAnonStructKey(anonFields: Array<AnonField>): String {
		final fields = anonFields.sorted(orderFields);
		return fields.map(makeFieldKey).join("||");
	}

	function orderFields(a: AnonField, b: AnonField): Int {
		if(a.optional && !b.optional) return 1;
		if(!a.optional && b.optional) return -1;
		return USort.alphabetic(a.name, b.name);
	}

	function makeFieldKey(a: AnonField): String {
		return a.name + ":" + Std.string(a.type) + (a.optional ? "?" : "");
	}

	function makeAllUnnamedDecls() {
		final decls = [];
		for(name => as in anonStructs) {
			decls.push(as.cpp);
			for(f in as.constructorOrder) {
				IComp.addIncludeFromType(f.type, true);
			}
		}
		return decls.join("\n\n");
	}

	function optionalInfoContent() {
		return '// haxe::shared_anon | haxe::unique_anon
// Helper functions for generating "anonymous struct" smart pointers.
namespace haxe {

	template<typename Anon, class... Args>
	${UnboundCompiler.SharedPtrClassCpp}<Anon> shared_anon(Args... args) {
		return ${UnboundCompiler.SharedPtrMakeCpp}<Anon>(Anon::make(args...));
	}

	template<typename Anon, class... Args>
	${UnboundCompiler.UniquePtrClassCpp}<Anon> unique_anon(Args... args) {
		return ${UnboundCompiler.UniquePtrMakeCpp}<Anon>(Anon::make(args...));
	}

}

// ---------------------------------------------------------------------

// haxe::optional_info
// Returns information about std::optional<T> types.
namespace haxe {

	template <typename T>
	struct optional_info {
		using inner = T;
		static constexpr bool isopt = false;
	};

	template <typename T>
	struct optional_info<std::optional<T>> {
		using inner = typename optional_info<T>::inner;
		static constexpr bool isopt = true;
	};

}

// ---------------------------------------------------------------------


// haxe::_unwrap_mm
// Unwraps all the \"memory management\" types to get the underlying
// value type. Also provided whether or not that type is deref-able.
namespace haxe {

	template<typename T>
	struct _unwrap_mm {
		using inner = T;
		constexpr static bool can_deref = false;
	};

	template<typename T>
	struct _unwrap_mm<T*> {
		using inner = typename _unwrap_mm<T>::inner;
		constexpr static bool can_deref = true;
	};

	template<typename T>
	struct _unwrap_mm<T&> {
		using inner = typename _unwrap_mm<T>::inner;
		constexpr static bool can_deref = false;
	};

	template<typename T>
	struct _unwrap_mm<std::shared_ptr<T>> {
		using inner = typename _unwrap_mm<T>::inner;
		constexpr static bool can_deref = true;
	};

	template<typename T>
	struct _unwrap_mm<std::unique_ptr<T>> {
		using inner = typename _unwrap_mm<T>::inner;
		constexpr static bool can_deref = true;
	};

}

// ---------------------------------------------------------------------

// GEN_EXTRACTOR_FUNC
// Generates a function named extract_[fieldName].
//
// Given any object, it checks whether that object has a field of the same name
// and type as the class this function is a member of (using `haxe::optional_info`).
//
// If it does, it returns the object\'s field\'s value; otherwise, it returns `std::nullopt`.
//
// Useful for extracting values for optional parameters for anonymous structure
// classes since the input object may or may not have the field.

#define GEN_EXTRACTOR_FUNC(fieldName)\\
template<typename T, typename Other = decltype(T().fieldName), typename U = typename haxe::optional_info<Other>::inner>\\
static auto extract_##fieldName(T other) {\\
	if constexpr(!haxe::optional_info<decltype(fieldName)>::isopt && haxe::optional_info<Other>::isopt) {\\
		return other.customParam.get();\\
	} else if constexpr(std::is_same<U,haxe::optional_info<decltype(fieldName)>::inner>::value) {\\
		return other.customParam;\\
	} else {\\
		return std::nullopt;\\
	}\\
}';
	}
}

#end
