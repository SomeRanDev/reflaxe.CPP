package haxe;

@:cxxStd
@:coreApi
typedef PosInfos = {
	var fileName: String;
	var lineNumber: Int;
	var className: String;
	var methodName: String;
	var ?customParams: Array<cxx.DynamicToString>;
}