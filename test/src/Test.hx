package;

function main() {
	trace("Hello world!");

	var a: Ptr<Int> = cast Stdlib.malloc(12);
	Stdlib.free(cast a);
}
