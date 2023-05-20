// =======================================================
// * DependencyTracker
//
// Tracks depenencies for types by assigning each 
// a number. If a type relies on another type, it is
// assigned a larger number. These numbers can be
// used to determine the order of types compiled in the
// same file or find infinitely recursive dependencies.
// =======================================================

package cxxcompiler.other;

#if (macro || cxx_runtime)

import reflaxe.helpers.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

import reflaxe.helpers.PositionHelper;

using reflaxe.helpers.ModuleTypeHelper;
using reflaxe.helpers.NullHelper;
using reflaxe.helpers.TypeHelper;

import cxxcompiler.subcompilers.Types;

using cxxcompiler.helpers.CppTypeHelper;
using cxxcompiler.helpers.MetaHelper;

class DependencyTracker {
	public static final bottom: Int = 99999999;

	// Start from 10 to leave room for built-in stuff like includes and #pragma once
	public static final minimum: Int = 10;

	static var allDependencies: Map<String, DependencyTracker> = [];
	static var maxPriority: Int = DependencyTracker.minimum;

	public static function make(t: ModuleType, filename: Null<String> = null): DependencyTracker {
		final id = t.getUniqueId();

		final tracker = if(!allDependencies.exists(id)) {
			final dt = new DependencyTracker(id);
			dt.haxeClassName = {
				final baseType = t.getCommonData();
				baseType.pack.concat([baseType.name]).join(".");
			};
			allDependencies.set(id, dt);
			dt;
		} else {
			allDependencies.get(id).trustMe();
		}

		tracker.setFilename(filename);

		return tracker;
	}

	public static function exists(t: ModuleType): Bool {
		return allDependencies.exists(t.getUniqueId());
	}

	public static function find(id: String): Null<DependencyTracker> {
		return allDependencies.get(id);
	}

	// stack

	public static var errorStack: Array<{ id: String, pos: Position }> = [];
	public static var dependencyStack: Array<{ id: String, pos: Position }> = [];

	public static function getErrorStackDetails() {
		return generateDetails(errorStack);
	}

	public static function getDepStackDetails() {
		return generateDetails(dependencyStack);
	}

	static function generateDetails(stack: Array<{ id: String, pos: Position }>) {
		var result = [];
		var index = 0;
		for(s in stack) {
			final id = s.id;
			final pos = s.pos;
			result.push('(${++index}) ${find(id)?.haxeClassName ?? "<unknown>"} - $pos');
		}
		return "--- Dependency Chain ---\n" + result.join("\n") + "\n-------------------------";
	}

	// ----

	function valueTypeError(msg: String, t: Type, pos: Position) {
		if(forwardDeclaredIndex != null) {
			Sys.stderr().writeString(forwardDeclaredBlame[forwardDeclaredIndex] + "\n\n");
		}
		final typeName = #if macro haxe.macro.TypeTools.toString(t) #else Std.string(t) #end;
		return Context.error(~/\$typeName\$/g.replace(msg, typeName), pos);
	}

	public function cannotUseValueTypeError(t: Type, pos: Position) {
		final msg = "Cannot use the value-type $typeName$ here as it cannot be #included without causing recursive #include chain. View dependecy chain above.";
		return valueTypeError(msg, t, pos);
	}

	public function cannotConstructValueTypeError(t: Type, pos: Position) {
		final msg = "Cannot construct value-type $typeName$ here since it will be generated for header file that cannot #include its class. View dependecy chain above.";
		return valueTypeError(msg, t, pos);
	}

	// ----

	var id: String;
	var haxeClassName: String = "";
	var filename: Null<String> = null;
	var dependencies: Array<DependencyTracker> = [];
	var dependencyPositions: Array<Position> = [];
	var forwardDeclared: Array<DependencyTracker> = [];
	var forwardDeclaredBlame: Array<String> = [];
	var priority: Int;
	var tracking: Bool = false;

	function new(id: String) {
		this.id = id;
		priority = (maxPriority++);
	}

	public function toString() {
		return "DependencyTracker(" + id + ")";
	}

	function setFilename(fn: Null<String>) {
		if(fn != null && filename == null) {
			filename = fn;
		}
	}

	public function addForwardDeclared(t: ModuleType, blame: String) {
		final dt = make(t);
		if(!forwardDeclared.contains(dt) && dt != this) {
			forwardDeclared.push(dt);
			forwardDeclaredBlame.push(blame);
		}
	}
	
	static var forwardDeclaredIndex: Null<Int> = null;
	public function canUseInHeader(t: Type, checkValue: Bool = true): Bool {
		return if(!checkValue || Types.getMemoryManagementTypeFromType(t) == Value) {
			final mt = t.getInternalType().toModuleType();
			if(mt != null) {
				final index = forwardDeclared.indexOf(make(mt));
				forwardDeclaredIndex = index == -1 ? null : index;
				index == -1;
			} else {
				true;
			}
		} else {
			true;
		}
	}

	public function assertCanUseInHeader(t: Type, pos: Position, checkValue: Bool = true): Dynamic {
		return if(!canUseInHeader(t, checkValue)) {
			cannotUseValueTypeError(t, pos);
		} else {
			null;
		}
	}

	public function addDep(t: ModuleType, pos: Position) {
		// TODO: Would we ever want to track extern class dependencies ?
		if(t.getCommonData().isExtern) {
			return;
		}

		final dt = make(t);
		if(!dependencies.contains(dt) && dt != this) {
			dependencyPositions.push(pos);
			dependencies.push(dt);
		}
	}

	public function isThisDepOf(t: ModuleType): Bool {
		dependencyStack = [];

		if(!exists(t)) {
			return false;
		}

		if(t.getUniqueId() == id) {
			return false;
		}

		final target = make(t);
		return target.hasDep(this);
	}

	public function isThisDepOfType(t: Type): Bool {
		final mt = t.toModuleType();
		return if(mt != null) {
			isThisDepOf(mt);
		} else {
			false;
		}
	}

	public function hasDep(targetDep: DependencyTracker) {
		if(tracking) {
			return false;
		}

		tracking = true;

		var result = false;
		var resultIndex = -1;

		for(i in 0...dependencies.length) {
			final d = dependencies[i];
			if(d.id == targetDep.id) {
				result = true;
				resultIndex = i;
				break;
			} else if(d.hasDep(targetDep)) {
				result = true;
				resultIndex = i;
				break;
			}
		}

		tracking = false;

		if(result && resultIndex >= 0) {
			dependencyStack.push({ id: id, pos: dependencyPositions[resultIndex] });
		}

		return result;
	}

	public function getPriority(): Int {
		errorStack = [];
		final result = _getPriority();
		return result;
	}

	function _getPriority(): Int {
		if(tracking) {
			pushToErrorStack();
			tracking = false;
			return -1;
		}
		tracking = true;

		var result = priority;

		for(i in 0...dependencies.length) {
			final d = dependencies[i];
			if(d.id != id) {
				final p = d._getPriority();
				if(p == -1) {
					pushToErrorStack(dependencyPositions[i]);
					return -1;
				} else if(result <= p) {
					result = p + 1;
				}
			}
		}

		tracking = false;

		return result;
	}

	function pushToErrorStack(pos: Null<Position> = null) {
		errorStack.push({ id: id, pos: pos ?? PositionHelper.unknownPos() });
	}
}

#end
