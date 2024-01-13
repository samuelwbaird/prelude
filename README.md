# Prelude

A Lua prelude for classes, lists and other useful meta methods. I'm consolidating my most used frequently used functionality from a larger and older codebase into a smaller standalone prelude, suitable for inclusion in other projects as a single file.

I'm attempting to maintain pure Lua compatibiity with 5.1, 5.2, 5.3 and 5.4, and avoid any external dependencies.

## Features

The primary features are a class constructor, a list class scaffolding use of tables as lists (both following Lua idiom), along with additional useful functions mostly related to metatables. See the documentation and examples folder for further reference.


Classes

 * class(), creates a new class constructor
 * list(), creates a new list object with additional conveniences for table access as a list

Metatables

 * weak__map(keys, values), construct a weak map

Global environment 

 * global(), publish the prelude to the global environment 
 * strict(block_writes), prevent uninitialised reads and optionally writes in the global environment
 * pcall__trace(fn), a wrapper for pcall that captures a stack trace where possible


## Usage

The prelude is intended to be included directly in other projects by copying the single file across, rather than as a tracked external dependency. If preferred this repo could be included as a git submodule


The prelude can be required as a scoped module:

	-- as a module
	local prelude = require('prelude')
	
	local Person = prelude.class()
	
	function Person:init(name)
		self.name = name
	end
	
	function Person:greet()
		print("Hi, I'm " .. self.name)
	end

	local sam = Person("Sam")
	sam:greet()


Or embedded into the global environment.

	-- include in the global environment
	dofile('prelude.lua').global()
	
	Person = class()
	
	function Person:init(name)
		self.name = name
	end

	function Person:greet()
		print("Hi, I'm " .. self.name)
	end

	local sam = Person("Sam")
	sam:greet()


## Examples

Run the examples from the project root file, ie.

	lua examples/as_module.lua
	lua examples/as_global.lua


## Documentation

To regenerate the documentation in /doc, install ldoc via luarocks and run:

	ldoc prelude.lua