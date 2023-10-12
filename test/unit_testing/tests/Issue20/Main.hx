package;

abstract Flexible(Int) {
    public function new()
        this = 1;

    @:to public function toAny<T>(): T
        return null;
}

function main() {
    var r: String = new Flexible().toAny();
    trace(r);
}
