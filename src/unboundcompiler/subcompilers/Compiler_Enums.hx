// =======================================================
// * Compiler_Enums
//
// This sub-compiler is used to handle compiling of all
// enum delcarations
// =======================================================

package unboundcompiler.subcompilers;

#if (macro || ucpp_runtime)

import haxe.macro.Type;

import reflaxe.BaseCompiler;

using reflaxe.helpers.NullHelper;
using reflaxe.helpers.SyntaxHelper;
using reflaxe.helpers.TypeHelper;

using unboundcompiler.helpers.UError;
using unboundcompiler.helpers.UMeta;
using unboundcompiler.helpers.USort;

@:allow(unboundcompiler.UnboundCompiler)
@:access(unboundcompiler.UnboundCompiler)
@:access(unboundcompiler.subcompilers.Compiler_Exprs)
@:access(unboundcompiler.subcompilers.Compiler_Includes)
@:access(unboundcompiler.subcompilers.Compiler_Types)
class Compiler_Enums extends SubCompiler {
	public function compileEnum(enumType: EnumType, options: EnumOptions): Null<String> {
		final filename = Main.getFileNameFromModuleData(enumType);
		final headerFilename = filename + UnboundCompiler.HeaderExt;

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
					if(Main.isSameAsCurrentModule(a.t)) {
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
		// Generate entire class declaration in "declaration"
		final enumName = TComp.compileEnumName(enumTypeRef, enumType.pos, null, false, true);
		var declaration = "class " + enumName + " {\npublic:\n";
		declaration += "\tint index;\n\n";

		// --------------------
		// Iterate through options

		// Accumulate different declarations while iterating.
		var constructors = [];
		var enumArgGetters = [];
		var unionStructs = [];
		var structs = [];

		// Counts arguments added to the variant.
		var variantIndex = 0;

		// Sort the enum fields in index order to ensure
		// sequential indexes are consistent + cleaner output.
		final sortedOptions = options.sorted((a, b) -> {
			return if(a.field.index < a.field.index) -1;
			else if(a.field.index > b.field.index) 1;
			else 0;
		});

		// Iterate
		for(o in sortedOptions) {
			var index = o.field.index;
			final hasArgs = o.args.length > 0;
			final args = o.args.map(opt -> [TComp.compileType(opt.t, o.field.pos), opt.name]);

			for(a in o.args) {
				Main.onTypeEncountered(a.t, true);
			}

			final structName = "d" + o.name + "Impl";
			if(hasArgs) {
				structs.push(structName);
			}

			// Generate static function "constructors"
			{
				var enumType = o.field.type.getTFunReturn();
				if(enumType == null) {
					enumType = o.field.type;
				}

				final funcArgs = [];
				for(i in 0...args.length) {
					funcArgs.push(args[i][0] + " _" + args[i][1] + (o.args[i].opt ? " = std::nullopt" : ""));
				}
				var construct = "";
				construct += "static " + TComp.compileType(enumType, o.field.pos) + " " + o.name + "(" + funcArgs.join(", ") + ") {\n";
				construct += "\t" + enumName + " result;\n";
				construct += "\tresult.index = " + index + ";\n";
				if(hasArgs) {
					construct += "\tresult.data = " + structName + "{ " + args.map((tn) -> "_" + tn[1]).join(", ") + " };\n";
				}

				final tmmt = TComp.getMemoryManagementTypeFromType(enumType);
				final retCpp = XComp.applyMMConversion("result", o.field.pos, enumType, Value, tmmt);

				construct += "\treturn " + retCpp + ";\n";
				construct += "}";
				constructors.push(construct);
			}

			// Generate argument "getter"
			if(hasArgs) {
				var enumArgGet = "";
				enumArgGet += structName + " get" + o.name + "() {\n";
				enumArgGet += "\treturn std::get<" + variantIndex + ">(data);\n";
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
			declaration += "\tstd::variant<" + structs.join(", ") + "> data;\n\n";
		}
		
		// Create default constructor
		declaration += (enumName + "() {\n\tindex = -1;\n}").tab() + "\n\n";

		// Static function "constructors"
		declaration += constructors.join("\n\n").tab();

		// Option argument getters
		if(enumArgGetters.length > 0) {
			declaration += "\n\n" + enumArgGetters.join("\n\n").tab();
		}

		// Finish C++ class
		declaration += "\n};";

		// Start output
		final headerFilePath = UnboundCompiler.HeaderFolder + "/" + headerFilename;

		// pragma once
		Main.setExtraFileIfEmpty(headerFilePath, "#pragma once");

		// Compile headers
		IComp.appendIncludesToExtraFileWithoutRepeats(headerFilePath, IComp.compileHeaderIncludes(), 1);

		// Output class
		var content = "";
		content += Main.compileNamespaceStart(enumType);
		content += declaration;
		content += Main.compileNamespaceEnd(enumType);

		Main.appendToExtraFile(headerFilePath, content + "\n", 2);

		// Let the reflection compiler know this enum was compiled.
		RComp.addCompiledModuleType(Main.getCurrentModule().trustMe());

		return null;
	}
}

#end
