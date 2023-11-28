// =======================================================
// * Enums
//
// This sub-compiler is used to handle compiling of all
// enum delcarations
// =======================================================

package cxxcompiler.subcompilers;

#if (macro || cxx_runtime)

import reflaxe.helpers.Context;
import haxe.macro.Type;

import reflaxe.BaseCompiler;
import reflaxe.data.EnumOptionData;
import reflaxe.helpers.NameMetaHelper;

using reflaxe.helpers.BaseTypeHelper;
using reflaxe.helpers.NullHelper;
using reflaxe.helpers.PositionHelper;
using reflaxe.helpers.SyntaxHelper;
using reflaxe.helpers.TypeHelper;

import cxxcompiler.other.DependencyTracker;

using cxxcompiler.helpers.Error;
using cxxcompiler.helpers.MetaHelper;
using cxxcompiler.helpers.Sort;

@:allow(cxxcompiler.Compiler)
@:access(cxxcompiler.Compiler)
@:access(cxxcompiler.subcompilers.Expressions)
@:access(cxxcompiler.subcompilers.Includes)
@:access(cxxcompiler.subcompilers.Types)
class Enums extends SubCompiler {
	static var dynToStringType: Null<Type>;
	static function getDynToStringType(): Type {
		if(dynToStringType == null) {
			dynToStringType = Context.getType("cxx.DynamicToString");
		}
		return dynToStringType;
	}

	/**
		The current `DependencyTracker` for the class being compiled.
	**/
	var dep: Null<DependencyTracker> = null;

	public function compileEnum(enumType: EnumType, options: Array<EnumOptionData>): Null<String> {
		if(enumType.isReflaxeExtern()) {
			return null;
		}

		final filename = Compiler.getFileNameFromModuleData(enumType);
		final headerFilename = filename + Compiler.HeaderExt;

		// --------------------
		// Init includes (always headers = true)
		IComp.resetAndInitIncludes(true, [headerFilename]);
		IComp.handleSpecialIncludeMeta(enumType.meta);

		// --------------------
		// Ensure no self-reference if value type.
		final isValueType = enumType.getMemoryManagementType() == Value;
		if(isValueType) {
			for(o in options) {
				for(a in o.args) {
					if(Main.isSameAsCurrentModule(a.type)) {
						o.field.pos.makeError(ValueSelfRef);
					}
				}
			}
		}

		final enumTypeRef = switch(Main.getCurrentModule()) {
			case TEnumDecl(e): e;
			case _: throw "Impossible";
		}

		// --------------------
		// Dependency tracker
		dep = DependencyTracker.make(TEnumDecl(enumTypeRef), filename);
		if(dep != null) Main.setCurrentDep(dep);

		// --------------------
		// Generate entire class declaration in "declaration"
		final enumName = TComp.compileEnumName(enumTypeRef, enumType.pos, null, false, true);
		var declaration = "class " + enumName + " {\npublic:\n";
		declaration += "\tint index;\n\n";

		// --------------------
		// Iterate through options

		// Accumulate different declarations while iterating.
		final constructors = [];
		final enumArgGetters = [];
		final unionStructs = [];
		final structs = [];
		final toStringCases = [];
		#if cxx_disable_haxe_std
		final destructorCases = [];
		#end

		// Counts arguments added to the variant.
		var variantIndex = 0;

		// Sort the enum fields in index order to ensure
		// sequential indexes are consistent + cleaner output.
		final sortedOptions = options.sorted((a, b) -> {
			return if(a.field.index < b.field.index) -1;
			else if(a.field.index > b.field.index) 1;
			else 0;
		});

		// Generate, #include, and encounter `cxx.DynamicToString` if necessary.
		final dynToStringType = getDynToStringType();
		var dynToStringCpp = null;
		function getDynToStringCpp() {
			if(dynToStringCpp == null) {
				dynToStringCpp = TComp.compileType(dynToStringType, PositionHelper.unknownPos(), true);
				Main.onTypeEncountered(dynToStringType, true, enumType.pos);
				IComp.addIncludeFromType(dynToStringType, true);
			}
			return dynToStringCpp;
		}

		// Iterate
		for(o in sortedOptions) {
			var index = o.field.index;
			final hasArgs = o.args.length > 0;
			final args = o.args.map(opt -> [TComp.compileType(opt.type, o.field.pos), opt.name]);

			for(a in o.args) {
				Main.onTypeEncountered(a.type, true, o.field.pos);
				if(dep != null) dep.assertCanUseInHeader(a.type, o.field.pos);
			}

			final structName = "d" + o.name + "Impl";
			if(hasArgs) {
				structs.push({ name: structName, index: index });
			}

			// Generate static function "constructors"
			{
				var enumType = o.field.type.getTFunReturn();
				if(enumType == null) {
					enumType = o.field.type;
				}

				final funcArgs = [];
				for(i in 0...args.length) {
					funcArgs.push(args[i][0] + " _" + args[i][1] + (o.args[i].opt ? " = " + Compiler.OptionalNullCpp : ""));
				}
				var construct = "";
				construct += "static " + TComp.compileType(enumType, o.field.pos) + " " + o.name + "(" + funcArgs.join(", ") + ") {\n";
				construct += "\t" + enumName + " result;\n";
				construct += "\tresult.index = " + index + ";\n";
				if(hasArgs) {
					construct += "\tresult.data" + (
						#if cxx_disable_haxe_std
						"._" + index
						#else
						""
						#end
					) + " = " + structName + "{ " + args.map((tn) -> "_" + tn[1]).join(", ") + " };\n";
				}

				final tmmt = Types.getMemoryManagementTypeFromType(enumType);
				final retCpp = XComp.applyMMConversion("result", o.field.pos, enumType, Value, tmmt);

				// Add include if smart pointer used since not guarenteed otherwise.
				switch(tmmt) {
					case SharedPtr: IComp.addInclude(Compiler.SharedPtrInclude[0], true);
					case UniquePtr: IComp.addInclude(Compiler.UniquePtrInclude[0], true);
					case _:
				}

				construct += "\treturn " + retCpp + ";\n";
				construct += "}";
				constructors.push(construct);
			}

			// Generate argument "getter"
			if(hasArgs) {
				var enumArgGet = "";
				enumArgGet += structName + " get" + o.name + "() {\n";
				#if cxx_disable_haxe_std
				enumArgGet += "\treturn data._" + index + ";\n";
				#else
				enumArgGet += "\treturn std::get<" + variantIndex + ">(data);\n";
				#end
				enumArgGet += "}";
				enumArgGetters.push(enumArgGet);
			}

			// Generate private structs
			if(hasArgs) {
				var content = "";
				content += "struct " + structName + " {\n";
				content += args.map((tn) -> "\t" + tn.join(" ") + ";").join("\n");
				content += "\n};";
				unionStructs.push(content.tab());
			}

			#if cxx_disable_haxe_std
			// Generate cases for destructor
			if(hasArgs) {
				final lines = ['case ${index}: {'];
				lines.push('\tdata._$index.~${structName}();');
				lines.push('\tbreak;');
				lines.push("}");
				destructorCases.push(lines.join("\n").tab());
			}
			#end

			// Generate cases used in `toString(): String` method
			{
				XComp.compilingInHeader = true;
				final lines = ['case ${index}: {'];
				#if !cxx_disable_haxe_std
				if(hasArgs) {
					lines.push('\tauto temp = get${o.name}();');
					final a = args.map(a -> '${getDynToStringCpp()}(temp.${a[1]})').join(" + \", \" + ");
					lines.push('\treturn ${XComp.stringToCpp(o.name)} + "(" + ${a} + ")";');
				} else {
				#end
					lines.push('\treturn ${XComp.stringToCpp(o.name)};');
				#if !cxx_disable_haxe_std
				}
				#end
				lines.push("}");
				XComp.compilingInHeader = false;

				toStringCases.push(lines.join("\n").tab());
			}

			if(hasArgs) {
				variantIndex++;
			}
		}

		// --------------------
		// Complete declaration

		// Only create union if we need to
		final requiresUnion = unionStructs.length > 0;
		if(requiresUnion) {
			IComp.addInclude("variant", true, true);
			declaration += unionStructs.join("\n\n") + "\n\n";
			#if cxx_disable_haxe_std
			declaration += "\tunion all_data {\n" + ('\t\tall_data() {}\n\t\t~all_data() {}\n') + [for(i in 0...structs.length) '\t\t${structs[i].name} _${structs[i].index};'].join("\n") + "\n\t} data;\n\n";
			#else
			declaration += "\tstd::variant<" + structs.map(s -> s.name).join(", ") + "> data;\n\n";
			#end
		}
		
		// Create default constructor
		declaration += (enumName + "() {\n\tindex = -1;\n}").tab() + "\n\n";

		#if cxx_disable_haxe_std
		// Create destructor
		destructorCases.push("default: {}".tab());
		declaration += ('~$enumName() {\n\tswitch(index) {\n${destructorCases.join("\n").tab()}\n\t}\n}').tab() + "\n\n";
		#end

		// Static function "constructors"
		declaration += constructors.join("\n\n").tab();

		// Option argument getters
		if(enumArgGetters.length > 0) {
			declaration += "\n\n" + enumArgGetters.join("\n\n").tab();
		}

		// toString
		toStringCases.push("default: return \"\";".tab());
		final toStringContent = "switch(index) {\n" + toStringCases.join("\n") + "\n}\nreturn \"\";";
		final cppStringType = NameMetaHelper.getNativeNameOverride("String") ?? (
			#if cxx_disable_haxe_std
			"const char*"
			#else
			"std::string"
			#end
		);
		declaration += "\n\n" + (cppStringType + " toString() {\n" + toStringContent.tab() + "\n}").tab();

		// operator bool
		declaration += "\n\n" + "operator bool() const {\n\treturn true;\n}".tab();

		// Finish C++ class
		declaration += "\n};";

		// Start output
		final headerFilePath = Compiler.HeaderFolder + "/" + headerFilename;

		// pragma once
		Main.setExtraFileIfEmpty(headerFilePath, "#pragma once");

		// Compile headers
		IComp.appendIncludesToExtraFileWithoutRepeats(headerFilePath, IComp.compileHeaderIncludes(), 1);
		Main.appendToExtraFile(headerFilePath, IComp.compileForwardDeclares(), 2);

		// Output class
		var content = "";
		content += Main.compileNamespaceStart(enumType);
		content += declaration;
		content += Main.compileNamespaceEnd(enumType);

		Main.appendToExtraFile(headerFilePath, content + "\n", 3);

		// Let the reflection compiler know this enum was compiled.
		RComp.addCompiledModuleType(Main.getCurrentModule().trustMe());

		// Clear the dependency tracker.
		Main.clearDep();

		return null;
	}
}

#end
