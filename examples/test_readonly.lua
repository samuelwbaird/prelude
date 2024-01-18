-- local and isolated module, set strict mode
local prelude = require('prelude').strict()

function test(label, fn, expected)
	local success, error = pcall(fn)
	print('Test: ' .. label .. ' : ' .. (success and 'success' or 'fail   ') .. ' - ' .. ((success == expected) and 'expected' or 'UNEXPECTED'))
	-- if not success then
	-- 	print(error)
	-- end
end

-- create a set of objects to test with
local source = {
	field1 = 'Some info',
	field2 = 'Some other info',
	related_object = {
		count = 1
	},
	method = function (self)
		self.updated = true
	end
}

print('Source object: ' .. prelude.pretty(source))

-- a shallow read only copy
local shallow = prelude.readonly(source)
-- should not be possible
test('shallow: write to a readonly field', function () shallow.field1 = 'test' end, false)
-- is not protected by a shallow copy
test('shallow: write to a related object', function () shallow.related_object.count = shallow.related_object.count + 1 end, true)
-- methods are not proxied to allow writes in the method
test('shallow: method call with updates ', function () shallow:method() end, false)

-- a deep read only copy applies read only wrapping on referenced objects,
-- and proxies functions that might update data to still work
local deep = prelude.readonly(source, true)
-- should not be possible
test('deep: write to a readonly field', function () deep.field1 = 'test' end, false)
-- is protected by a shallow copy
test('deep: write to a related object', function () deep.related_object.count = deep.related_object.count + 1 end, false)
-- methods are proxied to allow writes in the method
test('deep: method call with updates ', function () deep:method() end, true)

-- testing pairs/ipairs access only works on 5.2 and above
print('Test pairs/ipairs - on 5.2 and above')
for k, v in pairs(shallow) do
	print(k .. ' ' .. type(v))
end