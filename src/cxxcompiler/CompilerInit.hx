package cxxcompiler;

#if (macro || cxx_runtime)

import haxe.macro.Context;

import reflaxe.ReflectCompiler;
import reflaxe.input.ClassModifier;

using reflaxe.helpers.ExprHelper;

class CompilerInit {
	public static function Start() {
		#if !eval
		Sys.println("CompilerInit.Start can only be called from a macro context.");
		return;
		#end

		#if (haxe_ver < "4.3.0")
		Sys.println("Reflaxe/C++ requires Haxe version 4.3.0 or greater.");
		return;
		#end

		ReflectCompiler.AddCompiler(new Compiler(), {
			fileOutputExtension: ".hpp",
			outputDirDefineName: "cpp-output",
			fileOutputType: FilePerClass,
			reservedVarNames: reservedNames(),
			targetCodeInjectionName: "__cpp__",
			dynamicDCE: true,
			customStdMeta: [":cxxStd"],
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
		haxe.macro.Compiler.addMetadata("@:noCallstack", "haxe.CallStack", "callStack", true);
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
