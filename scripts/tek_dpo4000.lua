--[[

--]]
local ffi = require("ffi")
local math = require("math")
local inspect = require("inspect")
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
	sleep(3000)
	self.device:write(":MEASU:IMM:SOUrce1")
	self.device:write("HEADER OFF")
	self.device:write("AUTOSET EXEC")
	self.device:write("HOR:RECO 1000")
	sleep(3000)
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
	local setting = setting or {channel=1,type = 'amp'}
	local ret=nil
	buff   = ffi.new("uint8_t[256]")
	self.device:write(string.format("DATA:SOUR %d",setting.channel))
	self.device:write(string.format("MEASU:MEAS%d:TYP %s",setting.channel,setting.type))
	self.device:write(string.format("MEASU:MEAS%d:STATE ON",setting.channel))
	--self.device:write(string.format("MEASU:MEAS%d:VAL?",setting.channel))
	ret = self.device:ask(string.format("MEASU:MEAS%d:VAL?",setting.channel))
	--print(ret.value)
	
end
-- return an amplitude value but auto range device while collecting measurments.
function tek_dpo4000:powerset(setting)
	local setting = setting or {channel=1}
	local vertical_ranges   = {1.0E-3,2.0E-3,5.0E-3,10.0E-3,20.0E-3,50.0E-3,100.0E-3,200.0E-3,500.0E-3,1.0,2.0,5.0}
	local horizontal_ranges = {1.0,2.0,5.0,10.0};
	--trigger level to 0.00 volts.
	--self.device:write("TRIG:A SETL 0")
	self.device:write(string.format('TRIGger:A:LEVel:CH%d 0.0',setting.channel))
	--cmd.Format("DATA:SOUR %d",channel_set);
	
	ret = self.device:ask('TRIGger:EXTernal:PRObe?')
	local atten = tonumber(ret.value)
	--print(atten)

	ret = self.device:write(string.format("MEASU:MEAS%d:TYP PK2P",setting.channel))
	
	ret = self.device:write(string.format("MEASU:MEAS%d:STATE ON",setting.channel))
	
	sleep(100)
	ret = self.device:ask(string.format('MEASU:MEAS%d:VAL?',setting.channel))
	local peak = tonumber(ret.value)
	print(peak)
	
	local range=peak/6.0
	
	if range <= vertical_ranges[1] then
		range = vertical_ranges[1]
	else
		for i = 1, 12 ,1  do
			if vertical_ranges[i] < range and range <= vertical_ranges[i+1] then
			
				range=vertical_ranges[i+1];
				break;
			
			end
		end
	end
	
	ret = self.device:write(string.format("CH%d:SCA %f",setting.channel,range))
	time_div = 1.0/setting.frequency
	print (string.format("HORIZONTAL:SCALE %.2e",time_div))
	ret = self.device:write(string.format("HORIZONTAL:SCALE %.2e",time_div))
	
	
	--print(inspect(setting))
	--print(type(setting.frequency))
	
	--ret = self.device:write(string.format("REF%d:HORizontal:SCAle %f",setting.channel,))
	--local logtime = math.log10(3.0/setting.frequency)
	--local logfreq = math.log10( setting.frequency)
	--local exponent = math.floor(logfreq)
	--print(logfreq)
	--print(exponent)
	
    --local logmantissa = logfreq-exponent*1.0;
	--print(logmantissa)
    --local mantissa = math.pow(10.0,logmantissa)
	--print (mantissa)
	
	--exponent = exponent - 1.0;
	--range = mantissa*10.0 * math.pow(10.0,exponent-1)
	
	
	--[[
	if range <= horizontal_ranges[1]  then
		range = horizontal_ranges[1]
	else
		for i = 1, 12 do
			if horizontal_ranges[i] < range and range <= horizontal_ranges[i] then
				range=horizontal_ranges[i]
				break
			end
		end
	end
	-]]
	print (range)
end

function tek_dpo4000:trace(setting)
	local setting = setting or {channel=1}
	local ret=nil
	self.device:write("WFMI:YOFF?")

	buff   = ffi.new("uint8_t[256]")
	ret=self.device:read(buff,256)
	str = ffi.string(buff)
	--print(str)
	-- The DATa:SOUrce command specifies the waveform source when transferring a
	-- waveform from the oscilloscope.
	self.device:write(":DAT:SOU " .. string.format("%d",setting.channel))
	
	self.device:write("DATA:START 1")
    
    self.device:write("DATA:STOP 1000")
	
	--print(ret.value)
	
	--self.device:write("HOR:SCAl 2.0e-9")
	
	--self.device:write("HOR:SCAl 2.0e-9") --set time scale to 2.0 n seconds
	
	--self.device:write("WFMInpre:PT_Fmt ENV")
	
	ret = self.device:ask('WFMInpre:NR_Pt?')
	local points = tonumber(ret.value)
	--print(points)
	ret = self.device:ask('WFMPRE:YMULT?')
	local ymult = tonumber(ret.value)
	
	ret = self.device:ask('WFMPRE:YZERO?')
	local yzero = tonumber(ret.value)
	
	ret = self.device:ask('WFMPRE:YOFF?')
	local yoff = tonumber(ret.value)
	
	ret = self.device:ask('WFMPRE:XINCR?')
	local xincr = tonumber(ret.value)
	
	--ret = self.device:write("DATA:WIDTH 1")
	
	ret = self.device:write("DATA:ENCDG RIB")
	--ret = self.device:write("DATA:ENCDG FAS")
	self.device:write("CURVE?")
	
	--preamble #bb 
	local preamble  = ffi.new("uint8_t[2]") 
	
	ret=self.device:read(preamble,2)
	print (ret.ret)
	
	str = ffi.string(preamble)
	print(str)
	
	--[[
	local byte_count=tonumber(str:sub(2))
	--print(byte_count)
	local bytes=ffi.new("int8_t[?]",byte_count+1) 
	
	ret=self.device:read(bytes,byte_count)
	str = ffi.string(bytes)
	
	curve_bytes = tonumber(str)
	--print (tonumber(str))
	
	curve   = ffi.new("int8_t[?]",curve_bytes) 
	ret=self.device:read(curve,curve_bytes)
	
	for i = 0 , curve_bytes - 1 do
		intermediate = tonumber(curve[i]) * 1.0
		intermediate = intermediate - yoff
		intermediate = intermediate * ymult
		intermediate = intermediate + yzero
		
		print( intermediate) 
	end
	
	--]]
		
	--[[
	

	repeat 
	
		ret=self.device:read(curve,1024)
		for k,v in next, string.split(ffi.string(curve), ',') do print(v) end
	until ret.count[0] < 1024
	--]]
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