local ffi = require("ffi")
ffi.cdef[[
void Sleep(int ms);
]]
function sleep(ms)
    ffi.C.Sleep(ms)
end
local inspect = require 'inspect'
local vclass = require 'vclass'

function freq_iter(start,stop,n)
	local step = (stop - start) / n
	local i=0
	local _n=n+1
	return function()
		local freq = start + step*i
		i=i+1
		if i > (_n) then 
			return nil
		end
		return freq
	end
end
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



local hp_8562a = {}

hp_8562a.__index = hp_8562a

function hp_8562a:new (o)
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
	setmetatable(inst, hp_8562a)
	return inst
end

function hp_8562a:bus_init()
	self.device:write("IP;")
	
	sleep(1000)
end

function hp_8562a:start_freq(setting)
	--print(":FREQ:STAR "  .. format_value(setting ,'HZ'))
	self.device:write(":FREQ:STAR "  .. format_value(setting ,'HZ'))
end

function hp_8562a:center(cent,span)
	self.device:write("SP "  .. format_value(span ,'HZ'))
	sleep(1000)
	self.device:write("CF "  .. format_value(cent ,'HZ'))
end

function hp_8562a:bandwidth()
	
end

--[[
10 OUTPUT 718;"IP;SNGLS;"
20 INPUT "ENTER IN DESIRED CENTER FREQUENCY, IN MHZ",Cf
30 INPUT "ENTER IN DESIRED FREQUENCY SPAN, IN MHZ",Sp
40 OUTPUT 718;"CF ";Cf;"MHZ;"
50 OUTPUT 718;"SP ";Sp;"MHZ;"
60 OUTPUT 718;"TS;MKPK HI;"
70 OUTPUT 718;"MKA?;AUNITS?;"
80 ENTER 718 USING "K";Mka,Aunits$
90 PRINT "HIGHEST PEAK IS",Mka,Aunits$
100 END
--]]
local function bandwidths(freq)	
	local ret = (freq >= 1.e9  )  and {rbw=1.e6,vbw=3.e6,span=2.e6} 	   or 
				(freq >= 10.e6 )  and {rbw=100.e3,vbw=300.e3,span=1.e6}  or
				(freq >= 150.e3)  and {rbw=10.e3,vbw=30.e3,span=100.0e3} or
				(freq >= 100.e3)  and {rbw=3.e3,vbw=30.e3,span=10.0e3} or
				(freq >= 10.e3 )  and {rbw=3.e3,vbw=9.e3,span=10.0e3}   or
				(freq >= 1.e3  )  and {rbw=100.0,vbw=300.0,span=500.0}   or
				(freq >= 100.0 )  and {rbw=10.0,vbw=30.0,span=50.0}      or
				{rbw=10.0,vbw=30.0,span=50.0}
	return ret
end

function hp_8562a:marker(o) -- for lack of a better argument name
    local ret = {}
	if o.single == true then
		self.device:write("SNGLS;")
	else
		self.device:write("CONTS;")
	end
	
	bwd=bandwidths(o.center)
	--print(inspect(bwd))
	
	self.device:write("SP "  .. format_value(bwd.span ,'HZ'))
	self.device:write("CF "  .. format_value(o.center ,'HZ'))
	self.device:write("RB ".. format_value(bwd.rbw ,'HZ'))
	self.device:write("VB ".. format_value(bwd.vbw ,'HZ'))
	
	self.device:write("TS;")
	self.device:write("MKPK HI;")
	self.device:write("MKA?")
	_ret=self.device:read(self.buff,256)
	--sleep(1000)
	str = ffi.string(self.buff)
	
	ret.ret=_ret
	ret.value = str
	
	return ret
end

function hp_8562a:stop(setting)
	self.device:write("FB "  .. format_value(setting ,'HZ'))
end

function hp_8562a:start(setting)
	self.device:write("FA "  .. format_value(setting ,'HZ'))
end

function hp_8562a:raw(setting)
	self.device:write(setting)
end

function hp_8562a:close(setting)
	self.device:close()
end


return hp_8562a