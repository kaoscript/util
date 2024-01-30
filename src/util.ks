/**
 * util.ks
 * Version 0.1.1
 * August 4th, 2017
 *
 * Copyright (c) 2017 Baptiste Augrain
 * Licensed under the MIT license.
 * http://www.opensource.org/licenses/mit-license.php
 **/
import 'npm:timsort' => TimSort

func $clone(value? = null) { # {{{
	if value == null {
		return null
	}
	else if value is Array {
		return value.clone()
	}
	else if value is Object {
		return Object.clone(value)
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
		if source[key] is Object {
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
		if ?source[key] {
			$merge(source, key, current[key])
		}
		else {
			source[key] = current[key]
		}
	}
} # }}}

impl Array {
	static {
		merge(...args): Array { # {{{
			var l = args.length
			var mut source = null
			var mut i = 0

			while i < l && !((source ?= args[i]) && source is Array) {
				i += 1
			}

			return [] unless source is Array

			i += 1

			while i < l {
				if args[i] is Array {
					for var value in args[i] {
						source.pushUniq(value)
					}
				}

				i += 1
			}

			return source
		} # }}}
		same(a: Array, b: Array): Boolean { # {{{
			if a.length != b.length {
				return false
			}

			for var i from 0 to~ a.length {
				if a[i] != b[i] {
					return false
				}
			}

			return true
		} # }}}
	}
	append(...args?): Array { # {{{
		for var k from 0 to~ args.length {
			var arg: Array = Helper.array(args[k])
			var l = arg.length

			if l > 50000 {
				var mut i = 0
				var mut j = 50000

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
		for i from 0 to~ args.length {
			if args[i] is Array {
				this.pushUniq(...args[i])
			}
			else {
				this.pushUniq(args[i])
			}
		}
		return this
	} # }}}
	any(fn): Boolean { # {{{
		for var item, index in this {
			return true if fn(item, index, this)
		}

		return false
	} # }}}
	clear(): Array { # {{{
		this.length = 0

		return this
	} # }}}
	clone(): Array { # {{{
		var mut i = this.length
		var clone = Array.new(i)

		while i > 0 {
			i -= 1

			clone[i] = $clone(this[i])
		}

		return clone
	} # }}}
	contains(item?, from: Number = 0): Boolean { # {{{
		return this.indexOf(item, from) != -1
	} # }}}
	intersection(...arrays) { # {{{
		var result = []
		var mut seen = false

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
			for var item in args {
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

			for var i from this.length - 1 to 0 step -1 when this[i] == item {
				this.splice(i, 1)
			}
		}
		else {
			for var item in items {
				for var i from this.length - 1 to 0 step -1 when this[i] == item {
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

impl Object {
	static {
		clone(object: Object): Object { # {{{
			if object.clone is Function {
				return object.clone()!!
			}

			var clone = {}

			for var value, key of object {
				clone[key] = $clone(value)
			}

			return clone
		} # }}}
		defaults(...args): Object => Object.merge({}, ...args)
		delete(object: Object, property): Void {
			Helper.delete(object, property)
		}
		isEmpty(object: Object): Boolean { # {{{
			for var value of object {
				return false
			}

			return true
		} # }}}
		key(object: Object, index: Number): String? { # {{{
			var mut i = 0

			for var _, key of object {
				if i == index {
					return key
				}

				i += 1
			}

			return null
		} # }}}
		length(object: Object): Number => Object.keys(object).length
		map(object: Object, fn: Function): Array => Object.entries(object).map(fn)
		merge(...args?): Object { # {{{
			var mut source = {}

			var mut i = 0
			var l = args.length
			var dyn src
			while i < l && !((src ?= args[i]) && src is Object) {
				i += 1
			}

			i += 1

			if ?src && src is Object {
				source = src
			}

			while i < l {
				if args[i] is Object {
					for var value, key of args[i] {
						$merge(source, key, value)
					}
				}

				i += 1
			}

			return source
		} # }}}
		same(a: Object, b: Object): Boolean { # {{{
			return false unless Array.same(Object.keys(a), Object.keys(b))

			for var value, key of a {
				if value != b[key] {
					return false
				}
			}

			return true
		} # }}}
		value(object: Object, index: Number): Any? { # {{{
			var mut i = 0

			for var value of object {
				if i == index {
					return value
				}

				i += 1
			}

			return null
		} # }}}
	}
}

impl String {
	dasherize(): String => this.replace(/([A-Z])/g, '-$1').replace(/[^A-Za-z0-9]+/g, '-').toLowerCase()
	toFirstLowerCase(): String => this.charAt(0).toLowerCase():!(String) + this.substring(1):!(String)
}
