--[[

--]]
local ffi = require("ffi")
ffi.cdef[[
void Sleep(int ms);
]]
function sleep(ms)
    ffi.C.Sleep(ms)
end
local inspect = require 'inspect'
local vclass = require 'vclass'

local tek_tds7254 = {}

tek_tds7254.__index = tek_tds7254

function tek_tds7254:new (o)
	local o = o or {}
	--print(inspect(o))
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
	setmetatable(inst, tek_tds7254)
	return inst
end

function tek_tds7254:bus_init()
	self.device:write("*RST")
	sleep(3000)
end



function tek_tds7254:readpt(setting)
	local setting = setting or {channel=1,type = 'amp'}
	local ret=nil
	buff   = ffi.new("uint8_t[256]")
	--self.device:write(string.format("DATA:SOUR %d",setting.channel))
end

function tek_tds7254:trace(setting)
	local setting = setting or {channel=1}
	local ret=nil
	--self.device:write("WFMI:YOFF?")

	buff   = ffi.new("uint8_t[256]")
	--ret=self.device:read(buff,256)
	str = ffi.string(buff)
	self.device:write(string.format("SELect:CH%d ON",setting.channel))
	--print(str)
	-- The DATa:SOUrce command specifies the waveform source when transferring a
	-- waveform from the oscilloscope.
	self.device:write("MEASU:IMM:TYPE PK2Pk")
	
	
	
	self.device:write("HORIZ:RECO 500")
	self.device:write("DATA:STAR 1")
    self.device:write("DATA:STOP 500")
	
	ret = self.device:ask('WFMOutpre:NR_Pt?')
	local points = tonumber(ret.value)
	--self.device:write("DATA:STOP %d")
	
	--print(	string.format(" points %d  ", points) )
	--ymult
	ret = self.device:ask('WFMOutpre:YMULT?')
	local ymult = tonumber(ret.value)
	--print(	string.format(" ymult %f  ", ymult) )
	--yoff
	ret = self.device:ask('WFMOutpre:YOFf?')
	local yoff = tonumber(ret.value)
	--print(	string.format(" yoff %f  ", yoff) )
	--yunit
	--ret = self.device:ask('WFMOutpre:YUNit?')
	--local yunit = tonumber(ret.value)
	--print(	string.format(" yunit %s  ", yunit) )
	--yzero
	ret = self.device:ask('WFMOutpre:YZEro?')
	local yzero = tonumber(ret.value)
	--print(	string.format(" yzero %f  ", yzero) )
	
	ret = self.device:write("WFMOutpre:BYT_Nr 1")
	
	ret = self.device:write("DATA:ENCDG RIB")
	self.device:write("CURVE?")
	
	--preamble #bb 
	local preamble  = ffi.new("uint8_t[2]") 
	
	ret=self.device:read(preamble,2)
	str = ffi.string(preamble)
	--print(	string.format(" preamble %s  ", str) )
	--print (ret.ret)
	
	local byte_count=tonumber(str:sub(2))
	--print(byte_count)
	local bytes=ffi.new("int8_t[?]",byte_count+1) 
	
	ret=self.device:read(bytes,byte_count)
	str = ffi.string(bytes)
	--print(	string.format(" byte count %s  ", str) )
	curve_bytes = tonumber(str)
	--print (tonumber(str))
	
	curve   = ffi.new("int8_t[?]",curve_bytes) 
	ret=self.device:read(curve,curve_bytes)
	--Yn = YZEro + YMUlt (Yn -- YOFf)
	
	--print ( "--curve--")
	for i = 0 , curve_bytes - 1 do
		intermediate = tonumber(curve[i]) * 1.0
		intermediate = intermediate - yoff
		intermediate = intermediate * ymult
		intermediate = intermediate + yzero
		
		print( intermediate) 
	end
end

function tek_tds7254:close(setting)
	self.device:close()
end

return tek_tds7254