-- local and isolated module, set strict mode
local prelude = require('prelude').strict()

function test()
	local variable = wrong_name
	return 42
end

-- generate an error due to strict mode, and then capture a full trace
local success, result = prelude.pcall_trace(test)
print('Success: ' .. tostring(success))
print('Result: ' .. tostring(result))