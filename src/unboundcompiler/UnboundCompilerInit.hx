package unboundcompiler;

#if (macro || ucpp_runtime)

import haxe.macro.Context;

import reflaxe.ReflectCompiler;
import reflaxe.input.ClassModifier;

using reflaxe.helpers.ExprHelper;

class UnboundCompilerInit {
	public static function Start() {
		#if !eval
		Sys.println("UnboundCompilerInit.Start can only be called from a macro context.");
		return;
		#end

		#if (haxe_ver < "4.3.0")
		Sys.println("Haxe to Unbound C++ requires Haxe version 4.3.0 or greater.");
		return;
		#end

		ReflectCompiler.AddCompiler(new UnboundCompiler(), {
			fileOutputExtension: ".hpp",
			outputDirDefineName: "cpp-output",
			fileOutputType: FilePerClass,
			reservedVarNames: reservedNames(),
			targetCodeInjectionName: "__ucpp__",
			dynamicDCE: true,
			customStdMeta: [":ucppStd"],
			trackUsedTypes: true,
			allowMetaMetadata: true,
			autoNativeMetaFormat: "[[{}]]"
		});

		applyMods();
	}

	static function applyMods() {
		// Provide StringTools.isEof implementation for this target.
		ClassModifier.mod("StringTools", "isEof", macro return c == 0);

		// Ensure the Haxe compiler keeps every IMap field.
		#if macro
		haxe.macro.Compiler.addMetadata("@:keep", "haxe.IMap");
		#end
	}

	static function reservedNames() {
		return [
			"asm", "bool", "double", "new", "switch", "auto",
			"else", "operator", "template", "break", "enum",
			"private", "this", "case", "extern", "protected",
			"throw", "catch", "float", "public", "try", "char",
			"for", "register", "typedef", "class", "friend",
			"return", "union", "const", "goto", "short", "unsigned",
			"continue", "if", "signed", "virtual", "default", "inline",
			"sizeof", "void", "delete", "int", "static", "volatile",
			"do", "long", "struct", "while"
		];
	}
}

#end
