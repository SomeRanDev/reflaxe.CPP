:: ---------------
:: BuildCpp.bat
::
:: Builds the .cpp files generated in the out/ folder.
:: ---------------

:: Ensure everything is reset after .bat is complete
setlocal

:: Set cwd to where this .bat file is
cd /d %~dp0

:: Create these folders if they do not exist
if not exist "obj/" (mkdir obj)
if not exist "bin/" (mkdir bin)

:: Compile C++
cl.exe out/src/*.cpp /I out/include /std:c++17 /EHsc /Fo:obj/ /Fe:bin/Program.exe
