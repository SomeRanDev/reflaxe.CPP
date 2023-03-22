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
class StringMap<T> implements haxe.Constraints.IMap<String, T> {
	var m: ucpp.std.Map<String, T>;

	public function new(): Void {
		m = new ucpp.std.Map<String, T>();
	}

	public function set(key: String, value: T): Void {
		m.insert(new ucpp.std.Pair<String, T>(key, value));
	}

	public function get(key: String): Null<T> {
		return if(exists(key)) {
			m.at(key);
		} else {
			null;
		}
	}

	public function exists(key: String): Bool {
		return m.count(key) > 0;
	}

	public function remove(key: String): Bool {
		return m.erase(key) > 0;
	}

	public function keys(): Iterator<String> {
		final it = m.begin();
		final end = m.end();
		return {
			next: function() {
				return if(it != end) {
					final result: String = it.first;
					it.increment();
					return result;
				} else {
					"";
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

	public function keyValueIterator(): KeyValueIterator<String, T> {
		return {
			next: function() {
				return null;
			},
			hasNext: function() {
				return false;
			}
		}
	}

	public function copy(): StringMap<T> {
		final result = new StringMap<T>();
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
