package cxx.num;

@:cxxStd
@:numberType(32, true, false)
@:native("float")
@:coreType
@:notNull
@:runtimeValue
extern abstract Float32 to Float from Float {

    @:op(-A)
    private static function neg(a: Float32) : Float32;

    @:op(--A)
    private static function predec(a: Float32) : Float32;

    @:op(++A)
    private static function preinc(a: Float32) : Float32;

    @:op(A--)
    private static function dec(a: Float32) : Float32;

    @:op(A++)
    private static function inc(a: Float32) : Float32;
    
    @:op(A + B)
    private static function add(a: Float32, b: Float32) : Float32;
    
    @:op(A - B)
    private static function sub(a: Float32, b: Float32) : Float32;
    
    @:op(A * B)
    private static function mul(a: Float32, b: Float32) : Float32;

    @:op(A / B)
    private static function div(a: Float32, b: Float32) : Float32;

    // C/C++ does not support modulo on float
    // @:op(A % B)
    // @:native("fmodf") -- maybe this
    // private static function mod(a: Float32, b: Float32) : Float32;

    // haxe.Float does not support bitwise on float, but C/C++ does
    // @:op(A | B)
    // private static function or(a: Float32, b: Float32) : Float32;

    // haxe.Float does not support bitwise on float, but C/C++ does
    // @:op(A & B)
    // private static function and(a: Float32, b: Float32) : Float32;

    // haxe.Float does not support bitwise on float, but C/C++ does
    // @:op(A ^ B)
    // private static function xor(a: Float32, b: Float32) : Float32;
}
