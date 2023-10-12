package;

abstract Flexible(Int) {
    public function new()
        this = 1;

    @:to public function toAny<T>(): T
        return null;
}

/**
	TODO: Fix Issue #20.

	Problem: The return is typed as `TMono(null)` while compiling the `TCall` expression.
	Not really sure how to resolve this without being too messy.
**/
function main() {
    // var r: String = new Flexible();
    // trace(r);
}
