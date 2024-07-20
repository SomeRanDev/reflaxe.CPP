// =======================================================
// * Meta
//
// List all the custom metadata used in this project and
// provides access using a String enum abstract.
// =======================================================

package cxxcompiler.config;

enum abstract Meta(String) from String to String {
	/**
		@:uncompilable

		If the Reflaxe/C++ type compiler tries to compile this type
		or field, an error is thrown at the position its compiling for.
	**/
	var Uncompilable = ":uncompilable";

	/**
		@:headerOnly

		The module declaration with this meta will only be generated
		in a header file.
	**/
	var HeaderOnly = ":headerOnly";

	/**
		@:arrowAccess

		If used on a class, that class will use an arrow operator (->)
		for access instead of the default for its memory management.
	**/
	var ArrowAccess = ":arrowAccess";

	/**
		@:copyType

		Makes it so when used as a value type, variables will be
		generated as values instead of references.
	**/
	var CopyType = ":copyType";

	/**
		@:overrideMemoryManagement

		If used on an abstract, its memory management type will be
		wrapped around its internal type.
	**/
	var OverrideMemoryManagement = ":overrideMemoryManagement";

	/**
		@:forwardMemoryManagement

		If used on an abstract or typedef, memory management type
		is based on the inner type.
	**/
	var ForwardMemoryManagement = ":forwardMemoryManagement";

	/**
		@:valueType

		If defined on a class, instances of that class will default
		to value memory management if not specified otherwise.
	**/
	var ValueType = ":valueType";

	/**
		@:unsafePtrType

		If defined on a class, instances of that class will default
		to pointer memory management if not specified otherwise.
	**/
	var UnsafePtrType = ":unsafePtrType";

	/**
		@:uniquePtrType

		If defined on a class, instances of that class will default
		to unique pointer memory management if not specified otherwise.
	**/
	var UniquePtrType = ":uniquePtrType";

	/**
		@:sharedPtrType

		If defined on a class, instances of that class will default
		to shared pointer memory management if not specified otherwise.
		
		Classes use shared pointer management by default, so this meta
		technically doesn't do anything.
	**/
	var SharedPtrType = ":sharedPtrType";

	/**
		@:noInclude

		If defined on a module type, it will have no default include
		when used in a file.
	**/
	var NoInclude = ":noInclude";

	/**
		@:yesInclude

		If defined on an abstract, it ensures the abstract is included
		rather than the underlying Type. See `cxx.DynamicToString`.
	**/
	var YesInclude = ":yesInclude";

	/**
		@:include(includePath: String, triangleBrackets: Bool = false)

		Overrides the default include used to include this module type
		in a file.
	**/
	var Include = ":include";

	/**
		@:addInclude(includePath: String, triangleBrackets: Bool = false)

		Adds an additional include to be generated when this module type
		is used in a file.
	**/
	var AddInclude = ":addInclude";

	/**
		@:usingNamespace(ns: String)

		Adds "using namespace {ns};" to the top of the file of the class
		is generated to or the location this field is accessed.
	**/
	var UsingNamespace = ":usingNamespace";

	/**
		@:headerInclude(includePath: String, triangleBrackets: Bool = false)

		Generates an include in the header file this module type is
		generated in.
	**/
	var HeaderInclude = ":headerInclude";

	/**
		@:cppInclude(includePath: String, triangleBrackets: Bool = false)

		Generates an include in the source file this module type is
		generated in.
	**/
	var CppInclude = ":cppInclude";

	/**
		@:includeHaxeUtils
		
		If used on a module type, the Haxe utils header will be included
		in the declaration file. If used on a field, the header will
		be included in any file the field is accessed in.
		
		Mainly used in the standard library, as this header will
		normally be included automatically if necessary.
	**/
	var IncludeHaxeUtils = ":includeHaxeUtils";

	/**
		@:includeAnonUtils
		
		If used on a module type, the anonymous structure utils header
		will be included in the declaration file. If used on a field,
		the header will be included in any file the field is accessed in.
		
		Mainly used in the standard library, as this header will
		normally be included automatically if necessary.
	**/
	var IncludeAnonUtils = ":includeAnonUtils";

	/**
		@:includeTypeUtils
		
		If used on a module type, the type reflection utils header
		will be included in the declaration file. If used on a field,
		the header will be included in any file the field is accessed in.
		
		Mainly used in the standard library, as this header will
		normally be included automatically if necessary.
	**/
	var IncludeTypeUtils = ":includeTypeUtils";

	/**
		@:filename(filename: String)
		
		If used on a module type, it will set the file name the
		module is generated in. This applies to both the header and
		the source file.
	**/
	var Filename = ":filename";

	/**
		@:extern

		If used on a typedef, it will make the typedef not generate.
	**/
	var Extern = ":extern";

	/**
		@:cppEnum

		If used on an extern enum, it will be treated like a C++ enum.
	**/
	var CppEnum = ":cppEnum";

	/**
		@:headerCode(code: String)

		Generates additional C++ code to be used in the header file
		this module type is generated in (or would be generated in).
	**/
	var HeaderCode = ":headerCode";

	/**
		@:cppFileCode(code: String)

		Generates additional C++ code to be used in the source file
		this module type is generated in (or would be generated in).
	**/
	var CppFileCode = ":cppFileCode";

	/**
		@:headerClassCode(code: String)

		Generates additional C++ code to be used inside the class
		declaration.
	**/
	var HeaderClassCode = ":headerClassCode";

	/**
		@:cppTypedef

		If used on a typedef, it will be generated as a C++ "typedef"
		if possible, as opposed to a C++ "using".
	**/
	var CppTypedef = ":cppTypedef";

	/**
		@:noAutogen

		If used on a class no additional content is generated for it.
	**/
	var NoAutogen = ":noAutogen";

	/**
		@:noDiscard(nonMutating: Bool = false)
		
		Marks an extern variable or field as [[nodiscard]] and will
		generate C++ to prevent discard warnings from occuring.
		
		If `nonMutating` is `true`, that means accessing this field
		does not affect the program's state and is safe to remove
		if the return value is unused.
	**/
	var NoDiscard = ":noDiscard";

	/**
		@:const

		Adds the const specifier to the field or expression.
	**/
	var Const = ":const";

	/**
		@:constExpr

		Adds the constexpr specifier to the field or expression.
	**/
	var ConstExpr = ":constExpr";

	/**
		@:cppInline

		Adds the inline keyword to the C++ function output.
	**/
	var CppInline = ":cppInline";

	/**
		@:cppInline

		Adds the virtual keyword to the C++ class function output.
	**/
	var Virtual = ":virtual";

	/**
		@:specifier(name: String)

		Adds an arbitrary specifier to the C++ class function output.
	**/
	var Specifier = ":specifier";

	/**
		@:noExcept

		Adds the noexcept keyword to the C++ function output.
	**/
	var NoExcept = ":noExcept";

	/**
		@:prependToMain

		Calls this static function at the start of the main function.
	**/
	var PrependToMain = ":prependToMain";

	/**
		@:prependToMain

		Generates this as a top-level function outside of any namespace
		or class in the C++ output.
	**/
	var TopLevel = ":topLevel";

	/**
		@:nativeName(name: String, overrideId: String = "")
		
		If defined on a field, this will replace the field name that
		is generated. This is different from @:native as that meta
		replaces the entire expression, but this simply replaces
		the field name.
	**/
	var NativeName = ":nativeName";

	/**
		@:nativeVariableCode(code: String)
		
		Works just like @:native, but includes some helpeful text
		macros to be used within the "code".
		
		{this}
		Replaced with the expression whose field is accessed.
		
		{var}
		Replaced with the field-access expression C++ output
		that would've normally been generated without this
		meta.
	**/
	var NativeVariableCode = ":nativeVariableCode";

	/**
		@:nativeFunctionCode(code: String)
		
		Works just like @:native, but includes some helpeful text
		macros to be used within the "code".
		
		{this}
		Replaced with the expression whose field is accessed.
		
		{argX}
		Replaced with the C++ output that would be generated for
		argument number "X" (starting from 0).
		
		{typeX}
		Replaced with the C++ output that would be generated for
		type parameter number "X" (starting from 0).
	**/
	var NativeFunctionCode = ":nativeFunctionCode";

	/**
		@:nativeFunctionCode(code: String)
		
		Works just like @:native, but includes some helpeful text
		macros to be used within the "code".
		
		{typeX}
		Replaced with the C++ output that would be generated for
		type parameter number "X" (starting from 0).
	**/
	var NativeTypeCode = ":nativeTypeCode";

	/**
		@:makeThisNotNull

		Used with @:nativeFunctionCode. Ensures {this} expression
		is compiled as "not null".
	**/
	var MakeThisNotNull = ":makeThisNotNull";

	/**
		@:makeThisValue

		Used with @:nativeFunctionCode. Ensures {this} expression
		is compiled as a value type.
	**/
	var MakeThisValue = ":makeThisValue";

	/**
		@:appendContent(code: String)

		Appends arbitrary C++ code to the declaration of the 
		module type or field.
	**/
	var AppendContent = ":appendContent";

	/**
		@:prependContent(code: String)

		Prepends arbitrary C++ code to the declaration of the 
		module type or field.
	**/
	var PrependContent = ":prependContent";

	/**
		@:classNamePrefix(code: String)

		Prepends arbitrary C++ code between the "class" keyword
		and the class name of the class C++ declaration.
	**/
	var ClassNamePrefix = ":classNamePrefix";

	/**
		@:classSection(code: String)
		
		Places the class field in a different section than the
		default "public" section. Useful for C++ frameworks like
		Qt that provide their own class sections like "signals"
		and "public slots".
	**/
	var ClassSection = ":classSection";

	/**
		@:directEquality

		If defined on a class, objects are not converted to value type
		when using the equality operator.
	**/
	var DirectEquality = ":directEquality";

	/**
		@:noHaxeNamespaces

		If defined on a module type, namespaces are never used when
		compiling the type's name.
	**/
	var NoHaxeNamespaces = ":noHaxeNamespaces";

	/**
		@:typenamePrefixIfDependentScope

		Whenever this type's type parameters are passed type parameter
		from elsewhere, it will be generated with the "typename" prefix.
	**/
	var TypenamePrefixIfDependentScope = ":typenamePrefixIfDependentScope";

	/**
		@:redirectType(fieldName: String)

		When processing this field using its type, the type of the field
		provided by this meta is used instead. Use carefully.
	**/
	var RedirectType = ":redirectType";

	/**
		@:noCallstack

		When used on a function, that function will not generate callstack
		tracking C++ code if it's enabled. 
	**/
	var NoCallstack = ":noCallstack";

	/**
		@:numberType(size: Int, isFloat: Bool, isSigned: Bool)

		Used to generate casts when converting between other number types
		to prevent C++ warnings.
	**/
	var NumberType = ":numberType";

	/**
		@:dynamicCompatible

		If used on an extern class, a dynamic wrapper will be generated
		that will allow it to be used with the `Dynamic` type.
	**/
	var DynamicCompatible = ":dynamicCompatible";

	/**
		@:dynamicArrayAccess

		If used on a class, allows for array access to be used on this class
		when Dynamic.
	**/
	var DynamicArrayAccess = ":dynamicArrayAccess";

	/**
		@:dynamicArrayAccess

		If used on an extern class, the class's operator== will be used for
		equality between Dynamic objects. This is unnecessary for classes
		generated from Haxe code.
	**/
	var DynamicEquality = ":dynamicEquality";

	/**
		@:dontGenerateDynamic
	
		If used on a field, this field will not be generated in the Dynamic
		wrapper for C++.
		
		If used on a class, the class will not have a Dynamic wrapper at all.
	**/
	var DontGenerateDynamic = ":dontGenerateDynamic";

	/**
		@:unreflective

		If used on a module type, reflection information will not be generated
		for it. This includes both an implementation for `_class` and a
		Dynamic wrapper.
	**/
	var Unreflective = ":unreflective";

	/**
		@:dynamicAccessors

		If used on a property, allows for the property to have different
		accessors when generating the Dynamic wrapper.
	**/
	var DynamicAccessors = ":dynamicAccessors";

	/**
		@:constructor

		Use on a static function to have it be treated like a constructor.
		This is mainly to support extern classes with mutliple constructors;
		however, it SHOULD also work with user-made classes.
	**/
	var Constructor = ":constructor";

	/**
		@:dontGenerateDefaultConstructor
		
		Normally, a default constructor (constructor with no arguments) is
		generated for a C++ class if possible. This metadata will disable
		this behavior for the class it's used on.
	**/
	var DontGenerateDefaultConstructor = ":dontGenerateDefaultConstructor";

	/**
		@:requireMemoryManagement(mmt: helpers.MetaHelper.MemoryManagementType)
		
		Used on extern inline functions to notify the Dynamic compiler
		that a certain memory management type is required.
		
		By default, extern inline uses an unsafe pointer, which may not
		be compatible with statements that require smart pointers.
	**/
	var RequireMemoryManagement = ":requireMemoryManagement";

	/**
		@:requireReturnTypeHasConstructor
		
		Used on extern inline functions to notify the Dynamic compiler
		that the Dynamic wrapper should only generate this field
		if its return type has a constructor.
		
		This is to bypass issues with Haxe's DCE not generating iterators
		if they could not have possibly been used.
	**/
	var RequireReturnTypeHasConstructor = ":requireReturnTypeHasConstructor";

	/**
		@:passConstTypeParam(expression: Dynamic, index: Int)
		
		Used on a class field or variable expression to replace a @:const
		type parameter on the field's type with a new expression.
		
		Can be used to transfer the value from the containing class's @:const
		parameter to the field's or variable's type.
	**/
	var PassConstTypeParam = ":passConstTypeParam";

	/**
		@:templateArg(index: Int = -1)
		
		Used on a function argument to have it be passed as a template argument.
		
		Use with normal functions to create/use template arguments.
		Use with extern function to pass template arguments.
	**/
	var TemplateArg = ":templateArg";

	/**
		@:ignoreIfExtended

		If a class or interface that is extended or implemented has this metadata,
		the "extension" will not be generated on the child class.
	**/
	var IgnoreIfExtended = ":ignoreIfExtended";

	/**
		@:cppcList

		If used on a constructor of a class, the constructor will be generate a
		initializer list for the constructor.
	**/
    var CppcList = ":cppcList";

	/**
		Internal metadata. Cannot be used directly

		Used with @:passConstTypeParam to mark KExpr classes to be overwritten.
	**/
	var OverwriteKExpr = "-overwriteKExpr";
}
