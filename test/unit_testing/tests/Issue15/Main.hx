package;

class Base {
    public function new() {}

    function overridden(a:String) {}
    function dummy(optional:Int=null) {}
}

class Child extends Base {
    override function overridden(a:String) {}
}

function main() {
	new Child();
}