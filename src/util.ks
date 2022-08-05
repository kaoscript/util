/**
 * util.ks
 * Version 0.1.1
 * August 4th, 2017
 *
 * Copyright (c) 2017 Baptiste Augrain
 * Licensed under the MIT license.
 * http://www.opensource.org/licenses/mit-license.php
 **/
import 'timsort' => TimSort

func $clone(value = null) { # {{{
	if value == null {
		return null
	}
	else if value is Array {
		return value.clone()
	}
	else if value is Dictionary {
		return Dictionary.clone(value)
	}
	else {
		return value
	}
} # }}}

func $merge(source, key, value) { # {{{
	if value is Array {
		source[key] = value.clone()
	}
	else if value is not Primitive {
		if source[key] is Dictionary || source[key] is Object {
			$mergeObject(source[key], value)
		}
		else {
			source[key] = $clone(value)
		}
	}
	else {
		source[key] = value
	}
	return source
} # }}}

func $mergeObject(source, current) { # {{{
	for var _, key of current {
		if source[key]? {
			$merge(source, key, current[key])
		}
		else {
			source[key] = current[key]
		}
	}
} # }}}

#[rules(non-exhaustive)]
extern {
	sealed class Array {
		length: Number
		slice(begin?, end?): Array
	}

	sealed class Dictionary {
		static {
			keys(...): Array<String>
		}
	}
}

impl Array {
	static {
		merge(...args): Array { # {{{
			var dyn source: Array = []

			var dyn i = 0
			var dyn l = args.length
			while i < l && !((source ?= args[i]) && source is Array) {
				++i
			}
			++i

			while i < l {
				if args[i] is Array {
					for value in args[i] {
						source.pushUniq(value)
					}
				}

				++i
			}

			return source
		} # }}}
		same(a, b): Boolean { # {{{
			if a.length != b.length {
				return false
			}

			for i from 0 til a.length {
				if a[i] != b[i] {
					return false
				}
			}

			return true
		} # }}}
	}

	append(...args?): Array { # {{{
		var dyn l, i, j, arg: Array
		for var k from 0 til args.length {
			arg = Helper.array(args[k])

			if (l = arg.length) > 50000 {
				i = 0
				j = 50000

				while i < l {
					this.push(...arg.slice(i, j))

					i = j
					j += 50000
				}
			}
			else {
				this.push(...arg)
			}
		}
		return this
	} # }}}
	appendUniq(...args?): Array { # {{{
		if args.length == 1 {
			this.pushUniq(...args[0])
		}
		else {
			for i from 0 til args.length {
				this.pushUniq(...args[i])
			}
		}
		return this
	} # }}}
	any(fn): Boolean { # {{{
		for item, index in this {
			return true if fn(item, index, this)
		}

		return false
	} # }}}
	clear(): Array { # {{{
		this.length = 0

		return this
	} # }}}
	clone(): Array { # {{{
		var dyn i = this.length
		var dyn clone = new Array(i)

		while i > 0 {
			clone[--i] = $clone(this[i])
		}

		return clone
	} # }}}
	contains(item?, from: Number = 0): Boolean { # {{{
		return this.indexOf(item, from) != -1
	} # }}}
	intersection(...arrays) { # {{{
		var result = []

		var dyn seen
		for var value in this {
			seen = true

			for var array in arrays while seen {
				if array.indexOf(value) == -1 {
					seen = false
				}
			}

			if seen {
				result.push(value)
			}
		}

		return result
	} # }}}
	last(index: Number = 1) { # {{{
		return this.length != 0 ? this[this.length - index] : null
	} # }}}
	pushUniq(...args?): Array { # {{{
		if args.length == 1 {
			if !this.contains(args[0]) {
				this.push(args[0])
			}
		}
		else {
			for item in args {
				if !this.contains(item) {
					this.push(item)
				}
			}
		}
		return this
	} # }}}
	remove(...items?): Array { # {{{
		if items.length == 1 {
			var dyn item = items[0]

			for var i from this.length - 1 to 0 by -1 when this[i] == item {
				this.splice(i, 1)
			}
		}
		else {
			for var item in items {
				for var i from this.length - 1 to 0 by -1 when this[i] == item {
					this.splice(i, 1)
				}
			}
		}

		return this
	} # }}}
	sort(compareFn): Array { # {{{
		TimSort.sort(this, compareFn)

		return this
	} # }}}
}

impl Dictionary {
	static {
		clone(dict: Dictionary): Dictionary { # {{{
			if dict.clone is Function {
				return dict.clone()!!
			}

			var dyn clone = {}

			for var value, key of dict {
				clone[key] = $clone(value)
			}

			return clone
		} # }}}
		defaults(...args): Dictionary => Dictionary.merge({}, ...args)
		isEmpty(dict: Dictionary): Boolean { # {{{
			for var value of dict {
				return false
			}

			return true
		} # }}}
		key(dict: Dictionary, index: Number): String? { # {{{
			var dyn i = -1

			for var _, key of dict {
				if ++i == index {
					return key
				}
			}

			return null
		} # }}}
		length(dict: Dictionary): Number => Dictionary.keys(dict).length
		merge(...args?): Dictionary { # {{{
			var dyn source: Dictionary = {}

			var dyn i = 0
			var dyn l = args.length
			var dyn src
			while i < l && !((src ?= args[i]) && src is Dictionary) {
				++i
			}
			++i

			if ?src && src is Dictionary {
				source = src
			}

			while i < l {
				if args[i] is Dictionary || args[i] is Object {
					for var value, key of args[i] {
						$merge(source, key, value)
					}
				}

				++i
			}

			return source
		} # }}}
		value(dict: Dictionary, index: Number): Any? { # {{{
			var dyn i = -1

			for var value of dict {
				if ++i == index {
					return value
				}
			}

			return null
		} # }}}
	}
}
