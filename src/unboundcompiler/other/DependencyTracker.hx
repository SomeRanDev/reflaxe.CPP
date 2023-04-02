// =======================================================
// * DependencyTracker
//
// Tracks depenencies for types by assigning each 
// a number. If a type relies on another type, it is
// assigned a larger number. These numbers can be
// used to determine the order of types compiled in the
// same file or find infinitely recursive dependencies.
// =======================================================

package unboundcompiler.other;

#if (macro || ucpp_runtime)

import haxe.macro.Type;

using reflaxe.helpers.ModuleTypeHelper;
using reflaxe.helpers.TypeHelper;

class DependencyTracker {
	public static final bottom: Int = 99999999;

	static var allDependencies: Map<String, DependencyTracker> = [];
	static var maxPriority: Int = 0;

	public static function make(t: ModuleType, filename: Null<String> = null): DependencyTracker {
		final id = t.getUniqueId();

		final tracker = if(!allDependencies.exists(id)) {
			final dt = new DependencyTracker(id);
			allDependencies.set(id, dt);
			dt;
		} else {
			allDependencies.get(id);
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
	var priority: Int;
	var tracking: Bool = false;

	function new(id: String) {
		this.id = id;
		priority = (maxPriority++);
	}

	function setFilename(fn: Null<String>) {
		if(fn != null && filename == null) {
			filename = fn;
		}
	}

	public function addDep(t: ModuleType) {
		final dt = make(t);
		if(!dependencies.contains(dt) && dt != this) {
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
		for(d in dependencies) {
			if(d.id == targetDep.id) {
				return true;
			} else if(d.hasDep(targetDep)) {
				return true;
			}
		}
		return false;
	}

	public function getPriority(): Int {
		if(tracking) {
			return -1;
		}
		tracking = true;

		var result = priority;

		for(d in dependencies) {
			if(d.id != id) {
				final p = d.getPriority();
				if(result <= p) {
					result = p + 1;
				} else if(p == -1) {
					return -1;
				}
			}
		}

		tracking = false;

		return result;
	}
}

#end
