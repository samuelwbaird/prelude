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

--- Remove the last item in the list and return it
-- @function list:pop
-- @return The last item in the list
function prelude.list:pop()
	local length = #self
	if length > 0 then
		local value = self[length]
		self[length] = nil
		return value
	end
end

--- Remove the last item in the list and return it
-- @function list:is_empty
-- @return true if the list is empty
function prelude.list:is_empty()
	return next(self) == nil
end

--- Clear all items from the list
-- @function list:clear
-- @return The list for chaining
function prelude.list:clear()
	local length = #self
	while length > 0 do
		self[length] = nil
		length = length - 1
	end
	return self
end

--- Shallow copy a list returning a new list
-- @function list:clone
-- @return The new shallow copy
function prelude.list:clone()
	local new_list = prelude.list()
	for i, v in ipairs(self) do
		new_list[i] = v
	end
	return new_list
end
	
--- See if the list contains an item
-- @function list:contains
-- @param item The item to look for
-- @return true or false
function prelude.list:contains(item)
	for _, v in ipairs(self) do
		if v == item then
			return true
		end
	end
	return false
end
	
--- Get the index of an item within the list
-- @function list:index_of
-- @param item The item to look for
-- @return The index of the item or nil
function prelude.list:index_of(item)
	for i, v in ipairs(self) do
		if v == item then
			return i
		end
	end
end

--- Remove one or more occurances of an item
-- @function list:remove_item
-- @param item The item to look for
-- @param more_than_once Whether to remove multiple instances
-- @return The list for chaining
function prelude.list.remove_item(item, more_than_once)
	for i, v in ipairs(self) do
		if v == item then
			table.remove(self, i)
			if not more_than_once then
				return self
			end
		end
	end
	return self
end

--- Remove the item at a given index
-- @function list:remove
-- @param index The index to remove, if not numeric, this will be treated as an item to remove instead
-- @return The list for chaining
function prelude.list.remove(index)
	if type(index) ~= 'number' then
		self:remove_item(index)
	else
		table.remove(self, index)
	end
	return self
end

--- Remove items matching a predicate function
-- @function list:remove_where
-- @param predicate A function that returns true for any item that should be removed
-- @return The list for chaining
-- @usage
-- my_list:remove_where(function (item)
--   return item.score < 20
-- end)
function prelude.list.remove_where(predicate)
	for _, v in ipairs(self) do
		if predicate(v) then
			table.remove(self, i)
		end
	end
	return self
end

--- Return a new list, only including items that match a predicate
-- @function list:select
-- @param predicate A function that returns true for any item that should be in the new list
-- @return The new list of selected items
-- @usage
-- local high_performers = my_list:select(function (item)
--   return item.score > 100
-- end)
function prelude.list:select(predicate)
	local out = prelude.list()
	for _, v in ipairs(self) do
		if predicate(v) then
			out:push(v)
		end
	end
	return out
end

--- Return a new list, with all items transformed by a given function
-- @function list:map
-- @param fn A function that returns a new value mapped to each item
-- @return The new list of mapped results
function prelude.list:map(fn)
	local out = prelude.list()
	for i, v in ipairs(self) do
		out[i] = fn(v)
	end
	return out
end

--- Destructively update and remove items from the list
-- @function list:mutate
-- @param fn A function that returns a new value, or nil to remove values, for each item in the list
-- @return The list for chaining
function prelude.list:mutate(fn)
	local out = 0
	for i, v in ipairs(self) do
		local updated = fn(v)
		if updated then
			out = out + 1
			self[out] = updated
		end
	end
	local len = #self
	while len > out do
		self[len] = nil
		len = len - 1
	end
	return self
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

--- Include Lua table.concat
-- @function list:concat
prelude.list.concat = table.concat
--- Include Lua table.insert
-- @function list:insert
prelude.list.insert = table.insert
--- Include Lua table.maxn
-- @function list:maxn
prelude.list.maxn = table.maxn
--- Include Lua table.sort
-- @function list:sort
prelude.list.sort = table.sort


---------------------------------------------------------------------------------------

--- Meta tables
-- @section meta

--- Return a weak map
-- @param keys Specify if keys are weak (default is false)
-- @param values Specify if values are weak (default is true)
-- @return The new weak map
-- @usage
-- -- create a fully weak map
-- local fully_weak = weak_map(true)
-- local weak_values = weak_map()
function prelude.weak_map(keys, values)
	local mode = ''
	if type(keys) == 'boolean' and keys == true then
		mode = mode .. 'k'
	end
	if type(values) ~= 'boolean' or values == true then
		mode = mode .. 'v'
	end	
	return setmetatable({}, {
		__mode = mode
	})
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

--- Optionally prevent uninitialised writes as well
-- @return a reference to the prelude module for chaining
-- @usage
-- local prelude = require('prelude').strict()
-- local test = blah	-- fails due to uninitialised read
function prelude.strict(including_writes)
	setmetatable((_ENV or _G), {
		__index = function (obj, property)
			error('uninitialised read from global ' .. tostring(property), 2)
		end,
		__newindex = (including_writes and function (obj, property, value)
			error('uninitialised write to global ' .. tostring(property), 2)
		end or nil),
	})
	return prelude
end

--- Alternative to pcall that automatically adds a stack trace to the error
-- @param fn The function to call
-- @param ... and its arguments
function prelude.pcall_trace(fn, ...)
	local debug = require('debug')
	local handle_by_capturing_stack_trace = function (err)
		if debug then
			return debug.traceback(tostring(err), 3)
		else
			return tostring(err)
		end
	end
	
	return xpcall(function (...) return fn(...) end, handle_by_capturing_stack_trace)
end

return prelude