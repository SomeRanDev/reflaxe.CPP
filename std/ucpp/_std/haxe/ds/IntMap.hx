/*
 * Copyright (C)2005-2019 Haxe Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

package haxe.ds;

@:coreApi
class IntMap<T> implements haxe.Constraints.IMap<Int, T> {
	var m: ucpp.std.Map<Int, T>;

	public function new(): Void {
		m = new ucpp.std.Map<Int, T>();
	}

	public function set(key: Int, value: T): Void {
		m.insert(new ucpp.std.Pair<Int, T>(key, value));
	}

	public function get(key: Int): Null<T> {
		return if(exists(key)) {
			m.at(key);
		} else {
			null;
		}
	}

	public function exists(key: Int): Bool {
		return m.count(key) > 0;
	}

	public function remove(key: Int): Bool {
		return m.erase(key) > 0;
	}

	public function keys(): Iterator<Int> {
		final it = m.begin();
		final end = m.end();
		return {
			next: function() {
				return if(it != end) {
					final result: Int = it.first;
					it.increment();
					return result;
				} else {
					-1;
				}
			},
			hasNext: function() {
				return it != end;
			}
		}
	}

	public function iterator(): Iterator<T> {
		return {
			next: function() {
				return null;
			},
			hasNext: function() {
				return false;
			}
		}
	}

	public function keyValueIterator(): KeyValueIterator<Int, T> {
		return {
			next: function() {
				return null;
			},
			hasNext: function() {
				return false;
			}
		}
	}

	public function copy(): IntMap<T> {
		final result = new IntMap<T>();
		for(k in keys()) {
			result.set(k, get(k));
		}
		return result;
	}

	public function toString(): String {
		return "";
	}

	public function clear(): Void {
		m.clear();
	}
}
