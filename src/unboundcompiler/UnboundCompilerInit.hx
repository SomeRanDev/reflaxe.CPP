package unboundcompiler;

#if (macro || ucpp_runtime)

import reflaxe.ReflectCompiler;

using reflaxe.helpers.ExprHelper;

class UnboundCompilerInit {
	public static function Start() {
		ReflectCompiler.AddCompiler(new UnboundCompiler(), {
			fileOutputExtension: ".hpp",
			outputDirDefineName: "cpp-output",
			fileOutputType: FilePerClass,
			reservedVarNames: reservedNames(),
			targetCodeInjectionName: "__ucpp__",
			dynamicDCE: true,
			trackUsedTypes: true,
			allowMetaMetadata: false
		});
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
