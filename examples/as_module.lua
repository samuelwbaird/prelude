-- local and isolated module used via require
local prelude = require('prelude')

-- assert that the prelude is not in the global namespace
assert(class == nil, 'class should not be globally available')

-- everything from the prelude is contained in this module
-- use prelude.class, prelude.list etc.

-- create a new character class, and then populate a list of these characters

local character = prelude.class()

function character:init(counter)
	self.name = 'Character ' .. counter
end

function character:__tostring()
	return self.name
end

local all_characters = prelude.list()
for i = 1,  20 do
	all_characters:push(character(i))
end

all_characters:with_each(function (character)
	print(character)
end)

print('And my favourite character is ' .. tostring(all_characters:random()))