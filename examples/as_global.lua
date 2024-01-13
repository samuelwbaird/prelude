-- either dofile or require and immediately make all symbols in the prelude module global
-- dofile('prelude.lua').global()
require('prelude').global()

-- you can now use class or list as global keywords
-- create a new character class, and then populate a list of these characters

character = class()

function character:init(counter)
	self.name = 'Character ' .. counter
end

function character:__tostring()
	return self.name
end

local all_characters = list()
for i = 1,  20 do
	all_characters:push(character(i))
end

all_characters:with_each(function (character)
	print(character)
end)

print('And my favourite character is ' .. tostring(all_characters:random()))