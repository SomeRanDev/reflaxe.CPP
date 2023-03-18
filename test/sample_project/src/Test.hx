package;

@:topLevel
function test() {
	trace("in test");
}

function main() {
	test();

	trace("Hello", "world!", "Again");

	var bla = 123;
	if(bla == 123) {
		trace("It's 123!!");
	} else if(bla == 23) {
		trace("23");
	} else {
		trace("1");
	}
}