// =======================================================
// * Compiler_Reflection
//
// This sub-compiler is used to handle compiling anything
// related to Haxe reflection.
//
// This mainly involves compiling C++ to make the `Type`,
// `Reflect`, `Dynamic` and `Class<T>` types function
// properly.
// =======================================================

package unboundcompiler.subcompilers;

#if (macro || ucpp_runtime)

import haxe.macro.Type;

using reflaxe.helpers.PositionHelper;
using reflaxe.helpers.SyntaxHelper;

@:allow(unboundcompiler.UnboundCompiler)
@:access(unboundcompiler.UnboundCompiler)
class Compiler_Reflection extends SubCompiler {
	var compiledModules: Array<ModuleType> = [];
	var compiledClasses: Array<ClassType> = [];
	var compiledEnums: Array<EnumType> = [];

	public function addCompiledModuleType(mt: ModuleType) {
		compiledModules.push(mt);
		switch(mt) {
			case TClassDecl(c): addCompiledClassType(c.get());
			case TEnumDecl(e): addCompiledEnumType(e.get());
			case _:
		}
	}

	function addCompiledClassType(cls: ClassType) {
		compiledClasses.push(cls);
	}

	function addCompiledEnumType(enm: EnumType) {
		compiledEnums.push(enm);
	}

	public function compileClassReflection(cls: ClassType): String {
		final cpp = TComp.compileClassName(cls, PositionHelper.unknownPos(), null, true, true);

		final instanceFields = cls.fields.get().map(f -> Main.compileVarName(f.name));
		final staticFields = cls.statics.get().map(f -> Main.compileVarName(f.name));

		final ic = instanceFields.length;
		final sc = staticFields.length;

		final ifCpp = ic == 0 ? "{}" : "{ " + instanceFields.map(f -> "\"" + f + "\"").join(", ") + " }";
		final sfCpp = sc == 0 ? "{}" : "{ " + staticFields.map(f -> "\"" + f + "\"").join(", ") + " }";

		final fields = ['\"${cls.name}\"', ifCpp, sfCpp];

		// If the total number of fields is less than 10,
		// place everything on a single line.
		final fieldsCpp = if((ic + sc) >= 10) {
			"\n" + fields.map(f -> f.tab()).join(",\n") + "\n\t";
		} else {
			fields.join(", ");
		}

		return 'template<> struct _class<${cpp}> {
	DEFINE_CLASS_TOSTRING
	constexpr static _class_data<${ic}, ${sc}> data {${fieldsCpp}};
};';
	}

	public function typeUtilHeaderContent() {
		IComp.addInclude("array", true, true);
		IComp.addInclude("string", true, true);
		IComp.addInclude("memory", true, true);

		return "// ---------------------------------------------------------------------
// haxe::_class<T>
//
// A class used to access reflection information regarding Haxe types.
// ---------------------------------------------------------------------

namespace haxe {

template<typename T>
struct _class;

template<std::size_t sf_size, std::size_t if_size, typename Super = void>
struct _class_data {
	using super_class = _class<Super>;
	constexpr static bool has_super_class = std::is_same<Super, void>::value;

	const char* name = \"<unknown>\";
	const std::array<const char*, sf_size> static_fields;
	const std::array<const char*, if_size> instance_fields;
};

#define DEFINE_CLASS_TOSTRING\\
	std::string toString() {\\
		return std::string(\"Class<\") + data.name + \">\";\\
	}

template<typename T> struct _class {
	constexpr static _class_data<0, 0> data {\"unknown type\", {}, {}};
};

}

// ---------------------------------------------------------------------
// haxe::_unwrap_class
//
// Unwraps Class<T> to T.
// ---------------------------------------------------------------------

namespace haxe {

template<typename T>
struct _unwrap_class {
	using inner = T;
	constexpr static bool iscls = false;
};

template<typename T>
struct _unwrap_class<_class<T>> {
	using inner = typename _unwrap_class<T>::inner;
	constexpr static bool iscls = true;
};

}

// ---------------------------------------------------------------------
// haxe::_unwrap_mm
//
// Unwraps all the \"memory management\" types to get the underlying
// value type. Requires the type to be known at compile-time.
// ---------------------------------------------------------------------

namespace haxe {

template<typename T>
struct _unwrap_mm { using inner = T; };

template<typename T>
struct _unwrap_mm<T*> { using inner = typename _unwrap_mm<T>::inner; };

template<typename T>
struct _unwrap_mm<T&> { using inner = typename _unwrap_mm<T>::inner; };

template<typename T>
struct _unwrap_mm<std::shared_ptr<T>> { using inner = typename _unwrap_mm<T>::inner; };

template<typename T>
struct _unwrap_mm<std::unique_ptr<T>> { using inner = typename _unwrap_mm<T>::inner; };

}";
	}
}

#end