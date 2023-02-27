

<img src="https://raw.githubusercontent.com/RobertBorghese/Haxe-to-FreeCPP/main/.github/Logo.png" alt="I made a *checks notes* haxe 2 free cpp logo thingy look at it LOOK AT IT" width="900"/>

[![Test Workflow](https://github.com/RobertBorghese/Haxe-to-FreeCPP/actions/workflows/main.yml/badge.svg)](https://github.com/RobertBorghese/Haxe-to-FreeCPP/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
<a href="https://discord.com/channels/162395145352904705/1052688097592225904"><img src="https://discordapp.com/api/guilds/162395145352904705/widget.png?style=shield" alt="Reflaxe Thread"/></a>

*An alternative C++ target for Haxe that generates dependent-less, GC-less C++17 code. Made with [Reflaxe](https://github.com/RobertBorghese/reflaxe).*

The goal of this project is simple: create a compilation target for Haxe that generates minimal, human-readable C++ that can be compiled without linking additional libraries and does not rely on any garbage collection system.

**Haxe Code**
```haxe
function main() {
  trace("Hello world!");
}
```

**Haxe to Free C++ Output**
```cpp
#include "Main.h"

#include <iostream>

void _Main::Main_Fields_::main() {
	std::cout << "Main.hx:2: Hello world!" << std::endl;
}
```

&nbsp;

# Table of Contents

| Topic | Description |
| --- | --- |
| [Installation](https://github.com/RobertBorghese/Haxe-to-FreeCPP#installation) | How to install and use this project. |
| [Explanation](https://github.com/RobertBorghese/Haxe-to-FreeCPP#explanation) | A long winded explanation of this project's goals. |
| [Compiler Examples](https://github.com/RobertBorghese/Haxe-to-FreeCPP#compiler-examples) | Where to find examples. |
| [Compilation Hooks (Plugins)](https://github.com/RobertBorghese/Haxe-to-FreeCPP#compilation-hooks-plugins) | How to write plugins for the compiler. |
| [Destructors](https://github.com/RobertBorghese/Haxe-to-FreeCPP#destructors) | How to use destructors. |
| [Top Level Meta](https://github.com/RobertBorghese/Haxe-to-FreeCPP#top-level-meta) | Add top-level functions in C++. |
| [Memory Management](https://github.com/RobertBorghese/Haxe-to-FreeCPP#memory-management) | How the memory management system works. |

&nbsp;

# Installation

This project is currently in development, but once posted on haxelib, this is now the installation process should work:

| # | What to do | What to write |
| - | ------ | ------ |
| 1 | Install via haxelib. | <pre>haxelib install free-cpp</pre> |
| 2 | Add the lib to your `.hxml` file or compile command. | <pre lang="hxml">-lib free-cpp</pre> |
| 3 | Set the output folder for the compiled C++. | <pre lang="hxml">-D cpp-output=out</pre> |

Now your `.hxml` should be ready to go! Simply run with Haxe and the output will be generated just like any other Haxe target.

&nbsp;

# Explanation

Just to be clear, this project is not intended to be a drop-in replacement for the existing Haxe/C++ target. If Haxe/C++ already works perfectly for your project, you're in the wrong place. If anything, this project hopes to fill the gaps of what Haxe currently has trouble with when working with C++. So let's go ahead and dive into what that is...

## Why does this exist?

Haxe's normal C++ target uses a garbage collection system and requires compiling with the [hxcpp](https://github.com/HaxeFoundation/hxcpp) library. While this works great for projects expecting consistent behavior across multiple compilation targets, difficulties can arise trying to bind or work with existing C++ framworks containing custom compilation and/or memory management systems. Not to mention... Haxe generated C++ is bloated, confusing, and heavily reliant on hxcpp-exclusive structures.

Now, normally this isn't a problem as Haxe automatically compiles the C++, and most Haxe users can work with frameworks and libraries that have already done the heavy lifting. However, not every project has such a luxury. If you're looking to target C++ exclusively with your Haxe project and want a bit more ease in using/creating C++ code, this might be the project for you.

**Haxe to "Free C++"** attempts to resolve the aformentioned issues by converting Haxe to C++ in the simpliest way possible. *Instead of garbage collection,* modern smart pointers are used. *Instead of nullability,* the `optional<T>` type is used. C++ templates are used to translate anonymous structures and dynamic types. In general, modern C++ types are used to translate Haxe code to how it would be written if it were written in C++ to begin with.

## What are the benefits?

For starters, garbage collection is no longer a major issue. While GC works wonders in a controlled environment, it makes it so functions generated from Haxe cannot be arbitrarily called from C++ contexts, and Haxe/C++ objects cannot be managed by external C++ frameworks. But WITHOUT garbage collection, Haxe -> C++ functions can be safely bound to other languages (like [cxx for Rust](https://github.com/dtolnay/cxx)), or compiled with picky compilers ([WASM](https://developer.mozilla.org/en-US/docs/WebAssembly/C_to_wasm) comes to mind). Frameworks like Unreal Engine or Qt that provide their own memory management systems can be integrated with little issue.

This leads into another important aspect of this project: the different forms of memory management. While the original Haxe/C++ target allows classes to be treated like value-types, it requires a lot of boilerplate and forces the class to always use value management.

On the other hand, **Haxe to "Free C++"** gives memory types first-class treatment. A single metadata is used to default a class to using value, pointer, or smart pointer management, and `Value<T>`, `Ptr<T>`, and `SharedPtr<T>` can be used to override this default at any time. But the best part is conversions between these types are accounted for during typing, preventing invalid or unsafe assignments from being generated. Visit the [Memory Management](https://github.com/RobertBorghese/Haxe-to-FreeCPP#memory-management) section for more info.

&nbsp;

# Compiler Examples

Visit the `test/unit_testing/tests` directory for a bunch of samples and tests.

&nbsp;

# Compilation Hooks (Plugins)

This compiler also contains hooks to customize the C++ compilation. In an initialization macro, pass `FreeCompiler.onCompileBegin` a function to access an instance of the `FreeCompiler` once compiling begins. Then `addHook` can be used on any of the hooks contained within it.

Here is an example where all `Int` literals that are exactly `123` are compiled as `(100 + 20 + 3)`. Note the first parameter ("defaultOutput" in this case) is the output that would be generated normally; return it to prevent any changes to the compiler's normal behavior.
```haxe
// In some initialization macro...
FreeCompiler.onCompileBegin(function(compiler) {
  compiler.compileExpressionHook.addHook(myHookFunc);
});

// Called whenever an expression is compiled.
function myHookFunc(defaultOutput: Null<String>,
                    compiler: FreeCompiler,
		    typedExpr: TypedExpr): Null<String>
{
  return switch(typedExpr.expr) {
    case TConst(TInt(123)): "(100 + 20 + 3)";
    case _: defaultOutput;
  }
}
```

Now Haxe code will be compiled like this:
```haxe
// int a = (100 + 20 + 3);
var a = 123;
```

Here is a list of all the available `FreeCompiler` hooks.
```haxe
var compileExpressionHook;
function addHook(cb: (Null<String>, FreeCompiler, TypedExpr) -> Null<String>);

var compileClassHook;
function addHook(cb: (Null<String>, FreeCompiler, ClassType, ClassFieldVars, ClassFieldFuncs) -> Null<String>);

var compileEnumHook;
function addHook(cb: (Null<String>, FreeCompiler, EnumType, EnumOptions) -> Null<String>);

var compileTypedefHook;
function addHook(cb: (Null<String>, FreeCompiler, DefType) -> Null<String>);

var compileAbstractHook;
function addHook(cb: (Null<String>, FreeCompiler, AbstractType) -> Null<String>);
```

&nbsp;

# Destructors

Destructors are allowed in this Haxe target as there is no GC! Simply name any function `destructor` to make it the destructor.

**Haxe**
```haxe
@:headerOnly
class MyClass {
  public function destructor() {
    trace("Destroyed");
  }
}
```

**C++ Output**
```cpp
class MyClass {
public:
  ~MyClass() {
    std::cout << "Main.hx:4: Destroyed" << std::endl;
  }
};
```

&nbsp;

# Top Level Meta

The `@:topLevel` meta can be used to generated C++ functions outside of any namespace or class.

**Haxe**
```haxe
@:topLevel
function main(): Int {
  trace("Hello world!");
  return 0;
}
```

**C++ Output**
```cpp
int main() {
  std::cout << "Main.hx:3: Hello world!" << std::endl;
}
```

&nbsp;

# Memory Management

## Shared Pointer

By default, all classes use shared pointers. This uses the `std::shared_ptr<T>` class from the C++ standard library. They can be moved, copied, and referenced in mutliple locations. The `SharedPtr<T>` class can make a type use shared pointer if it doesn't by default.
```haxe
// std::shared_ptr<SharedClass> obj = std::make_shared<SharedClass>();
var obj = new SharedClass();

// std::shared_ptr<Int> sharedNum = std::make_shared<Int>(12);
var sharedNum: SharedPtr<Int> = 12;
```

## Value

A value type is a type that is only stored in one location. It gets copied when assigned or passed, so it's a good option for light-weight classes. Primitives such as `Int` and `Bool` are value types, but you can make any class default to it using the `@:valueType` metadata. The `Value<T>` class can be used to make a variable's type a "value" type anytime.
```haxe
@:valueType
class ValueClass { ... }

// ValueClass obj = ValueClass();
var obj = new ValueClass();

// SharedClass obj2 = SharedClass();
var obj2: Value<SharedClass> = new SharedClass();

// ---

function ReturnsPointer(): Ptr<ValueClass> { ... }

// ValueClass obj = (*ReturnsPointer());
var obj: ValueClass = ReturnsPointer();
```

## Pointer

This refers to C++'s raw "pointers" (for example: `MyType*`). While pointers may be unsafe, they are an important part of C++ code. The `Ptr<T>` type can be used to work with pointer types. Please note classes cannot be constructed while using the "pointer" memory management. Instead, they must reference values or come from external C++ functions.
```haxe
// ValueClass obj = ValueClass();
// ValueClass* ptr = &obj;
// ptr->doFunc();
var obj = new ValueClass();
var ptr: Ptr<ValueClass> = obj;
ptr.doFunc();
```

## Unique Pointer

A unique pointer is another standard library smart pointer. It works like a shared pointer, but it cannot be copied or moved. In return, it gives better performance. Simply wrap a type with `UniquePtr<T>` to make it a unique pointer, or have a class default it using `@:uniquePtrType`.
```haxe
// std::unique_ptr<UniqueClass> obj = std::make_unique<UniqueClass>();
var obj = new UniqueClass();

// std::unique_ptr<ValueClass> obj = std::make_unique<ValueClass>();
var obj2: UniquePtr<ValueClass> = new ValueClass();
```

