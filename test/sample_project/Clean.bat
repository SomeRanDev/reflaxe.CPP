:: ---------------
:: Clean.bat
::
:: Deletes all the folders generated when compiling the .cpp.
:: ---------------

:: Ensure everything is reset after .bat is complete
setlocal

:: Set cwd to where this .bat file is
cd /d %~dp0

:: Delete these folders
rmdir "./bin" "./obj" "./out" /s