package;

final TEST_DIR = "test/unit_testing/tests";
final OUT_DIR = "out";
final INTENDED_DIR = "intended";

function printlnErr(msg: String) {
	Sys.stderr().writeString(msg + "\n", haxe.io.Encoding.UTF8);
	Sys.stderr().flush();
}

function main() {
	final tests = checkAndReadDir(TEST_DIR);
	var failures = 0;
	for(t in tests) {
		if(!processTest(t)) {
			failures++;
		}
	}

	final testCount = tests.length;
	final success = testCount - failures;
	Sys.println("");
	Sys.println(success + " / " + testCount + " tests passed.");

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
	for(hxml in hxmlFiles) {
		final absPath = haxe.io.Path.join([testDir, hxml]);
		final args = [
			"-cp std",
			"-cp std/gcf/_std",
			"-cp src",
			"-lib reflaxe",
			"extraParams.hxml",
			"-cp " + testDir,
			"-D cpp-output=" + haxe.io.Path.join([testDir, OUT_DIR]),
			"\"" + absPath + "\""
		];
		final process = new sys.io.Process("haxe " + args.join(" "));
		final ec = process.exitCode();
		if(ec != 0) {
			printFailed(hxml + "\nExit Code: " + ec + "\n" + process.stderr.readAll().toString());
			return false;
		} else {
			final output = process.stdout.readAll().toString();
			if(output.length > 0) {
				Sys.println(output);
			}
		}
	}
	return if(compareOutputFolders(testDir)) {
		Sys.println("Success! Output matches! ❤️");
		true;
	} else {
		false;
	}
}

function compareOutputFolders(testDir: String): Bool {
	final intendedFolder = haxe.io.Path.join([testDir, INTENDED_DIR]);
	final outFolder = haxe.io.Path.join([testDir, OUT_DIR]);
	if(!sys.FileSystem.exists(intendedFolder)) {
		return true;
	}
	final files = getAllFiles(intendedFolder);
	final errors = [];
	for(f in files) {
		final err = compareFiles(haxe.io.Path.join([intendedFolder, f]), haxe.io.Path.join([outFolder, f]));
		if(err != null) {
			errors.push(err);
		}
	}
	return if(errors.length > 0) {
		printFailed(errors.join("\n"));
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

	final contentA = sys.io.File.getContent(fileA);
	final contentB = sys.io.File.getContent(fileB);

	if(contentA != contentB) {
		return "`" + fileB + "` does not match the intended output.";
	}

	return null;
}

