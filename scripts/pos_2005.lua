local ffi = require("ffi")
ffi.cdef[[
void Sleep(int ms);
]]
function sleep(ms)
    ffi.C.Sleep(ms)
end
local inspect = require 'inspect'
local vclass = require 'vclass'

local pos_2005 = {}

pos_2005.__index = pos_2005

function pos_2005:new (o)
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
	
	setmetatable(inst, pos_2005)
	return inst
end

function pos_2005:open(connect_string)
	--print (connect_string)
end

function pos_2005:cp()
	self.device:write("AXIS1:CP?\n")
	buff   = ffi.new("uint8_t[256]")
	self.device:read(buff,256)
	str = ffi.string(buff)
	print (str)
end

function pos_2005:sk(value)
	--self.device:write("AXIS1:SK 180\n")
	self.device:write("AXIS1:SK " .. value .. "\n")
	
	buff   = ffi.new("uint8_t[256]")
	while true do
        self.device:write("AXIS1:*OPC?\n")
	    self.device:read(buff,256)
	    str = ffi.string(buff)
	    print (str)
		if tonumber(str) == 1 then
			break
		end
    end
	
end
function pos_2005:bus_init()	
	sleep(1000)	
end

function pos_2005:close(setting)
	self.device:close()
end

return pos_2005