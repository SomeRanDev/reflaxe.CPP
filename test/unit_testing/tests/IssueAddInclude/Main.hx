package;

@:staticMethodInclude("cstdio")
class Test {
    @:native("printf")
    public static function bla(a: String) {}
}

function main() {
    Test.bla(@:cstr "asd");
}
