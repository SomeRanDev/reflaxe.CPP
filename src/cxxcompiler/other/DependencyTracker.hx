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

	// ----

	var id: String;
	var filename: Null<String> = null;
	var dependencies: Array<DependencyTracker> = [];
	var dependencyPositions: Array<Position> = [];
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

	public function addDep(t: ModuleType, pos: Position) {
		final dt = make(t);
		if(!dependencies.contains(dt) && dt != this) {
			dependencyPositions.push(pos);
			dependencies.push(dt);
		}
	}

	public function isThisDepOf(t: ModuleType): Bool {
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

		for(d in dependencies) {
			if(d.id == targetDep.id) {
				result = true;
				break;
			} else if(d.hasDep(targetDep)) {
				result = true;
				break;
			}
		}

		tracking = false;

		return result;
	}

	public static var errorStack: Array<{ id: String, pos: Position }> = [];

	public static function getErrorStackDetails() {
		return errorStack.map(function(data) {
			final id = data.id;
			final pos = data.pos;
		}).join("\n");
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
