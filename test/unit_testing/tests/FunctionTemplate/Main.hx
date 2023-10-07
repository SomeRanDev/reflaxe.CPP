package;

function main() {
	hasGeneric(123);
}

function hasGeneric<@:const T: Int>(@:templateArg(0) i: Int) {
	trace(untyped T);
}
