package;

final TEST_DIR = "test/unit_testing/tests";
final OUT_DIR = "out";
final INTENDED_DIR = "intended";
final BUILD_DIR = "build";

var ShowAllOutput = false;
var UpdateIntended = false;
var UpdateIntendedSys = false;
var OSExclusive = false;
var NoDetails = false;

function printlnErr(msg: String) {
	Sys.stderr().writeString(msg + "\n", haxe.io.Encoding.UTF8);
	Sys.stderr().flush();
}

function main() {
	// ------------------------------------
	// Parse options
	// ------------------------------------
	final args = Sys.args();
	if(args.contains("help")) {
		Sys.println("Run this .hxml file from the root of the repo.
Append the following options to the command:

* help
Shows this output.

* nocompile
The C++ compiling/run tests do not occur.

* compile-only
Recompiles the C++ without compiling the Haxe code.

* always-compile
The C++ compiling/run tests will occur no matter what, even if the initial output comparison tests fail.

* show-output
The output of the C++ compilation and executable is always shown, even if it ran successfuly.

* update-intended
The C++ output is generated in the `intended` folder.

* os-exclusive
Only tests with intended folders exclusive to this operating system will be processed.

* no-details
The list of C++ output lines that do not match the tests are ommitted from the output.

* dev-mode
Enables `always-compile`, `show-output`, and `no-details`.

* test=TestName
Makes it so only this test is ran. This option can be added multiple times to perform multiple tests.");

		return;
	}

	ShowAllOutput = args.contains("show-output");
	UpdateIntended = args.contains("update-intended");
	UpdateIntendedSys = args.contains("update-intended-sys");
	OSExclusive = args.contains("os-exclusive");
	NoDetails = args.contains("no-details");

	var alwaysCompile = args.contains("always-compile");

	if(args.contains("dev-mode")) {
		alwaysCompile = true;
		ShowAllOutput = true;
		NoDetails = true;
	}

	// ------------------------------------
	// Allowed tests
	// ------------------------------------
	final allowedTests = args.map(a -> {
		final r = ~/test=(\w+)/;
		if(r.match(a)) {
			r.matched(1);
		} else {
			null;
		}
	}).filter(a -> a != null);

	// ------------------------------------
	// Haxe compiling
	// ------------------------------------
	var tests = checkAndReadDir(TEST_DIR);
	if(allowedTests.length > 0) {
		tests = tests.filter(t -> allowedTests.contains(t));
		if(tests.length <= 0) {
			printlnErr("The provided tests do not exist: " + tests);
			Sys.exit(1);
		}
	}

	if(OSExclusive) {
		tests = tests.filter(function(t) {
			final sysDir = INTENDED_DIR + "-" + Sys.systemName();
			return sys.FileSystem.exists(haxe.io.Path.join([TEST_DIR, t, sysDir]));
		});
	}

	final compileOnly = args.contains("compile-only");
	var failures = 0;
	if(!compileOnly) {
		for(t in tests) {
			if(!processTest(t)) {
				failures++;
			}
		}
	}

	final testCount = tests.length;
	final success = testCount - failures;
	if(!compileOnly) {
		Sys.println("");
		Sys.println(success + " / " + testCount + " tests passed.");
	}

	if(failures > 0 && !alwaysCompile) {
		Sys.exit(1);
	}

	// ------------------------------------
	// C++ compiling
	// ------------------------------------
	if(args.contains("nocompile")) {
		return;
	}

	failures = 0;
	final systemName = Sys.systemName();
	final originalCwd = Sys.getCwd();

	Sys.println("\n===========\nTesting C++ Compilation\n===========\n");

	if(systemName != "Windows" && systemName != "Linux") {
		Sys.println("C++ compilation test not supported for `" + systemName + "`");
		return;
	}

	final failedTests = [];
	for(t in tests) {
		if(!processCppCompile(t, systemName, originalCwd)) {
			failures++;
			failedTests.push(t);
		}
	}

	final success = testCount - failures;
	Sys.println("");
	Sys.println(success + " / " + testCount + " successfully compiled in C++.");
	if(failures > 0) {
		Sys.println("The following failed: " + failedTests);
	}

	if(failures > 0) {
		Sys.exit(1);
	}
}

function checkAndReadDir(path: String): Array<String> {
	if(!sys.FileSystem.exists(path)) {
		throw "Path: `" + path + "` could not be found. Is the current working directory (cwd) the top folder of the repository??";
	}
	return sys.FileSystem.readDirectory(path);
}

function processTest(t: String): Bool {
	Sys.println("-- " + t + " --");
	final testDir = haxe.io.Path.join([TEST_DIR, t]);
	final hxmlFiles = checkAndReadDir(testDir).filter(function(file) {
		final p = new haxe.io.Path(file);
		return p.ext == "hxml";
	});
	return if(hxmlFiles.length == 0) {
		printFailed("No .hxml files found in test directory: `" + testDir + "`!");
		false;
	} else {
		executeTests(testDir, hxmlFiles);
	}
}

function printFailed(msg: Null<String> = null) {
	printlnErr("Failed... 💔");
	if(msg != null) {
		printlnErr(msg);
	}
}

function executeTests(testDir: String, hxmlFiles: Array<String>): Bool {
	final noIntended = sys.FileSystem.exists(haxe.io.Path.join([testDir, "no-intended"]));

	for(hxml in hxmlFiles) {
		final absPath = haxe.io.Path.join([testDir, hxml]);
		final args = [
			"--no-opt",
			"-cp std",
			"-cp std/cxx/_std",
			"-cp src",
			"-lib reflaxe",
			"extraParams.hxml",
			"-cp " + testDir,
			"-D message-reporting=pretty",
			"-D cpp-output=" + haxe.io.Path.join([testDir, noIntended ? OUT_DIR : getOutputDirectory(testDir)]),
			"\"" + absPath + "\""
		];

		Sys.println("haxe " + args.join(" "));
		Sys.println("");

		final process = new sys.io.Process("haxe " + args.join(" "));
		final _out = process.stdout.readAll();
		final _in = process.stderr.readAll();

		final stdoutContent = _out.toString();
		final stderrContent = _in.toString();

		final ec = process.exitCode();
		if(ec != 0) {
			onProcessFail(process, hxml, ec, stdoutContent, stderrContent);
			return false;
		} else {
			if(stdoutContent.length > 0) {
				Sys.println(stdoutContent);
			}
			if(ShowAllOutput && stderrContent.length > 0) {
				Sys.println(stderrContent);
			}
		}
	}

	return if(noIntended) {
		Sys.println("No intended folder! 😉");
		true;
	} else if(compareOutputFolders(testDir)) {
		Sys.println("Success! Output matches! ❤️");
		true;
	} else {
		false;
	}
}

function getOutputDirectory(testDir: String): String {
	final sysDir = INTENDED_DIR + "-" + Sys.systemName();
	return if(UpdateIntendedSys) {
		sysDir;
	} else if(UpdateIntended) {
		if(sys.FileSystem.exists(haxe.io.Path.join([testDir, sysDir]))) {
			sysDir;
		} else {
			INTENDED_DIR;
		}
	} else {
		OUT_DIR;
	}
}

function onProcessFail(process: sys.io.Process, hxml: String, ec: Int, stdoutContent: String, stderrContent: String) {
	final info = [];
	info.push(".hxml File:\n" + hxml);
	info.push("Exit Code:\n" + ec);

	if(stdoutContent.length > 0) {
		info.push("Output:\n" + stdoutContent);
	}

	if(stderrContent.length > 0) {
		info.push("Error Output:\n" + stderrContent);
	}

	var result = "\nFAILURE INFO\n------------------------------------\n";
	result += info.join("\n\n");
	result += "\n------------------------------------\n";

	printFailed(result);
}

function compareOutputFolders(testDir: String): Bool {
	final outFolder = haxe.io.Path.join([testDir, OUT_DIR]);
	final intendedFolderSys = haxe.io.Path.join([testDir, INTENDED_DIR + "-" + Sys.systemName()]);
	final intendedFolder = if(sys.FileSystem.exists(intendedFolderSys)) {
		intendedFolderSys;
	} else {
		haxe.io.Path.join([testDir, INTENDED_DIR]);
	}

	if(!sys.FileSystem.exists(intendedFolder)) {
		printFailed("Intended folder does not exist?");
		return false;
	}

	final files = getAllFiles(intendedFolder);
	final errors = [];
	for(f in files) {
		final intendedPath = haxe.io.Path.join([intendedFolder, f]);
		final outPath = haxe.io.Path.join([outFolder, f]);
		final err = compareFiles(intendedPath, outPath);
		if(err != null) {
			// If updating the intended folder, copy changes to the out/ as well.
			if(UpdateIntended) {
				if(!sys.FileSystem.exists(intendedPath)) {
					sys.FileSystem.deleteFile(outPath);
				} else {
					final dir = haxe.io.Path.directory(outPath);
					if(!sys.FileSystem.exists(dir)) {
						sys.FileSystem.createDirectory(dir);
					}
					sys.io.File.saveContent(outPath, sys.io.File.getContent(intendedPath));
				}
			} else {
				errors.push(err);
			}
		}
	}

	// If updating the intended folder, delete any out/ files that don't match.
	if(UpdateIntended) {
		final outputFiles = getAllFiles(outFolder);
		for(f in outputFiles) {
			if(!files.contains(f)) {
				final path = haxe.io.Path.join([outFolder, f]);
				if(sys.FileSystem.exists(path)) {
					sys.FileSystem.deleteFile(path);
				}
			}
		}
	}

	return if(errors.length > 0) {
		var result = "\nOUTPUT DOES NOT MATCH\n------------------------------------\n";
		result += errors.join("\n");
		result += "\n------------------------------------\n";
		printFailed(result);
		false;
	} else {
		true;
	}
}

function getAllFiles(dir: String): Array<String> {
	final result = [];
	for(file in sys.FileSystem.readDirectory(dir)) {
		final fullPath = haxe.io.Path.join([dir, file]);
		if(sys.FileSystem.isDirectory(fullPath)) {
			for(f in getAllFiles(fullPath)) {
				result.push(haxe.io.Path.join([file, f]));
			}
		} else {
			result.push(file);
		}
	}
	return result;
}

function compareFiles(fileA: String, fileB: String): Null<String> {
	if(!sys.FileSystem.exists(fileA)) {
		return "`" + fileA + "` does not exist.";
	}
	if(!sys.FileSystem.exists(fileB)) {
		return "`" + fileB + "` does not exist.";
	}

	function normalize(s: String) return StringTools.trim(StringTools.replace(s, "\r\n", "\n"));

	final contentA = normalize(sys.io.File.getContent(fileA));
	final contentB = normalize(sys.io.File.getContent(fileB));

	if(contentA != contentB) {
		final msg = fileB + "` does not match the intended output.";

		return if(NoDetails) {
			msg;
		} else {
			final result = ["---\n`" + msg + "\n---"];

			final linesA = contentA.split("\n");
			final linesB = contentB.split("\n");

			for(i in 0...linesA.length) {
				if(linesA[i] != linesB[i]) {
					var comp = "* Line " + (i + 1) + "\n";
					comp += "[int] (" + linesA[i].length + ") `" + linesA[i] + "`\n";
					comp += "[out] (" + linesB[i].length + ") `" + (i < linesB.length ? linesB[i] : "<empty>") + "`";
					result.push(comp);
				}
			}

			if(linesB.length > linesA.length) {
				result.push(fileB + " also has " + (linesB.length - linesA.length) + " more lines than " + fileA + ".");
			}

			result.join("\n\n");
		}
	}

	return null;
}

function processCppCompile(t: String, systemName: String, originalCwd: String): Bool {
	var result = true;

	Sys.println("-- " + t + " --");

	final testDir = haxe.io.Path.join([TEST_DIR, t, BUILD_DIR]);

	if(!sys.FileSystem.exists(testDir)) {
		sys.FileSystem.createDirectory(testDir);
	}

	Sys.println("cd " + testDir);
	Sys.setCwd(testDir);

	final compileCommand = if(systemName == "Windows") {
		// /W3 /WX /EHsc
		"cl ../" + OUT_DIR + "/src/*.cpp /I ../" + OUT_DIR + "/include /std:c++17 /Fe:test_out.exe /W3 /WX /EHsc";
	} else if(systemName == "Linux") {
		// -W3 -Werror
		"g++ -std=c++17 ../" + OUT_DIR + "/src/*.cpp -I ../" + OUT_DIR + "/include -o test_out -Wall -Werror -Wnon-virtual-dtor";
	} else {
		throw "Unsupported system";
	}

	Sys.println(compileCommand);
	Sys.println("");

	final compileProcess = new sys.io.Process(compileCommand);
	final stdoutContent = compileProcess.stdout.readAll().toString();
	final stderrContent = compileProcess.stderr.readAll().toString();
	final ec = compileProcess.exitCode();

	if(ec != 0) {
		Sys.println("C++ compilation failed...");
		Sys.println(stdoutContent);
		Sys.println(stderrContent);
		result = false;
	} else {
		Sys.println("C++ compilation success! 🧠");
		if(ShowAllOutput) {
			Sys.println(stdoutContent);
			Sys.println(stderrContent);
		}
	}

	// Run output
	final executeProcess = new sys.io.Process("\"./test_out\"");
	final exeOut = executeProcess.stdout.readAll().toString();
	final exeErr = executeProcess.stderr.readAll().toString();
	final exeEc = executeProcess.exitCode();
	if(exeEc != 0) {
		Sys.println("C++ executable returned exit code: " + exeEc);
		Sys.println(exeOut);
		Sys.println(exeErr);
		result = false;
	} else {
		Sys.println("C++ executable ran successfully! 🏃");
		if(ShowAllOutput) {
			Sys.println(exeOut);
			Sys.println(exeErr);
		}
	}

	// Reset to original current working directory
	Sys.setCwd(originalCwd);

	return result;
}

