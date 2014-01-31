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
	--local ret = string.format("%.2f%s",value,prefix[digits[2] + 1] .. unit)
	return (string.format("%.2f%s",value,prefix[digits[2] + 1] .. unit))
end
local rigol = {}

rigol.__index = rigol

function rigol:new (o)
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
	--inst.device:write("*RST")
	setmetatable(inst, rigol)
	return inst
end

function rigol:open(connect_string)
	--print (connect_string)
end

function rigol:bus_init()
	--print (self.device)
	self.device:write("*RST")
	sleep(1000)
	--self.device:write(":FREQ:STOP "  .. format_value(200000.0 ,'HZ'))
	--self.device:write(":FREQ:STOP 200KHZ")
end

function rigol:start_freq(setting)
	--print(":FREQ:STAR "  .. format_value(setting ,'HZ'))
	self.device:write(":FREQ:STAR "  .. format_value(setting ,'HZ'))
end

function rigol:center(cent,span)
	self.device:write(":FREQ:CENT "  .. format_value(cent ,'HZ'))
	self.device:write(":FREQ:SPAN "  .. format_value(span ,'HZ'))
end

function rigol:count(setting)
	local ret = {}
	
	local setting = setting or {count=1,swtime=1.0}
    
	if type(setting.count) == nil then
		--error("no title")
		setting.count = 1
	end
	
	if type(setting.count) == nil then
		--error("no title")
		setting.count = 1
	end 
	
	if setting.swtime == nil then
		setting.swtime = 1
	end 
	buff   = ffi.new("uint8_t[256]")
	self.device:write(":INIT:CONT OFF")
	self.device:write(":SWE:TIME " .. setting.swtime)
	self.device:write(":SWE:COUN "  .. setting.count)
	self.device:write(":INIT")
	
	while true do
		self.device:write(":SWE:COUN:CURR?")
		self.device:read(buff,256)
		str = ffi.string(buff)
		sleep(setting.count*100)
		print (tonumber(str))
		if tonumber(str) == 10 then
			break
		end
		
		
	end

end

function rigol:marker()
    local ret = {}
	
	
	self.device:write(":INIT:CONT OFF")
	self.device:write(":INIT")
	
	buff   = ffi.new("uint8_t[256]")
	self.device:write("*OPC?")
	local _ret=self.device:read(buff,256)
	--print(_ret)
	local str = ffi.string(buff)
	
	self.device:write(":CALC:MARK1:MAX:MAX")
	self.device:write(":CALC:MARK1:Y?")
	_ret=self.device:read(buff,256)
	sleep(1000)
	str = ffi.string(buff)
	--print(str)
	ret.ret=_ret
	ret.value = str
	return ret
end

function rigol:stop_freq(setting)
	--print(":FREQ:STAR "  .. format_value(setting ,'HZ'))
	self.device:write(":FREQ:STOP "  .. format_value(setting ,'HZ'))
end

function rigol:start(setting)
	--print (setting)
end

function rigol:close(setting)
	self.device:close()
end

return rigol