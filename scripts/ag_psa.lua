local ffi = require("ffi")
ffi.cdef[[
void Sleep(int ms);
]]
function sleep(ms)
    ffi.C.Sleep(ms)
end
local v = require "vclass"


function freq_iter(start,stop,n)
	local step = (stop - start) / n
	local i=0
	return function()
		local freq = start + step*i
		i=i+1
		if i > n then 
			return nil
		end
		return freq
	end
end

local function eng(value,digits,unit)
	local expof10 = math.floor(math.log10(value))
	--              0  1  2   3   4  5   6  7  8  9
	local prefix = {'','','','K','K','K','M','M','M','G'}
	if(expof10 > 0) then
		expof10 = (expof10/3)*3
	else
		expof10 = (-expof10/3)*(-3)
	end	
	value = value * math.pow(10.0,-expof10)
	if (value >= 1000.0) then
		value = value / 1000.0
		expof10 = expof10 + 3
	elseif (value >= 100.0) then
		digits = digits - 2
	elseif (value >= 10.0) then
		digits = digits - 1
	end
	--print (value)
	--print (expof10)
	--return string.format("%.2fe%d",value,expof10)
	return string.format("%.2f %s",value,prefix[expof10]) .. unit
end

function jump_jack_flash(value,unit)
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
	--print (value)
	value = value * math.pow(1000.0,-digits[2 ])
	return (string.format("%.2f %s",value,prefix[digits[2] + 1] .. unit))
	--return string.format("%d %d %s" , digits[1],digits[2] , prefix[digits[2] + 1] .. unit)
	--return digits
end


local ag_psa = v.new()
local sig_gen = v.new()
local ret
ret = ag_psa:open("GPIB0::30::INSTR")
ret = sig_gen:open("GPIB0::15::INSTR")


--id=ffi.string(ret.buf,ret.count[0])
--print(id)
-- setup the the signal generator
--sig_gen:write("FUNC SIN") -- single tone
--sig_gen:write("VOLT:UNIT DBM")
--sig_gen:write("OUTPUT ON")
sig_gen:write("VOLT -21.0 DBM")
--sig_gen:write("FREQ 10.0 MHZ")
-- setup the psa
ag_psa:write(":SYST:PRES;")
ag_psa:write("SENS:SWE:POIN 1001")
ag_psa:write("SENS:DET POS")
ag_psa:write("UNIT:POW DBM")

--ag_psa:write(":SENS:FREQ:STAR 220.0 KHZ")
--ag_psa:write(":SENS:FREQ:STOP 20.0 MHZ")

ag_psa:write(":INIT:CONT OFF")
--ag_psa:write("CALC:MARK1:STAT ON")
--ag_psa:write(":SWE:TYPE AUTO")
--ag_psa:write(":INIT:IMM;")
ag_psa:write(":SWE:TIME:AUTO ON")
ag_psa:write("SENS:SWE:POIN 1001")
ag_psa:write(":BWID:RES "  .. jump_jack_flash(10000.0 ,'HZ'))
ag_psa:write(":BWID:VID "  .. jump_jack_flash(30000.0 ,'HZ'))

local start=100.0e3
local stop=15.0e6
local steps=25

buff   = ffi.new("uint8_t[256]")
sleep(1000)
for freq in freq_iter(start,stop,5) do
      sleep(100)
	  sig_gen:write('FREQ ' .. jump_jack_flash(freq ,'HZ'))
	  ag_psa:write(':FREQ:CENT ' .. jump_jack_flash(freq + 1000.0,'HZ'))
	  ag_psa:write(':FREQ:SPAN ' .. jump_jack_flash(100000.0,'HZ'))
	  
	  ag_psa:write(":INIT:IMM;")
	  sleep(1000)
	  ag_psa:write(":CALC:MARK1:MAX")
	  ag_psa:write(":CALC:MARK1:Y?")
	  ret=ag_psa:read(buff,256)
	  str = ffi.string(buff)
	  print(str)
end


buff = ffi.new("uint8_t[256]")
local str=''

--sig_gen:write('FREQ ' .. jump_jack_flash(15.0e6,'HZ'))
ag_psa:write(":INIT:IMM;")
ag_psa:write("*OPC?")

ret=ag_psa:read(buff,256)
str = ffi.string(buff)
print(str)

ag_psa:write("CALC:MARK1:MAX")
sleep(1000)
ag_psa:write("CALC:MARK1:Y?")
ret=ag_psa:read(buff,256)
str = ffi.string(buff)
print(str)

ag_psa:close()
sig_gen:close()
-- close visa session
v:close_session()