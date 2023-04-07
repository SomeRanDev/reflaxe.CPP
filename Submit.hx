//====================================================================
// * Haxe to (Unbound) C++ Submit Script
//
// Haxelib is dumb and only allows for one class path, so this
// script merges all the class paths (`src`, `std`, `std/ucpp/_std`)
// into a single folder to help with haxelib submission.
//====================================================================

package;

import sys.io.File;
import haxe.io.Path;

class Submit {
	static final destFolder = "_submit";

	public static function main() {
		if(destFolder.length <= 0) throw "Destination folder must be defined.";
		if(sys.FileSystem.exists(destFolder)) throw "'Folder /" + destFolder + "/ should not exist before running this script.'";
		makeDirIfNonExist(destFolder);

		copyDirContent("src", destFolder + "/src");
		copyDirContent("std", destFolder + "/src", "std/ucpp/_std");
		copyDirContent("std/ucpp/_std", destFolder + "/src", "", ".cross.hx");

		for(file in ["haxelib.json", "extraParams.hxml", "LICENSE", "README.md"]) {
			File.copy(file, destFolder + "/" + file);
		}
	}

	static function makeDirIfNonExist(p: String) {
		if(!sys.FileSystem.exists(p)) {
			sys.FileSystem.createDirectory(p);
		}
	}
	
	static function copyDirContent(from: String, to: String, ignore: String = "", replaceExt: Null<String> = null) {
		if(sys.FileSystem.exists(from)) {
			for(file in sys.FileSystem.readDirectory(from)) {
				final path = Path.join([from, file]);
				var dest = Path.join([to, file]);
				trace(file, path, dest, sys.FileSystem.isDirectory(path));
				if(!sys.FileSystem.isDirectory(path)) {
					if(replaceExt != null) {
						dest = Path.withoutExtension(dest) + replaceExt;
					}
					trace("copied: " + path + "  to  " + dest);
					File.copy(path, dest);
				} else {
					if(ignore.length > 0 && ignore == path) {
						return;
					}
					final d = Path.addTrailingSlash(path);
					final d2 = Path.addTrailingSlash(dest);
					makeDirIfNonExist(d2);
					copyDirContent(d, d2, ignore, replaceExt);
				}
			}
		}
	}
}
