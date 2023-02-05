package haxe;

typedef PosInfos = {
	var fileName: String;
	var lineNumber: Int;
	var className: String;
	var methodName: String;
	var ?customParams: Array<String>;
}