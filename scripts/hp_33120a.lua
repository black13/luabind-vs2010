local ffi = require("ffi")
ffi.cdef[[
void Sleep(int ms);
]]
function sleep(ms)
    ffi.C.Sleep(ms)
end
local inspect = require 'inspect'
local vclass = require 'vclass'

function format_value(value,unit)
	local prefix = {'','K','M','G'}
	local digits = (value >= 1.e9) and {9,3} or 
	      (value >= 1.e8) and {8,2} or
	      (value >= 1.e7) and {7,2} or
	      (value >= 1.e6) and {6,2} or
	      (value >= 1.e5) and {5,1} or
	      (value >= 1.e4) and {4,1} or
	      (value >= 1.e3) and {3,1} or
	      (value >= 1.e2) and {2,0} or
	      (value >= 1.e1) and {1,0} or {0,0}
	
	value = value * math.pow(1000.0,-digits[2 ])
	--local ret = string.format("%.2f%s",value,prefix[digits[2] + 1] .. unit)
	return (string.format("%.2f%s\r\n",value,prefix[digits[2] + 1] .. unit))
end
local hp_33120 = {}

hp_33120.__index = hp_33120

function hp_33120:new (o)
	--local o = o or {}
	local inst={}
	if type(o) == "table" then
		 for k,v in pairs(o) do
			 inst[k]=v
		 end
	end
	
	local device = vclass:new()
	local ret = device:open(inst.connect)
	inst.device = device
	
	setmetatable(inst, hp_33120)
	return inst
end

function hp_33120:open(connect_string)
	--print (connect_string)
end

function hp_33120:bus_init()

	self.device:write("*RST")
	self.device:write("*CLS")
	self.device:write("*ESE 0")
	sleep(1000)	
end

function hp_33120:freq(setting)
	self.device:write("FREQ "  .. format_value(setting ,'HZ'))
end

function hp_33120:power(setting,unit)

    if string.lower(unit) == 'dbm' then
		self.device:write("VOLT:UNIT " .. unit)
	end
	
	self.device:write("SOUR:VOLT "  .. format_value(setting ,""))
end

function hp_33120:stat(setting)
    --self.device:write("OUTPUT "  .. setting)
end

function hp_33120:close(setting)
	self.device:close()
end

return hp_33120