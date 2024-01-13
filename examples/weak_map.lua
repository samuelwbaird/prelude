-- local and isolated module
local prelude = require('prelude')

-- create a default weak map (values only)
-- run a program that creates a number of throw away objects
-- each referenced by a sequential number

local map = prelude.weak_map()
for key = 1, 10000 do
	map[key] = {}
end

-- now lets set how many objects are still in that map
-- it will not be the full set of 10000
local count = 0
for k, v in pairs(map) do
	count = count + 1
end
print('objects remaining ' .. count)