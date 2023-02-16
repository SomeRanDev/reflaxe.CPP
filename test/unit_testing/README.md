# Haxe to GC-Free C++ Tests

This is where the tests happen!

### How to Run Tests
```hxml
haxe TestAll.hxml
```

### How to Add Test
 * Create a new folder in `tests/` with your desired name.
 * Place as many `.hx` files in this folder as desired.
 * Create as many `.hxml` files are desired, they will be called in alphabetical order. If only one `.hxml` file is desired, please call it `Test.hxml` for consistency.
 * Place the intended C++ output in `intended/`. The generated C++ output will be placed in `out/`. If the content of these folders do not match, the test will fail.
