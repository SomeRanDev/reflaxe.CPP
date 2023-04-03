# Haxe to Unbound C++ Tests || Fast Test Program

As more and more tests are added to this project, the longer it takes to test things. This small Rust project aims to alleviate this problem by using multi-threading to run all the tests simultaneously.

With Rust installed, run the following command in this directory:
```
cargo run --release
```

If running the executable directly, the path to the base of the "Haxe to Unbound C++" repository must be provided as the first argument:
```
./haxe-ucpp-fast-test path-to-repo
```
