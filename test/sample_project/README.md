# Haxe to GC-Free C++ Sample Project

Just a simple sample to help you get started.

Call either .hxml file with `haxe` from the base directory of the repository.
```
haxe test/sample_project/Test_WithRepo.hxml
```

---

`Test_WithHaxelib.hxml`<br>
For creating new projects, this should be used to access the latest version of this library on haxelib.

`Test_WithRepo.hxml`<br>
Call this .hxml file to use the library code currently in the parent directories when downloaded from the github repository.

`BuildCpp.bat`<br>
Builds the generated C++ files into `bin/Program.exe`. Requires calling from a VS environment with access to `cl.exe`. (Note to Future Self: try searching "Native Tools Command Prompt" in Windows if you have Visual Studio installed.)
