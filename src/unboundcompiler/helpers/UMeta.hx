// =======================================================
// * UMeta
//
// List all the custom metadata used in this project and
// provides access using a String enum abstract.
//
// Furthermore, it adds static extensions for objects that
// match: { name: String, meta: Null<MetaAccess> }
// =======================================================

package unboundcompiler.helpers;

#if (macro || ucpp_runtime)

using reflaxe.helpers.NameMetaHelper;

enum abstract Meta(String) from String to String {
	// @:headerOnly
	//
	// The module declaration with this meta will only be generated
	// in a header file.
	var HeaderOnly = ":headerOnly";

	// @:arrowAccess
	//
	// If used on a class, that class will use an arrow operator (->)
	// for access instead of the default for its memory management.
	var ArrowAccess = ":arrowAccess";

	// @:overrideMemoryManagement
	//
	// If used on an abstract, its memory management type will be
	// wrapped around its internal type.
	var OverrideMemoryManagement = ":overrideMemoryManagement";

	// @:valueType
	//
	// If defined on a class, instances of that class will default
	// to value memory management if not specified otherwise.
	var ValueType = ":valueType";

	// @:unsafePtrType
	//
	// If defined on a class, instances of that class will default
	// to pointer memory management if not specified otherwise.
	var UnsafePtrType = ":unsafePtrType";

	// @:uniquePtrType
	//
	// If defined on a class, instances of that class will default
	// to unique pointer memory management if not specified otherwise.
	var UniquePtrType = ":uniquePtrType";

	// @:sharedPtrType
	//
	// If defined on a class, instances of that class will default
	// to shared pointer memory management if not specified otherwise.
	// Classes use shared pointer management by default, so this meta
	// technically doesn't do anything.
	var SharedPtrType = ":sharedPtrType";

	// @:noInclude
	//
	// If defined on a module type, it will have no default include
	// when used in a file.
	var NoInclude = ":noInclude";

	// @:yesInclude
	//
	// If defined on an abstract, it ensures the abstract is included
	// rather than the underlying Type. See `ucpp.DynamicToString`.
	var YesInclude = ":yesInclude";

	// @:include(includePath: String, triangleBrackets: Bool = false)
	//
	// Overrides the default include used to include this module type
	// in a file.
	var Include = ":include";

	// @:addInclude(includePath: String, triangleBrackets: Bool = false)
	//
	// Adds an additional include to be generated when this module type
	// is used in a file.
	var AddInclude = ":addInclude";

	// @:headerInclude(includePath: String, triangleBrackets: Bool = false)
	//
	// Generates an include in the header file this module type is
	// generated in.
	var HeaderInclude = ":headerInclude";

	// @:cppInclude(includePath: String, triangleBrackets: Bool = false)
	//
	// Generates an include in the source file this module type is
	// generated in.
	var CppInclude = ":cppInclude";

	// @:includeHaxeUtils
	//
	// If used on a module type, the Haxe utils header will be included
	// in the declaration file. If used on a field, the header will
	// be included in any file the field is accessed in.
	//
	// Mainly used in the standard library, as this header will
	// normally be included automatically if necessary.
	var IncludeHaxeUtils = ":includeHaxeUtils";

	// @:includeAnonUtils
	//
	// If used on a module type, the anonymous structure utils header
	// will be included in the declaration file. If used on a field,
	// the header will be included in any file the field is accessed in.
	//
	// Mainly used in the standard library, as this header will
	// normally be included automatically if necessary.
	var IncludeAnonUtils = ":includeAnonUtils";

	// @:includeTypeUtils
	//
	// If used on a module type, the type reflection utils header
	// will be included in the declaration file. If used on a field,
	// the header will be included in any file the field is accessed in.
	//
	// Mainly used in the standard library, as this header will
	// normally be included automatically if necessary.
	var IncludeTypeUtils = ":includeTypeUtils";

	// @:filename(filename: String)
	//
	// If used on a module type, it will set the file name the
	// module is generated in. This applies to both the header and
	// the source file.
	var Filename = ":filename";

	// @:extern
	//
	// If used on a typedef, it will make the typedef not generate.
	var Extern = ":extern";

	// @:headerCode(code: String)
	//
	// Generates additional C++ code to be used in the header file
	// this module type is generated in (or would be generated in).
	var HeaderCode = ":headerCode";

	// @:cppFileCode(code: String)
	//
	// Generates additional C++ code to be used in the source file
	// this module type is generated in (or would be generated in).
	var CppFileCode = ":cppFileCode";

	// @:cppTypedef
	//
	// If used on a typedef, it will be generated as a C++ "typedef"
	// if possible, as opposed to a C++ "using".
	var CppTypedef = ":cppTypedef";

	// @:noAutogen
	//
	// If used on a class no additional content is generated for it.
	var NoAutogen = ":noAutogen";

	// @:constExpr
	//
	// Adds the constexpr specifier to the field or expression.
	var ConstExpr = ":constExpr";

	// @:cppInline
	//
	// Adds the inline keyword to the C++ function output.
	var CppInline = ":cppInline";

	// @:cppInline
	//
	// Adds the virtual keyword to the C++ class function output.
	var Virtual = ":virtual";

	// @:specifier(name: String)
	//
	// Adds an arbitrary specifier to the C++ class function output.
	var Specifier = ":specifier";

	// @:noExcept
	//
	// Adds the noexcept keyword to the C++ function output.
	var NoExcept = ":noExcept";

	// @:prependToMain
	//
	// Calls this static function at the start of the main function.
	var PrependToMain = ":prependToMain";

	// @:prependToMain
	//
	// Generates this as a top-level function outside of any namespace
	// or class in the C++ output.
	var TopLevel = ":topLevel";

	// @:nativeName(name: String)
	//
	// If defined on a field, this will replace the field name that
	// is generated. This is different from @:native as that meta
	// replaces the entire expression, but this simply replaces
	// the field name.
	var NativeName = ":nativeName";

	// @:nativeVariableCode(code: String)
	//
	// Works just like @:native, but allows for some macros to
	// be used within the "code".
	//
	// {this}
	// Replaced with the expression whose field is accessed.
	//
	// {var}
	// Replaced with the field-access expression C++ output
	// that would've normally been generated without this
	// meta.
	var NativeVariableCode = ":nativeVariableCode";

	// @:nativeFunctionCode(code: String)
	//
	// Works just like @:native, but allows for some macros to
	// be used within the "code".
	//
	// {this}
	// Replaced with the expression whose field is accessed.
	//
	// {argX}
	// Replaced with the C++ output that would be generated for
	// argument number "X" (starting from 0).
	//
	// {typeX}
	// Replaced with the C++ output that would be generated for
	// type parameter number "X" (starting from 0).
	var NativeFunctionCode = ":nativeFunctionCode";

	// @:nativeFunctionCode(code: String)
	//
	// Works just like @:native, but allows for some macros to
	// be used within the "code".
	//
	// {typeX}
	// Replaced with the C++ output that would be generated for
	// type parameter number "X" (starting from 0).
	var NativeTypeCode = ":nativeTypeCode";

	// @:directEquality
	//
	// If defined on a class, objects are not converted to value type
	// when using the equality operator.
	var DirectEquality = ":directEquality";

	// @:noHaxeNamespaces
	//
	// If defined on a module type, namespaces are never used when
	// compiling the type's name.
	var NoHaxeNamespaces = ":noHaxeNamespaces";

	// @:typenamePrefixIfDependentScope
	//
	// Whenever this type's type parameters are passed type parameter
	// from elsewhere, it will be generated with the "typename" prefix.
	var TypenamePrefixIfDependentScope = ":typenamePrefixIfDependentScope";
}

// An enum for memory management types.
enum MemoryManagementType {
	Value;
	UnsafePtr;
	SharedPtr;
	UniquePtr;
}

class UMeta {
	public static function hasNativeMeta(meta: NameAndMeta): Bool {
		return meta.hasMeta(":native");
	}

	public static function isHeaderOnly(meta: NameAndMeta): Bool {
		return meta.hasMeta(Meta.HeaderOnly);
	}

	public static function isArrowAccess(meta: NameAndMeta): Bool {
		return meta.hasMeta(Meta.ArrowAccess);
	}

	public static function isOverrideMemoryManagement(meta: NameAndMeta): Bool {
		return meta.hasMeta(Meta.OverrideMemoryManagement);
	}

	// ----------------------------
	// Returns the memory manage type
	// based on the meta.
	public static function getMemoryManagementType(meta: NameAndMeta): MemoryManagementType {
		return if(meta.hasMeta(Meta.ValueType)) {
			Value;
		} else if(meta.hasMeta(Meta.UnsafePtrType)) {
			UnsafePtr;
		} else if(meta.hasMeta(ValueType.UniquePtrType)) {
			UniquePtr;
		} else {
			SharedPtr;
		}
	}

	public static function hasMemoryManagementType(meta: NameAndMeta): Bool {
		return meta.hasMeta(Meta.ValueType) || meta.hasMeta(Meta.UnsafePtrType) || meta.hasMeta(ValueType.UniquePtrType) || meta.hasMeta(ValueType.SharedPtrType);
	}
}

#end
