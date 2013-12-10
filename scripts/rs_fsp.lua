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
	return (string.format("%.2f%s",value,prefix[digits[2] + 1] .. unit))
end

local rs_fsp = {}

rs_fsp.__index = rs_fsp

function rs_fsp:new (o)
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
	inst.buff   = ffi.new("uint8_t[256]")
	setmetatable(inst, rs_fsp)
	return inst
end

function rs_fsp:bus_init()
	self.device:write("SYST:PRESET;")
	self.device:write("SYST:DISP:UPD ON;")
	self.device:write("INST SAN;")
	self.device:write("SWE:POIN 1001;")
	sleep(1000)
end

function rs_fsp:center(cent,span)
	self.device:write("SENSE:FREQ:SPAN "  .. format_value(span ,'HZ'))
	sleep(1000)
	self.device:write("SENSE:FREQ:CENT "  .. format_value(cent ,'HZ'))
end

function rs_fsp:close(setting)
	self.device:close()
end

return rs_fsp