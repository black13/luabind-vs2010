local ffi = require("ffi")
ffi.cdef[[
void Sleep(int ms);
]]
function sleep(ms)
    ffi.C.Sleep(ms)
end
local inspect = require 'inspect'
local vclass = require 'vclass'
--local util   = require 'util'

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
	local ret = string.format("%.2f%s",value,prefix[digits[2] + 1] .. unit)
	return (string.format("%.2f%s",value,prefix[digits[2] + 1] .. unit))
end
local ag_n5181a = {}

ag_n5181a.__index = ag_n5181a

function ag_n5181a:new (o)
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
	
	setmetatable(inst, ag_n5181a)
	return inst
end

function ag_n5181a:open(connect_string)
	--print (connect_string)
end

function ag_n5181a:bus_init()

	self.device:write("*RST;*CLS")
	sleep(1000)	
end

function ag_n5181a:freq(setting)
	--print(":FREQ:STAR "  .. format_value(setting ,'HZ'))
	self.device:write("FREQ:FIXED "  .. format_value(setting ,'HZ'))
end

function ag_n5181a:power(setting,unit)
	self.device:write("POW:AMPL "  .. format_value(setting ,unit))
end

function ag_n5181a:stat(setting)
	self.device:write("OUTP:STAT "  .. setting)
end

function ag_n5181a:close(setting)
	self.device:close()
end

return ag_n5181a