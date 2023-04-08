package;

function main() {
	final arr = [1, 2, 3];
	final m = [1 => 1, 2 => 2];
	final regex = ~/[a-zA-Z]+/;

	trace(arr);
	trace(m);
	trace(regex);

	Sys.println(arr);
	Sys.println(m);
	Sys.println(regex);
}
