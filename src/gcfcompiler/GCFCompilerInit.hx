package gcfcompiler;

#if (macro || gdscript_runtime)

import haxe.macro.Expr;
import haxe.macro.Type;

import haxe.display.Display.MetadataTarget;

import reflaxe.ReflectCompiler;

using reflaxe.helpers.ExprHelper;

class GCFCompilerInit {
	public static function Start() {
		ReflectCompiler.AddCompiler(new GCFCompiler(), {
			fileOutputExtension: ".hpp",
			outputDirDefineName: "cpp-output",
			fileOutputType: FilePerClass,
			ignoreTypes: ["haxe.iterators.ArrayIterator"],
			reservedVarNames: reservedNames(),
			targetCodeInjectionName: "__cpp__",
			smartDCE: true,
			trackUsedTypes: true,
			allowMetaMetadata: true,
			autoNativeMetaFormat: "[[{}]]",
			metadataTemplates: [
			]
		});
	}

	static function reservedNames() {
		return [];
	}
}

#end
