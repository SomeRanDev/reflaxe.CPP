# Reflaxe/C++ Tests || Fast Test Program

As more and more tests are added to this project, the longer it takes to test things. This small Rust project aims to alleviate this problem by using multi-threading to run all the tests simultaneously.

With Rust installed, run the following command in this directory:

```
cargo run --release
```

There are a couple arguments that can be appended:

```
cargo run --release -- --help

cargo run --release -- --test HelloWorld

cargo run --release -- -dev-mode --update-intended
```

If running the executable directly, the path to the base of the "Reflaxe/C++" repository must be provided as the first argument:

```
./haxe-cxx-fast-test --ucpp_repo_path path-to-repo
```
