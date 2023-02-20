package freecompiler;

#if (macro || gdscript_runtime)

import haxe.macro.Expr;
import haxe.macro.Type;

import haxe.display.Display.MetadataTarget;

import reflaxe.ReflectCompiler;

using reflaxe.helpers.ExprHelper;

class FreeCompilerInit {
	public static function Start() {
		ReflectCompiler.AddCompiler(new FreeCompiler(), {
			fileOutputExtension: ".hpp",
			outputDirDefineName: "cpp-output",
			fileOutputType: FilePerClass,
			ignoreTypes: ["haxe.iterators.ArrayIterator", "haxe.iterators.ArrayKeyValueIterator"],
			reservedVarNames: reservedNames(),
			targetCodeInjectionName: "__fcpp__",
			dynamicDCE: true,
			trackUsedTypes: true,
			allowMetaMetadata: false
		});
	}

	static function reservedNames() {
		return [];
	}
}

#end
