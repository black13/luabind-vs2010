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

local tek_dpo4000 = {}

tek_dpo4000.__index = tek_dpo4000

function tek_dpo4000:new (o)
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
	setmetatable(inst, tek_dpo4000)
	return inst
end

function tek_dpo4000:bus_init()
	self.device:write("*RST")
	
	self.device:write(":MEASU:IMM:SOUrce1")
	self.device:write("HEADER OFF")
	self.device:write("AUTOSET EXEC")
	self.device:write("HOR:REC 1000")
	--[[
	if (Write(inst,"*RST")) return(TRUE);
		DoDelay(3000);
	
		cmd.Format(":MEASU:IMM:SOUrce%d", channel_set);
		if (Write(inst,cmd)) return(TRUE);
		DoDelay(3000);
		////turn off header-return channel info only
		if (Write(inst, "HEADER OFF\r\n")) return(TRUE);
		if (Write(inst,":AUTOSET EXEC")) return(TRUE);

		cmd.Format("HOR:RECO %d",m_num_points);
		if (Write(inst,cmd)) return(TRUE);
	--]]
	
	sleep(1000)
end

function string:split(sSeparator, nMax, bRegexp)
	assert(sSeparator ~= '')
	assert(nMax == nil or nMax >= 1)

	local aRecord = {}

	if self:len() > 0 then
		local bPlain = not bRegexp
		nMax = nMax or -1

		local nField=1 nStart=1
		local nFirst,nLast = self:find(sSeparator, nStart, bPlain)
		while nFirst and nMax ~= 0 do
			aRecord[nField] = self:sub(nStart, nFirst-1)
			nField = nField+1
			nStart = nLast+1
			nFirst,nLast = self:find(sSeparator, nStart, bPlain)
			nMax = nMax-1
		end
		aRecord[nField] = self:sub(nStart)
	end

	return aRecord
end

function tek_dpo4000:readpt(setting)

end

function tek_dpo4000:trace(setting)
	local setting = setting or {channel=1}
	local ret=nil
	self.device:write("WFMI:YOFF?")

	buff   = ffi.new("uint8_t[256]")
	ret=self.device:read(buff,256)
	str = ffi.string(buff)
	print(str)
	self.device:write(":DAT:SOU CH1")
	
	--print(ret.value)
	
	self.device:write("HOR:SCAl 2.0e-9")
	
	--self.device:write("HOR:SCAl 2.0e-9") --set time scale to 2.0 n seconds
	
	self.device:write("WFMInpre:PT_Fmt ENV")
	
	ret = self.device:ask('WFMInpre:NR_Pt?')
	local points = tonumber(ret.value)
	print(points)
	ret = self.device:ask('WFMPRE:YMULT?')
	local ymult = tonumber(ret.value)
	
	ret = self.device:ask('WFMPRE:YZERO?')
	local yzero = tonumber(ret.value)
	
	ret = self.device:ask('WFMPRE:YOFF?')
	local yoff = tonumber(ret.value)
	
	ret = self.device:ask('WFMPRE:XINCR?')
	local xincr = tonumber(ret.value)
	
	self.device:write("CURVE?")
	 
	curve   = ffi.new("uint8_t[1024]") 
	--ret=self.device:read(curve,1024)
	--print(tonumber(ret.count[0]))
	
	repeat 
		ret=self.device:read(curve,1024)
		for k,v in next, string.split(ffi.string(curve), ',') do print(v) end
	until ret.count[0] < 1024
	
	--print(inspect(ret))
	--[[
	--from python
	ymult = float(scope.ask('WFMPRE:YMULT?'))
	yzero = float(scope.ask('WFMPRE:YZERO?'))
	yoff = float(scope.ask('WFMPRE:YOFF?'))
	xincr = float(scope.ask('WFMPRE:XINCR?'))
	--]]
	--str = ffi.string(ret.value)
	--print(tonumber(ret.value))
	--print(inspect(ret))
	--HORizontal:SCAle <NR3>
	--HORizontal:SCAle?
	
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