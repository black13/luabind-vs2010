local ffi = require("ffi")
ffi.cdef[[
void Sleep(int ms);
]]
function sleep(ms)
    ffi.C.Sleep(ms)
end
local inspect = require 'inspect'
local vclass = require 'vclass'

local tek_dpo4000 = {}

tek_dpo4000.__index = tek_dpo4000

function tek_dpo4000:new (o)
	local o = o or {}
	print(inspect(o))
	local inst={}
	if type(o) == "table" then
		 for k,v in pairs(o) do
			 inst[k]=v
		 end
	end
	
	local device = vclass:new()
	
	local ret = device:open(inst.connect)
	inst.device = device
	inst.buff   = ffi.new("uint8_t[256]")
	setmetatable(inst, tek_dpo4000)
	return inst
end

function tek_dpo4000:bus_init()
	self.device:write("*RST")
	sleep(1000)
end

function tek_dpo4000:trace(setting)

end

function tek_dpo4000:close(setting)
	self.device:close()
end
--[[
local function main()
	print ('in main')
	local device = vclass:new()
	local ret = device:open('USB0::0x0699::0x0401::C020189::INSTR')
	print (ret)
	device:write("*RST")
end
--]]

return tek_dpo4000