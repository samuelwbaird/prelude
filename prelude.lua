--[[--
 A general purpose prelude for Lua with no additional dependencies.
 Provide basic classes, lists and other useful meta-functionality.
]]

local prelude = {}

---------------------------------------------------------------------------------------

--- Class meta constructor,
-- creates a new class metatable, which also functions as the constructor for that class,
--  @return A new class metatable/constructor
-- @usage 
-- -- add methods to the class metatable as needed
-- -- add an init method to your class to make use of any arguments on construction
-- local NewClass = prelude.class()
-- function NewClass:init(tag)
--   self.tag = tag
-- end
-- function NewClass:announce()
--   print('my tag is ' .. self.tag)
-- end
-- -- now construct objects using our new class
-- local newObj = NewClass('special')
-- newObj:announce()

function prelude.class()
	-- create a class metatable
	local class_meta = {}
	class_meta.__index = class_meta
	-- assign a metatable to the class metatable that allows the class to be used directly as a constructor function
	setmetatable(class_meta, {
		__call = function (class_meta, ...)
			local obj = {}
			setmetatable(obj, class_meta)
			if obj.init then
				obj:init(...)
			end
			return obj
		end,
	})
	-- return the new class for use
	return class_meta	
end

---------------------------------------------------------------------------------------

--- List class
-- @section list

prelude.list = prelude.class()

--- List constructor
-- @function list
-- @param arg1 optionally a single table to (shallow) copy into the new list
-- @param ... or, an open number of parameters to add as items in the new list
-- @return the new list object
-- @usage
-- local empty_list = prelude.list()
-- local cloned_list = prelude.list({ 1, 2, 3 })
-- local parmeter_list = prelude.list(obj1, obj2, obj3)
function prelude.list:init(arg1, arg2, ...)
	if type(arg1) == 'table' and #arg1 > 0 and arg2 == nil then
		-- copy from this list
		for i, v in ipairs(arg1) do
			self[i] = v
		end
	elseif arg1 then
		-- add argument items individually
		self:push(arg1, arg2, ...)
	end	
end

--- Add an item to the end of the list
-- @function list:push
-- @param item the item to add to the list
-- @param ... optionally additional items to add
-- @return The item that was added
function prelude.list:push(item, additional, ...)
	self[#self + 1] = item
	if additional then
		self:push(additional, ...)
	end
	return item
end

--- Call a function with each member of the list
-- @function list:with_each
-- @param fn to call with each member
-- @usage
-- my_list:with_each(function (item)
--   item:update()
-- end)
function prelude.list:with_each(fn)
	for _, v in ipairs(self) do
		fn(v)
	end
end

--- Return a random member of the list
-- @function list:random
-- @return A random member of the list, or nil if empty
function prelude.list:random()
	return #self > 0 and self[math.random(#self)]
end

--- Destructively shuffle the order of the list
-- @function list:shuffle
function prelude.list:shuffle()
    for i = #self, 2, -1 do
      local j = math.random(i)
      self[i], self[j] = self[j], self[i]
    end
end

--- Convert the list to a string when required
-- @function list:__tostring
-- @return A square brackets string representation of the list
function prelude.list:__tostring()
	local strings = {}
    for i, v in ipairs(self) do
		strings[i] = tostring(v)
	end
	return '[' .. table.concat(strings, ', ') .. ']'
end

---------------------------------------------------------------------------------------

--- Global environment
-- @section global

--- Optionally make everything in the preload global
-- @return a reference to the prelude module for chaining
-- @usage 
-- require('prelude').global()
-- local my_list = list()
function prelude.global()
	for k, v in pairs(prelude) do
		(_ENV or _G)[k] = v
	end
	-- chain any additional calls
	return prelude
end

return prelude