// =======================================================
// * Dynamic
//
// This sub-compiler is used to handle compiling anything
// related to the Dynamic type.
//
// Dynamic requires simulating an entire system without
// using any types, so it's a big area of focus for
// a C++ target.
// =======================================================

package cxxcompiler.subcompilers;

#if (macro || cxx_runtime)

import reflaxe.helpers.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

import reflaxe.data.ClassVarData;
import reflaxe.data.ClassFuncData;
import reflaxe.helpers.PositionHelper;

using reflaxe.helpers.NameMetaHelper;
using reflaxe.helpers.NullableMetaAccessHelper;
using reflaxe.helpers.SyntaxHelper;
using reflaxe.helpers.TypeHelper;

import cxxcompiler.config.Meta;
import cxxcompiler.helpers.MetaHelper;

using cxxcompiler.helpers.Error;

@:allow(cxxcompiler.Compiler)
@:access(cxxcompiler.Compiler)
class Dynamic_ extends SubCompiler {
	public var enabled(default, null): Bool = false;

	public var exceptionType: Null<haxe.macro.Type>;

	public function enableDynamic(blamePosition: Position) {
		// dynamic/Dynamic.h requires this
		if(exceptionType == null) {
			exceptionType = Context.getType("haxe.Exception");
			Main.onTypeEncountered(exceptionType, true, blamePosition);
		}

		enabled = true;

		// Call `onDynamicEnabled` for Class compiler
		CComp.onDynamicEnabled();
	}

	/**
		Return the name of the `Dynamic` type in C++.
	**/
	public function compileDynamicTypeName() {
		return "haxe::Dynamic";
	}

	var valueType: String = "";
	var valueTypeWParams: String = "";

	var classType: Null<ClassType> = null;
	var type: Null<Type> = null;

	var dynamicName: String = "";

	var getProps: Array<String> = [];
	var setProps: Array<String> = [];

	/**
		Reset the state of the compiler in preparation for generating
		`Dynamic` wrapper for a new class.
	**/
	public function reset(valueType: String, valueTypeWParams: String, classType: ClassType, type: Type) {
		this.valueType = valueType;
		this.valueTypeWParams = valueTypeWParams;
		this.classType = classType;
		this.type = type;

		dynamicName = "Dynamic_" + StringTools.replace(valueType, "::", "_");

		getProps = [];
		setProps = [];
	}

	/**
		Generate a `TypedExpr` given a `TypedExprDef` and `Type`.
	**/
	function genTypedExpr(typedExprDef: TypedExprDef, type: Type, pos: Null<Position> = null): TypedExpr {
		return {
			expr: typedExprDef,
			t: type,
			pos: pos ?? PositionHelper.unknownPos()
		};
	}

	/**
		Handle compilation of variable field.
	**/
	function makeGetExpr(field: ClassField): Null<String> {
		if(type == null) return null;

		final thisExpr = genTypedExpr(TConst(TThis), type);
		final exprDef = switch(type) {
			case TInst(clsRef, params): TField(thisExpr, FInstance(clsRef, params, { get: () -> field, toString: () -> "" }));
			case _: throw "Unsupported";
		}
		final expr = genTypedExpr(exprDef, field.type);

		XComp.setThisOverride(genTypedExpr(TIdent("o"), TAbstract(Main.getPtrType(), [type])));
		final cpp = Main.compileExpression(expr);
		XComp.clearThisOverride();

		return cpp;
	}

	/**
		Add a variable's get and set.
	**/
	public function addVar(v: ClassVarData, cppType: String, name: String) {
		final getDynAcc = v.field.meta.extractPrimtiveFromFirstMeta(Meta.DynamicAccessors, 0);
		if((v.read == AccNormal || v.read == AccNo) && getDynAcc != "never" && getDynAcc != "get") {
			final cpp = makeGetExpr(v.field);
			if(cpp != null) {
				getProps.push('if(name == "${name}") {
	return Dynamic::unwrap<$valueTypeWParams>(d, []($valueTypeWParams* o) {
		return makeDynamic(${cpp});
	});
}');
			}
		}

		final setDynAcc = v.field.meta.extractPrimtiveFromFirstMeta(Meta.DynamicAccessors, 1);
		if((v.write == AccNormal || v.write == AccNo) && setDynAcc != "never" && setDynAcc != "set") {
			setProps.push('if(name == "${name}") {
	return Dynamic::unwrap<$valueTypeWParams>(d, [value]($valueTypeWParams* o) {
		o->${name} = value.asType<${cppType}>();
		return value;
	});
}');
		}
	}

	/**
		Generate code to call function given its data.
	**/
	function makeCallExpr(f: ClassFuncData, el: Array<TypedExpr>): Null<Array<String>> {
		if(type == null) return null;
		if(f.isStatic) return null;

		final isInlineExtern = (f.field.isExtern || f.field.hasMeta(":runtime")) && f.field.kind.equals(FMethod(MethInline));
		if(isInlineExtern && f.expr != null) {
			XComp.setThisOverride(genTypedExpr(TIdent("o"), type));
			final cpp = ['auto result = [o, args] ${Main.compileExpression(f.expr)};', "result()"];
			XComp.clearThisOverride();

			return cpp;
		} else {
			final field = f.field;
			final thisExpr = genTypedExpr(TConst(TThis), type);
			final exprDef = switch(type) {
				case TInst(clsRef, params): TField(thisExpr, FInstance(clsRef, params, { get: () -> field, toString: () -> "" }));
				case _: throw "Unsupported";
			}
			final expr = genTypedExpr(exprDef, field.type);
			final t = genTypedExpr(TCall(expr, el), f.ret);
			
			XComp.setThisOverride(genTypedExpr(TIdent("o"), TAbstract(Main.getPtrType(), [type])));
			final cpp = Main.compileExpression(t);
			XComp.clearThisOverride();

			return cpp != null ? [cpp] : null;
		}
	}

	/**
		Add a function.
	**/
	public function addFunc(v: ClassFuncData, cppArgs: Array<String>, name: String) {
		if(v.field.name == "new") return;

		final hasRet = !v.ret.isVoid();
		final args = [];
		final typedArgs = [];
		//final exprArgs = [];
		for(i in 0...cppArgs.length) {
			final a = 'args[${i}].asType<${cppArgs[i]}>()';
			args.push(a);
			typedArgs.push(genTypedExpr(TIdent(a), v.args[i].type));
			//exprArgs.push(macro untyped __cpp__($v{a}));
		}

		var mmt = UnsafePtr;
		if(isExternInline(f) && f.field.hasMeta(Meta.RequireMemoryManagement)) {
			final ident = f.field.meta.extractIdentifierFromFirstMeta(Meta.RequireMemoryManagement, 0);
			switch(ident) {
				case "UnsafePtr":
					mmt = UnsafePtr;
				case "SharedPtr":
					mmt = SharedPtr;
				case _:
					f.field.meta.getFirstPosition(Meta.RequireMemoryManagement)?.makeError(UnsupportedRequireMMT);
			}
		}

		final cpp = makeCallExpr(f, typedArgs, mmt);
		if(cpp != null && cpp.length > 0) {
			final end = cpp[cpp.length - 1];
			final prefixCode = (cpp.length > 1 ? (cpp.slice(0, -1).join("\n") + "\n") : "");
			final content = prefixCode + if(hasRet) {
				'return makeDynamic($end);';
			} else {
				'$end;\nreturn Dynamic();';
			}

			final isPtr = mmt == UnsafePtr;
			final dynFuncName = isPtr ? "makeFunc" : "makeFuncShared";
			final cppType = isPtr ? '$valueTypeWParams*' : 'std::shared_ptr<$valueTypeWParams>';

			getProps.push('if(name == "${name}") {
	return Dynamic::$dynFuncName<$valueTypeWParams>(d, []($cppType o, std::deque<Dynamic> args) {
${content.tab(2)}
	});
}');
		}
		
	}

	/**
		Generate the Dynamic wrapper class.
	**/
	public function getDynamicContent() {
		if(classType == null) {
			throw "Impossible";
		}

		final getArgs = getProps.length > 0 ? "Dynamic& d, std::string name" : "Dynamic&, std::string";
		final setArgs = setProps.length > 0 ? "Dynamic& d, std::string name, Dynamic value" : "Dynamic&, std::string, Dynamic";

		final hasTypeParams = classType.params.length > 0;

		final prefix = if(hasTypeParams) {
			final blankTemplateClass = 'template<typename T> class $dynamicName;';
			final dynamicTemplate = 'template<${classType.params.map(p -> "typename " + p.name).join(", ")}>';
			'\n$blankTemplateClass\n\n$dynamicTemplate';
		} else {
			"";
		}

		final name = if(hasTypeParams) {
			'$dynamicName<$valueTypeWParams>';
		} else {
			dynamicName;
		}

		return '
namespace haxe {
$prefix
class ${name} {
public:
	static Dynamic getProp(${getArgs}) {${getProps.length > 0 ? ("\n" + getProps.join(" else ").tab(2)) : ""}
		return Dynamic();
	}

	static Dynamic setProp(${setArgs}) {${setProps.length > 0 ? ("\n" + setProps.join(" else ").tab(2)) : ""}
		return Dynamic();
	}
};

}';
	}

	/**
		Generate the `dynamic/Dynamic.h` file.
	**/
	public function dynamicTypeContent() {
		final includes = ["any", "deque", "functional", "memory", "optional", "string", "typeindex"];
		for(i in includes) {
			IComp.addInclude(i, true, true);
		}

		return "namespace haxe {

[[noreturn]]
void makeError(const char* msg);

// Forward declare just in case
template<typename T> struct _class;

// The different types of Dynamic values
enum DynamicType {
	Empty, Null, Function, Value, Pointer, Reference, UniquePtr, SharedPtr
};

// ---

// A helper class for extracting certain info from types
template<typename T>
struct _mm_type { using inner = T; constexpr static DynamicType type = Value; };

template<typename T>
struct _mm_type<T*> { using inner = T; constexpr static DynamicType type = Pointer; };

template<typename T>
struct _mm_type<std::shared_ptr<T>> { using inner = T; constexpr static DynamicType type = SharedPtr; };

// Unwrap references as they're incompatible with `std::any`.
template<typename T>
struct _mm_type<T&> { using inner = typename _mm_type<T>::inner; constexpr static DynamicType type = _mm_type<T>::type; };

// Due to their nature, `unique_ptr` cannot be stored in `Dynamic`.
// But let's track anyway for error reporting.
template<typename T>
struct _mm_type<std::unique_ptr<T>> { using inner = T; constexpr static DynamicType type = UniquePtr; };

// ---

// Use within the Dynamic to extract a pointer type
// from a Dynamic into a local variable `p`.
#define DYN_GETPTR(name, t) \\
	std::optional<t> v;\\
	if(name._dynType == Value) v = std::any_cast<t>(name._anyObj);\\
	else v = std::nullopt;\\
	t* p = nullptr;\\
	if(name._dynType == Value) {\\
		p = v.operator->();\\
	} else {\\
		p = name.asType<t*>();\\
	}

// ---

// The class used for Haxe's `Dynamic` type.
class Dynamic {
public:
	DynamicType _dynType;

	long id;
	static long getId() { static long maxId = 0; return maxId++; }

	std::optional<std::type_index> _innerType;
	std::any _anyObj;

	std::function<Dynamic(std::deque<Dynamic>)> func;
	std::function<Dynamic(Dynamic&,std::string)> getFunc;
	std::function<Dynamic(Dynamic&,std::string,Dynamic)> setFunc;

	Dynamic(): id(getId()) {
		_dynType = Empty;
	}

	template<typename T>
	Dynamic(T obj): id(getId()) {
		using inner = typename _mm_type<T>::inner;

		if constexpr(std::is_integral_v<T>) {
			long l = static_cast<long>(obj);
			_anyObj = l;
			_innerType = std::type_index(typeid(long));
			_dynType = Value;
		} else if constexpr(std::is_floating_point_v<T>) {
			long d = static_cast<double>(obj);
			_anyObj = d;
			_innerType = std::type_index(typeid(double));
			_dynType = Value;
		} else {
			_anyObj = obj;
			_innerType = std::type_index(typeid(inner));
			_dynType = _mm_type<T>::type;
		}

		// We cannot copy or move `std::unique_ptr`s
		if(_dynType == UniquePtr) {
			makeError(\"Cannot assign std::unique_ptr to haxe::Dynamic\");
		}

		// Supply properties if possible.
		// Otherwise, Dynamic works as a simple `std::any` wrapper.
		if constexpr(haxe::_class<inner>::data.has_dyn) {
			using Dyn = typename haxe::_class<inner>::Dyn;
			getFunc = [](Dynamic& d, std::string name) { return Dyn::getProp(d, name); };
			setFunc = [](Dynamic& d, std::string name, Dynamic value) { return Dyn::setProp(d, name, value); };
		}
	}

	static Dynamic null() {
		Dynamic result;
		result._dynType = Null;
		return result;
	}

	bool isNull() const {
		return _dynType == Null;
	}

	bool isEmpty() const {
		return _dynType == Empty;
	}

	bool isFunction() const {
		return _dynType == Function;
	}

	template<typename T>
	bool isType() const {
		if(isEmpty()) return false;
		if(!_innerType) return false;
		return _innerType.value() == std::type_index(typeid(T));
	}

	bool isInt() const {
		return isType<long>();
	}

	bool isFloat() const {
		return isType<double>();
	}

	bool isNumber() const {
		return isInt() || isFloat();
	}

	bool isString() const {
		return isType<std::string>();
	}

	template<typename T>
	T asType() const {
		using In = typename _mm_type<T>::inner;

		// Check number types
		if constexpr(std::is_integral_v<T>) {
			return static_cast<T>(std::any_cast<long>(_anyObj));
		} else if constexpr(std::is_floating_point_v<T>) {
			if(isInt()) {
				return static_cast<T>(std::any_cast<long>(_anyObj));
			} else if(isFloat()) {
				return static_cast<T>(std::any_cast<double>(_anyObj));
			}
		}
		if constexpr(_mm_type<T>::type == Value) {
			switch(_dynType) {
				case Value: return std::any_cast<T>(_anyObj);
				case Pointer: return *std::any_cast<T*>(_anyObj);

				// Cannot store references in `std::any`.
				// case Reference: return std::any_cast<T&>(_anyObj);

				// Cannot store `unique_ptr`.
				// case UniquePtr: return *std::any_cast<std::unique_ptr<T>>(_anyObj);

				case SharedPtr: return *std::any_cast<std::shared_ptr<T>>(_anyObj);
				default: break;
			}
		} else if constexpr(_mm_type<T>::type == Pointer) {
			switch(_dynType) {
				case Pointer: return std::any_cast<In*>(_anyObj);

				// Cannot store `unique_ptr`.
				// case 3: return std::any_cast<std::unique_ptr<In>>(_anyObj).get();

				case SharedPtr: return std::any_cast<std::shared_ptr<In>>(_anyObj).get();
				default: break;
			}
		} else if constexpr(_mm_type<T>::type == Reference) {
			makeError(\"Cannot cast Dynamic to reference (&)\");
		} else if constexpr(_mm_type<T>::type == UniquePtr) {
			makeError(\"Cannot cast Dynamic to std::unique_ptr\");
		} else if constexpr(_mm_type<T>::type == SharedPtr) {
			if(_dynType == SharedPtr) {
				return std::any_cast<std::shared_ptr<In>>(_anyObj);
			}
		}
		
		makeError(\"Bad Dynamic cast\");
	}

	std::string toString() {
		if(getFunc != nullptr) {
			Dynamic toString = getFunc(*this, \"toString\");
			if(toString.isFunction()) {
				Dynamic result = toString();
				if(result.isString()) {
					return result.asType<std::string>();
				}
			}
		}
		switch(_dynType) {
			case Empty: return std::string(\"Dynamic(Undefined)\");
			case Null: return std::string(\"Dynamic(null)\");
			case Function: return std::string(\"Dynamic(Function)\");
			default: break;
		}
		if(isInt()) {
			return std::to_string(asType<long>());
		} else if(isFloat()) {
			return std::to_string(asType<double>());
		}
		return std::string(\"Dynamic\");
	}

	Dynamic getPropSafe(std::string name) {
		if(getFunc != nullptr) {
			return getFunc(*this, name);
		}
		return Dynamic();
	}

	Dynamic setPropSafe(std::string name, Dynamic value) {
		if(setFunc != nullptr) {
			return setFunc(*this, name, value);
		}
		return Dynamic();
	}

	Dynamic getProp(std::string name) {
		Dynamic result = getPropSafe(name);
		if(!result.isEmpty()) return result;
		makeError(\"Property does not exist\");
	}

	Dynamic setProp(std::string name, Dynamic value) {
		Dynamic result = setPropSafe(name, value);
		if(!result.isEmpty()) return result;
		makeError(\"Property does not exist\");
	}

	// operators

	Dynamic operator()() {
		if(_dynType == Function) {
			return func({});
		}
		makeError(\"Cannot call this Dynamic\");
	}

	template<typename... Types>
	Dynamic operator()(Types... args) {
		std::deque<Dynamic> dynArgs = { args... };
		return operator()(dynArgs);
	}

	Dynamic operator()(std::deque<Dynamic> args) {
		if(_dynType == Function) {
			return func(args);
		}
		makeError(\"Cannot call this Dynamic\");
	}

	bool operator==(Dynamic const& other) const {
		if(_dynType != other._dynType) {
			return false;
		}

		if(isInt() && other.isInt()) {
			return asType<long>() == other.asType<long>();
		} else if(isNumber() && other.isNumber()) {
			return asType<double>() == other.asType<double>();
		}

		return id == other.id;
	}

	Dynamic operator[](int index) {
		if(getFunc != nullptr) {
			Dynamic arrayAccess = getFunc(*this, \"[]\");
			if(arrayAccess.isFunction()) {
				return arrayAccess(index);
			}
		}

		try {
			DYN_GETPTR((*this), std::deque<Dynamic>)
			if(p != nullptr) {
				return p->operator[](index);
			}
		} catch(...) {
		}
		return Dynamic();
	}

	// helpers

	template<typename T>
	static Dynamic unwrap(Dynamic& d, std::function<Dynamic(T*)> callback) {
		DYN_GETPTR(d, T)
		return callback(p);
	}

	template<typename T>
	static Dynamic makeFunc(Dynamic& d, std::function<Dynamic(T*, std::deque<Dynamic>)> callback) {
		Dynamic result;
		result._dynType = Function;
		result.func = [callback, d](std::deque<Dynamic> args) {
			std::optional<T> v;
			if(d._dynType == Value) v = std::any_cast<T>(d._anyObj);
			else v = std::nullopt;
			T* p = nullptr;
			if(d._dynType == Value) {
				p = v.operator->();
			} else {
				p = d.asType<T*>();
			}
			return callback(p, args);
		};
		return result;
	}

	template<typename T>
	static Dynamic makeFuncShared(Dynamic& d, std::function<Dynamic(std::shared_ptr<T>, std::deque<Dynamic>)> callback) {
		Dynamic result;
		result._dynType = Function;
		result.func = [callback, d](std::deque<Dynamic> args) {
			std::shared_ptr<T> p = nullptr;
			if(d._dynType == Value || d._dynType == Pointer) {
				p = std::make_shared<T>(d.asType<T>());
			} else if(d._dynType == SharedPtr) {
				p = std::any_cast<std::shared_ptr<T>>(d._anyObj);
			} else {
				makeError(\"Cannot use unique pointer for this property\");
			}
			return callback(p, args);
		};
		return result;
	}
};

template<typename T>
Dynamic makeDynamic(T obj) {
	return Dynamic(obj);
}

}";
	}
}

#end
