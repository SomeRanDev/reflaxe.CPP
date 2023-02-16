# Haxe to GC-Free C++ Tests

This is where the tests happen!

## How to Run Tests
Make sure you're calling from the base directory of this repository.
```hxml
haxe test/unit_testing/TestAll.hxml
```

## How to Add Test
 * Create a new folder in `tests/` with your desired name.
 * Place as many `.hx` files in this folder as desired.
 * Create as many `.hxml` files are desired, they will be called in alphabetical order. If only one `.hxml` file is desired, please call it `Test.hxml` for consistency.
 * Place the intended C++ output in `intended/`. The generated C++ output will be placed in `out/`. After every `.hxml` file in the directory is executed, the content of these folders are compared. If they do not match, the test will fail.
