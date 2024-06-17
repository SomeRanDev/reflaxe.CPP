// =======================================================
// * Includes
//
// This sub-compiler is used to handle compiling of all
// #include statements.
//
// - First call "resetAndInitIncludes" to reset the state.
//
// - Next call "addInclude" while compiling to accumulate
//   desired includes.
//
// - Finally call "compileIncludes" to receive the
//   compiled list of #include statements.
// =======================================================

package cxxcompiler.subcompilers;

#if (macro || cxx_runtime)

import reflaxe.helpers.Context; // Use like haxe.macro.Context
import haxe.macro.Expr;
import haxe.macro.Type;

import cxxcompiler.config.Meta;

using StringTools;

using reflaxe.helpers.DynamicHelper;
using reflaxe.helpers.ModuleTypeHelper;
using reflaxe.helpers.NameMetaHelper;
using reflaxe.helpers.NullableMetaAccessHelper;
using reflaxe.helpers.NullHelper;
using reflaxe.helpers.TypeHelper;

using cxxcompiler.helpers.Error;
using cxxcompiler.helpers.MetaHelper;
using cxxcompiler.helpers.Sort;

enum abstract ExtraFlag(String) from String to String {
	// An instance of converting "this" to a shared_ptr was encountered.
	// Ensures the class declaration extends from std::enable_shared_from_this.
	var SharedFromThis = "SharedFromThis";
}

@:allow(cxxcompiler.Compiler)
@:access(cxxcompiler.Compiler)
class Includes extends SubCompiler {
	// ----------------------------
	// C++ STD Includes
	public static var StringInclude = "string";
	public static var ArrayInclude = "deque";
	public static var AnyInclude = "any";

	// ----------------------------
	// Store list of includes.
	var headerIncludes: Array<String> = [];
	var cppIncludes: Array<String> = [];
	var lazyIncludes: Array<() -> Void> = [];

	// ----------------------------
	// Store list of "using namespace" uses.
	//
	// Using "using namespace" in header files is bad practice,
	// so only usings for cpp files are tracked.
	var cppUsings: Array<String> = [];

	// ----------------------------
	var forwardDeclares: Array<String> = [];

	// ----------------------------
	// A list of arbitrary flags that may be used.
	//
	// Helpful for signaling to the declaration to compile a certain way
	// based on an expression or pattern detected.
	//
	// Cleared at the start of module compilation like includes.
	var extraFlags: Map<String, Bool> = [];

	// ----------------------------
	// List of headers to ignore.
	var ignoreIncludes: Array<String> = [];

	// ----------------------------
	// If the Haxe utility header was included
	// somewhere in the output, this will be true.
	public var haxeUtilHeaderRequired(default, null): Bool = false;

	// ----------------------------
	// If the anonymous structure header was included
	// somewhere in the output, this will be true.
	public var anonHeaderRequired(default, null): Bool = false;

	// ----------------------------
	// If the anonymous structure utility header was included
	// somewhere in the output, this will be true.
	public var anonUtilHeaderRequired(default, null): Bool = false;

	// ----------------------------
	// If the type utility header was included
	// somewhere in the output, this will be true.
	public var typeUtilHeaderRequired(default, null): Bool = false;

	// ----------------------------
	// Clears include arrays and fills
	// them with the current type usage data.
	function resetAndInitIncludes(onlyHeader: Bool = false, ignoreList: Null<Array<String>> = null) {
		// Reset include lists
		headerIncludes = [];
		cppIncludes = [];
		lazyIncludes = [];
		ignoreIncludes = ignoreList ?? [];

		// Reset using list
		cppUsings = [];

		// Reset forward declares
		forwardDeclares = [];

		// Reset extra flags
		extraFlags = [];

		// If not compiling a module, stop here.
		final current = Main.getCurrentModule();
		if(current == null) return;

		// @:headerInclude and @:cppInclude
		final meta = current.getCommonData().meta;
		for(params in meta.extractParamsFromAllMeta(Meta.HeaderInclude)) {
			addMetaEntryInc(params, true);
		}
		for(params in meta.extractParamsFromAllMeta(Meta.CppInclude)) {
			addMetaEntryInc(params, false);
		}
	}

	// ----------------------------
	// Prevents the path provided here from
	// being included until the next reset.
	function addIgnore(includePath: String) {
		ignoreIncludes.push(includePath);
	}

	// ----------------------------
	// Add a callback to be called right before
	// the includes are compiled.
	function addLazyInclude(callback: () -> Void) {
		lazyIncludes.push(callback);
	}

	// ----------------------------
	// Add include while compiling code.
	public function addInclude(include: String, header: Bool, triangleBrackets: Bool = false) {
		function add(arr: Array<String>, inc: String) {
			if(!arr.contains(inc)) {
				arr.push(inc);
			}
		}

		if(ignoreIncludes.contains(include)) {
			return;
		}

		final includeStr = wrapInclude(include, triangleBrackets);
		add(header ? headerIncludes : cppIncludes, includeStr);
	}

	function wrapInclude(include: String, triangleBrackets: Bool) {
		return if(!triangleBrackets) { "\"" + include + "\""; } else { "<" + include + ">"; };
	}

	// ----------------------------
	// Add "using namespace" while compiling code.
	public function addUsingNamespace(ns: String) {
		if(!cppUsings.contains(ns)) {
			cppUsings.push(ns);
		}
	}

	// ----------------------------
	// Add forward declaration for class.
	public function addForwardDeclare(mt: ModuleType) {
		switch(mt) {
			case TAbstract(_): throw "Cannot forward declare abstract";
			case _:
		}

		final baseType = mt.getCommonData();
		if(baseType.isExtern) throw "Cannot forward declare extern class";

		final pieces = [];
		final ns = Main.compileNamespaceStart(baseType);
		pieces.push(ns.length > 0 ? (ns + "\t") : "");
		if(baseType.params.length > 0) {
			pieces.push("template<" + baseType.params.map(p -> "typename").join(", ") + "> ");
		}
		pieces.push("class " + baseType.name + ";");
		pieces.push(Main.compileNamespaceEnd(baseType));

		final cpp = pieces.join("");
		if(!forwardDeclares.contains(cpp)) {
			forwardDeclares.push(cpp);
		}
	}

	// ----------------------------
	// Returns true if the provided ModuleType should
	// not generate an include when used.
	function isNoIncludeType(mt: ModuleType, unwrapAbstract: Bool = true): Bool {
		final result = switch(mt) {
			case TAbstract(absRef): {
				if(unwrapAbstract) {
					final newMt = Context.followWithAbstracts(TypeHelper.fromModuleType(mt)).toModuleType();
					if(newMt != null) {
						isNoIncludeType(newMt, false);
					} else {
						true;
					}
				} else {
					true;
				}
			}
			case TClassDecl(clsRef): {
				switch(clsRef.get().kind) {
					case KTypeParameter(_): true;
					case _: false;
				}
			}
			case _: false;
		}

		// If this module is set to be ignored,
		// check if there is include meta.
		if(result) {
			final cd = mt.getCommonData();
			if(cd.hasMeta(Meta.Include) || cd.hasMeta(Meta.AddInclude) || cd.hasMeta(Meta.YesInclude)) {
				return false;
			}
		}

		return result;
	}

	// ----------------------------
	// Add include based on the provided Type.
	public function addIncludeFromType(t: Type, header: Bool) {
		switch(t.unwrapNullTypeOrSelf()) {
			case TFun(_, _): {
				addFunctionTypeInclude(header);
			}
			case TAnonymous(_): {
				addAnonTypeInclude(header);
			}
			case TType(_.get() => defType, [inner]) if((defType.name == "Class" || defType.name == "Enum") && defType.pack.length == 0): {
				addIncludeFromType(inner, header);
			}
			case TType(_.get() => defType, []) if((defType.name.startsWith("Class<") || defType.name.startsWith("Enum<")) && defType.pack.length == 0): {
				return; // Ignore weird "Class<T>" and "Enum<T>" typedefs?
			}
			case ut: {
				final mt = t.toModuleType();
				if(mt != null) {
					addIncludeFromModuleType(mt, header);

					// Include `T` for `abstract Something<T>(T)`
					// TODO: is there better place to put this?
					if(!isNoIncludeType(mt)) {
						addIncludeFromAbstractTypeParam(ut, header);
					}
				}

				// This SHOULD(?) also handle cxx.Ptr<TYPE> and other mmts.
				// If this is done outside of a header, it causes include looping??
				if(!header) {
					final params = t.getParams();
					if(params != null) {
						for(p in params) {
							final mt = p.toModuleType();
							switch(mt) {
								case TClassDecl(cRef): {
									switch(cRef.get().kind) {
										case KExpr(_): continue;
										case _:
									}
								}
								case _:
							}
							addIncludeFromType(p, header);
						}
					}
				}
			}
		}
	}

	function addIncludeFromAbstractTypeParam(t: Type, header: Bool) {
		switch(t) {
			case TAbstract(_.get() => absType, _) if(absType.type.isTypeParameter()): {
				final ut = t.getUnderlyingType().trustMe(/* Cannot be `null` since guaranteed to be `TAbstract` */);
				addIncludeFromType(ut, header);
			}
			case _:
		}
	}

	function addFunctionTypeInclude(header: Bool) {
		IComp.addInclude("functional", header, true);
	}

	function addHaxeUtilHeader(header: Bool) {
		haxeUtilHeaderRequired = true;
		IComp.addInclude(Compiler.HaxeUtilsHeaderFile + Compiler.HeaderExt, header);
	}

	function addAnonTypeInclude(header: Bool) {
		anonHeaderRequired = true;
		IComp.addInclude(Compiler.AnonStructHeaderFile + Compiler.HeaderExt, header);
	}

	function addAnonUtilHeader(header: Bool) {
		anonUtilHeaderRequired = true;
		IComp.addInclude(Compiler.AnonUtilsHeaderFile + Compiler.HeaderExt, header);
	}

	function addTypeUtilHeader(header: Bool) {
		typeUtilHeaderRequired = true;
		IComp.addInclude(Compiler.TypeUtilsHeaderFile + Compiler.HeaderExt, header);
	}

	// ----------------------------
	function addNativeStackTrace(blamePosition: Position) {
		final t = Context.getType("haxe.NativeStackTrace");
		if(t != null) {
			Main.onTypeEncountered(t, XComp.compilingInHeader, blamePosition);
		}
		IComp.addInclude("haxe_NativeStackTrace.h", XComp.compilingInHeader);
	}

	// ----------------------------
	// Used when compiling classes and enums to include
	// special includes generated by Reflaxe/C++.
	function handleSpecialIncludeMeta(m: MetaAccess, header: Bool = true) {
		final anonUtil = m.extractParamsFromFirstMeta(Meta.IncludeHaxeUtils);
		if(anonUtil != null) {
			IComp.addHaxeUtilHeader(anonUtil.length > 0 ? anonUtil[0] : header);
		}

		final anonUtil = m.extractParamsFromFirstMeta(Meta.IncludeAnonUtils);
		if(anonUtil != null) {
			IComp.addAnonUtilHeader(anonUtil.length > 0 ? anonUtil[0] : header);
		}

		final typeUtil = m.extractParamsFromFirstMeta(Meta.IncludeTypeUtils);
		if(typeUtil != null) {
			IComp.addTypeUtilHeader(typeUtil.length > 0 ? typeUtil[0] : header);
		}
	}

	function addIncludeFromModuleType(mt: Null<ModuleType>, header: Bool) {
		if(mt != null) {
			if(isNoIncludeType(mt)) return;

			// Add our "main" include if @:noInclude is absent.
			// First look for and use @:include, otherwise, use default header include.
			final cd = mt.getCommonData();
			final isExtern = cd.isExtern || cd.hasMeta(":extern");
			final main = Main.getCurrentModule();
			if(main != null && main.getUniqueId() == mt.getUniqueId()) return;
			if(addIncludeFromMetaAccess(cd.meta, header)) {
				switch(mt) {
					case TAbstract(absRef) if(!cd.hasMeta(Meta.YesInclude)): {
						addIncludeFromType(absRef.get().type, header);
						return;
					}
					case _:
				}
				if(!isExtern) {
					addInclude(Compiler.getFileNameFromModuleData(cd) + Compiler.HeaderExt, header, false);
				}
			}
			if(isExtern) {
				switch(mt) {
					case TClassDecl(_.get() => cls) if(cls.hasMeta(Meta.DynamicCompatible)): {
						final dynFilename = Classes.getReflectionFileName(cls);
						addLazyInclude(function() {
							if(DComp.enabled) {
								addInclude(dynFilename, false, false);
							}
						});
					}
					case _:
				}
			}

			includeMMType(cd.getMemoryManagementType(), header);
		}
	}

	public function includeMMType(mmType: MemoryManagementType, header: Bool) {
		if(mmType == UniquePtr) {
			addInclude(Compiler.SharedPtrInclude[0], header, Compiler.SharedPtrInclude[1]);
		} else if(mmType == SharedPtr) {
			addInclude(Compiler.UniquePtrInclude[0], header, Compiler.UniquePtrInclude[1]);
		}
	}

	// Add include from extracted metadata entry parameters.
	// Returns true if successful.
	function addMetaEntryInc(params: Null<Array<Dynamic>>, header: Bool): Bool {
		if(params != null && params.length > 0 && params[0].isString()) {
			addInclude(params[0], header, params[1] == true);
			return true;
		}
		return false;
	}

	// Adds includes introduced from MetaAccess.
	// Returns "true" if a default include was not added.
	function addIncludeFromMetaAccess(metaAccess: Null<MetaAccess>, header: Bool = false): Bool {
		if(metaAccess == null) return true;

		var defaultOverrided = false;

		if(!metaAccess.maybeHas(Meta.NoInclude)) {
			final includeOverride = metaAccess.extractParamsFromFirstMeta(Meta.Include);
			if(!addMetaEntryInc(includeOverride, header)) {
				defaultOverrided = true;
			}
		}
		
		// Additional header files can be added using @:addInclude.
		final additionalIncludes = metaAccess.extractParamsFromAllMeta(Meta.AddInclude);
		for(inc in additionalIncludes) {
			addMetaEntryInc(inc, header);
		}

		// Additional "using namespace" instances to use.
		final usingNamespaces = metaAccess.extractPrimtiveFromAllMeta(Meta.UsingNamespace, 0);
		for(useNs in usingNamespaces) {
			addUsingNamespace(useNs);
		}

		// Include special meta headers at call location if used on field.
		handleSpecialIncludeMeta(metaAccess, header);

		return defaultOverrided;
	}

	public function compileHeaderIncludes(): String {
		return compileIncludes(headerIncludes);
	}

	public function compileForwardDeclares(): String {
		var result = "";
		if(forwardDeclares.length > 0) {
			result += "\n\n";
			result += forwardDeclares.join("\n");
		}
		return result;
	}

	public function compileCppIncludes(): String {
		var result = compileIncludes(cppIncludes);
		if(cppUsings.length > 0) {
			if(result.length > 0) result += "\n\n";
			result += cppUsings.sortedAlphabetically().map(u -> "using namespace " + u + ";").join("\n");
		}
		return result;
	}

	// Take one of the include arrays and
	// compile/format for the output.
	function compileIncludes(includeArr: Array<String>): String {
		callAllLazyIncludes();
		return if(includeArr.length > 0) {
			includeArr.sorted(Sort.includeBracketOrder).map(i -> "#include " + i).join("\n");
		} else {
			"";
		}
	}

	function callAllLazyIncludes() {
		if(lazyIncludes.length > 0) {
			for(callback in lazyIncludes) {
				callback();
			}
			lazyIncludes = [];
		}
	}

	// Given the filename and priority, this function formats
	// the extra file section containing include statements to
	// ensure they are organized and contain no repeats.
	function appendIncludesToExtraFileWithoutRepeats(filename: String, newIncludes: String, priority: Int) {
		final isNotEmpty = (s) -> StringTools.trim(s).length > 0;
		if(!isNotEmpty(newIncludes)) return;

		final existing = Main.getExtraFileContent(filename, priority);
		if(!isNotEmpty(existing)) {
			Main.appendToExtraFile(filename, newIncludes, priority);
		} else {
			final existingIncludes = existing.split("\n").filter(isNotEmpty);
			final includes = newIncludes.split("\n").filter(isNotEmpty).filter(i -> !existingIncludes.contains(i));
			final combined = existingIncludes.concat(includes).sorted(Sort.includeBracketOrder);
			Main.replaceInExtraFile(filename, combined.join("\n"), priority);
		}
	}

	// Make note of a special case.
	public function setExtraFlag(flag: String, value: Bool = true) {
		extraFlags.set(flag, value);
	}

	// Get whether a flag was enabled.
	public function isExtraFlagOn(flag: String): Bool {
		return extraFlags.exists(flag) && extraFlags.get(flag);
	}
}

#end