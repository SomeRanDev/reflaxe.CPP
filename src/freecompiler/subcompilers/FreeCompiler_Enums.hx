// =======================================================
// * FreeCompiler_Enums
//
// This sub-compiler is used to handle compiling of all
// enum delcarations
// =======================================================

package freecompiler.subcompilers;

#if (macro || fcpp_runtime)

// import haxe.macro.Context;
// import haxe.macro.Expr;
import haxe.macro.Type;

import reflaxe.BaseCompiler;

// using reflaxe.helpers.NameMetaHelper;
using reflaxe.helpers.SyntaxHelper;

using freecompiler.helpers.FreeError;
using freecompiler.helpers.FreeMeta;

@:allow(freecompiler.FreeCompiler)
@:access(freecompiler.FreeCompiler)
@:access(freecompiler.subcompilers.FreeCompiler_Includes)
@:access(freecompiler.subcompilers.FreeCompiler_Types)
class FreeCompiler_Enums extends FreeSubCompiler {
	public function compileEnum(enumType: EnumType, options: EnumOptions): Null<String> {
		final filename = Main.getFileNameFromModuleData(enumType);
		final headerFilename = filename + FreeCompiler.HeaderExt;

		// --------------------
		// Init includes (always headers = true)
		IComp.resetAndInitIncludes(true, [headerFilename]);

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

		// --------------------
		// Generate entire class declaration in "declaration"
		final enumName = TComp.compileEnumName(enumType, enumType.pos, null, false, true);
		var declaration = "class " + enumName + " {\npublic:\n";
		declaration += "\tint index;\n\n";

		var constructors = [];
		var destructInfo = [];
		var unionStructs = [];
		var unionContent = [];

		// --------------------
		// Iterate through options
		var index = 0;
		for(o in options) {
			final hasArgs = o.args.length > 0;
			final args = o.args.map(opt -> [TComp.compileType(opt.t, o.field.pos), opt.name]);

			for(a in o.args) {
				Main.onTypeEncountered(a.t, true);
			}

			// Generate static function "constructors"
			{
				final funcArgs = [];
				for(i in 0...args.length) {
					funcArgs.push(args[i][0] + " _" + args[i][1] + (o.args[i].opt ? " = std::nullopt" : ""));
				}
				var construct = "";
				construct += "static " + enumName + " " + o.name + "(" + funcArgs.join(", ") + ") {\n";
				construct += "\t" + enumName + " result;\n";
				construct += "\tresult.index = " + index + ";\n";
				if(hasArgs) {
					construct += "\tresult.data." + o.name + " = { " + args.map((tn) -> "_" + tn[1]).join(", ") + " };\n";
				}
				construct += "\treturn result;\n";
				construct += "}";
				constructors.push(construct);
			}

			// Generate private structs
			if(hasArgs) {
				var content = "";
				final structName = "d" + o.name + "Impl";
				content += "struct " + structName + " {\n";
				content += args.map((tn) -> "\t" + tn.join(" ") + ";").join("\n");
				content += "\n};";
				unionStructs.push(content.tab());
				destructInfo.push({ index: index, name: o.name, sname: structName });
				unionContent.push("\t" + structName + " " + o.name + ";");
			}

			index++;
		}

		// --------------------
		// Complete declaration

		// Only create union if we need to
		final requiresUnion = unionStructs.length > 0;
		if(requiresUnion) {
			declaration += unionStructs.join("\n\n") + "\n\n";

			final unionIntro = "union dData {\n\tdData() {}\n\t~dData() {}\n";
			final unionEnd = "\n};";
			declaration += (unionIntro + unionContent.join("\n") + unionEnd).tab() + "\n\n";

			declaration += "\tdData data;\n\n";
		}
		
		// Create default constructor
		declaration += (enumName + "() {\n\tindex = -1;\n}").tab() + "\n\n";

		// If we're using a union, we need a copy constructor and destructor
		if(requiresUnion) {
			// --------------------
			// Copy Constructor
			var copyCon = enumName + "(const " + enumName + "& other) {\n\tindex = other.index;\n";

			// Copy Constructor Body
			{
				var constructSwitch = "#define ConstructCase(index, cls) case index: { data.cls = other.data.cls; break; }\n";
				for(d in destructInfo) {
					constructSwitch += "ConstructCase(" + d.index + ", " + d.name + ")\n";
				}
				constructSwitch += "#undef ConstructCase";

				copyCon += "\tswitch(index) {\n";
				copyCon += constructSwitch.tab().tab();
				copyCon += "\n\t}\n";
			}

			copyCon += "}";

			// --------------------
			// Destructor
			var destruct = "~" + enumName + "() {\n";

			// Destructor body
			{
				var destructSwitch = "#define DestructCase(index, field, cls) case index: { data.field.~cls(); break; }\n";
				for(d in destructInfo) {
					destructSwitch += "DestructCase(" + d.index + ", " + d.name + ", " + d.sname + ")\n";
				}
				destructSwitch += "#undef DestructCase";

				destruct += "\tswitch(index) {\n";
				destruct += destructSwitch.tab().tab();
				destruct += "\n\t}\n";
			}

			destruct += "}";

			// --------------------
			// Add to declaration
			declaration += copyCon.tab() + "\n\n";
			declaration += destruct.tab() + "\n\n";
		}

		// Static function "constructors"
		declaration += constructors.join("\n\n").tab();
		declaration += "\n};";

		// Start output
		final headerFilePath = "include/" + headerFilename;

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

		return null;
	}
}

#end