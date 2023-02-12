// =======================================================
// * GCFCompiler_Includes
//
// This sub-compiler is used to handle compiling of all
// #include statements.
//
// - First call "resetAndInitIncludes" to reset the state.
//
// - Next call "addInclude" while compiling to accumulate
//   desired includes.
//
// - Finally call "compileIncludes" to received the
//   compiled list of #include statements.
// =======================================================

package gcfcompiler.subcompilers;

#if (macro || gcf_runtime)

import haxe.macro.Type;

using reflaxe.helpers.DynamicHelper;
using reflaxe.helpers.ModuleTypeHelper;
using reflaxe.helpers.NameMetaHelper;
using reflaxe.helpers.NullableMetaAccessHelper;
using reflaxe.helpers.TypeHelper;

using gcfcompiler.helpers.GCFError;
using gcfcompiler.helpers.GCFMeta;
using gcfcompiler.helpers.GCFSort;

@:allow(gcfcompiler.GCFCompiler)
@:access(gcfcompiler.GCFCompiler)
class GCFCompiler_Includes extends GCFSubCompiler {
	// ----------------------------
	// Store list of includes.
	var headerIncludes: Array<String>;
	var cppIncludes: Array<String>;

	// ----------------------------
	// List of headers to ignore.
	var ignoreIncludes: Array<String>;

	// ----------------------------
	// If the anonymous structure header was included
	// somewhere in the output, this will be true.
	public var anonHeaderRequired(default, null): Bool = false;

	// ----------------------------
	// Clears include arrays and fills
	// them with the current type usage data.
	function resetAndInitIncludes(onlyHeader: Bool = false, ignoreList: Null<Array<String>> = null) {
		// Reset include lists
		headerIncludes = [];
		cppIncludes = [];
		ignoreIncludes = ignoreList != null ? ignoreList : [];

		final current = Main.getCurrentModule();
		if(current == null) return;

		// @:headerInclude and @:cppInclude
		final meta = current.getCommonData().meta;
		for(params in meta.extractParamsFromAllMeta(":headerInclude")) {
			addMetaEntryInc(params, true);
		}
		for(params in meta.extractParamsFromAllMeta(":cppInclude")) {
			addMetaEntryInc(params, false);
		}

		// "getTypeUsage" returns information on all
		// the types used by this ClassType.
		// Let's add them to our includes.
		final typeUsage = Main.getTypeUsage();
		for(level => usedTypes in typeUsage) {
			if(level >= StaticAccess) {
				final header = onlyHeader || level >= FunctionDeclaration;
				for(ut in usedTypes) {
					switch(ut) {
						case EModuleType(mt): {
							if(!mt.isAbstract()) {
								addIncludeFromModuleType(mt, header);
							}
						}
						case EType(t): {
							addIncludeFromType(t, header);
						}
					}
				}
			}
		}
	}

	// ----------------------------
	// Prevents the path provided here from
	// being included until the next reset.
	function addIgnore(includePath: String) {
		ignoreIncludes.push(includePath);
	}

	// ----------------------------
	// Add include while compiling code.
	function addInclude(include: String, header: Bool, triangleBrackets: Bool = false) {
		function add(arr: Array<String>, inc: String) {
			if(!arr.contains(inc)) {
				arr.push(inc);
			}
		}

		if(ignoreIncludes.contains(include)) {
			return;
		}

		final includeStr = if(!triangleBrackets) { "\"" + include + "\""; } else { "<" + include + ">"; }
		add(header ? headerIncludes : cppIncludes, includeStr);
	}

	// ----------------------------
	// Returns true if the provided ModuleType should
	// not generate an include when used.
	function isNoIncludeType(mt: ModuleType): Bool {
		return switch(mt) {
			case TAbstract(_): true;
			case TClassDecl(clsRef): {
				switch(clsRef.get().kind) {
					case KTypeParameter(_): true;
					case _: false;
				}
			}
			case _: false;
		}
	}

	// ----------------------------
	// Add include based on the provided Type.
	function addIncludeFromType(t: Type, header: Bool) {
		switch(t.unwrapNullTypeOrSelf()) {
			case TFun(_, _): {
				addFunctionTypeInclude(header);
			}
			case TAnonymous(_): {
				addAnonTypeInclude(header);
			}
			case _: {
				final mt = t.toModuleType();
				if(mt != null) {
					addIncludeFromModuleType(mt, header);
				}
			}
		}
	}

	function addFunctionTypeInclude(header: Bool) {
		IComp.addInclude("functional", header, true);
	}

	function addAnonTypeInclude(header: Bool) {
		anonHeaderRequired = true;
		IComp.addInclude(GCFCompiler.AnonStructHeaderFile + GCFCompiler.HeaderExt, header);
	}

	function addIncludeFromModuleType(mt: Null<ModuleType>, header: Bool) {
		if(isNoIncludeType(mt)) return;

		if(mt != null) {
			// Add our "main" include if @:noInclude is absent.
			// First look for and use @:include, otherwise, use default header include.
			final cd = mt.getCommonData();
			final main = Main.getCurrentModule();
			if(main != null && main.getUniqueId() == mt.getUniqueId()) return;
			if(addIncludeFromMetaAccess(cd.meta, header)) {
				if(!cd.isExtern) {
					addInclude(Main.getFileNameFromModuleData(cd) + GCFCompiler.HeaderExt, header, false);
				}
			}

			final mmType = cd.getMemoryManagementType();
			if(mmType == UniquePtr) {
				addInclude(GCFCompiler.SharedPtrInclude[0], header, GCFCompiler.SharedPtrInclude[1]);
			} else if(mmType == SharedPtr) {
				addInclude(GCFCompiler.UniquePtrInclude[0], header, GCFCompiler.UniquePtrInclude[1]);
			}
		}
	}

	// Add include from extracted metadata entry parameters.
	// Returns true if successful.
	function addMetaEntryInc(params: Array<Dynamic>, header: Bool): Bool {
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

		if(!metaAccess.maybeHas(":noInclude")) {
			final includeOverride = metaAccess.extractParamsFromFirstMeta(":include");
			if(!addMetaEntryInc(includeOverride, header)) {
				defaultOverrided = true;
			}
		}
		
		// Additional header files can be added using @:addInclude.
		final additionalIncludes = metaAccess.extractParamsFromAllMeta(":addInclude");
		for(inc in additionalIncludes) {
			addMetaEntryInc(inc, header);
		}

		return defaultOverrided;
	}

	function compileHeaderIncludes(): String {
		return compileIncludes(headerIncludes);
	}

	function compileCppIncludes(): String {
		return compileIncludes(cppIncludes);
	}

	// Take one of the include arrays and
	// compile/format for the output.
	function compileIncludes(includeArr: Array<String>): String {
		return if(includeArr.length > 0) {
			includeArr.sortedAlphabetically().map(i -> "#include " + i).join("\n");
		} else {
			"";
		}
	}
}

#end