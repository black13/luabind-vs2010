local ffi = require("ffi")

ffi.cdef[[
void Sleep(int ms);
]]
function sleep(ms)
    ffi.C.Sleep(ms)
end

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

local function main()
local analyzer = require 'rigol'
local siggen   = require 'ag_n5181a'
local monitor  = require 'rs_fsp'

local siggen   = siggen:new{connect='GPIB0::21::INSTR'}
local analyzer = analyzer:new{connect='USB0::0x1AB1::0x0960::DSA8A134700019::INSTR'}
local monitor  = monitor:new{connect='GPIB0::20::INSTR'}

monitor:bus_init()
siggen:bus_init()
analyzer:bus_init()

	local start=100.0e3
	local stop=1.0e9
	local steps=25
	
	siggen:freq(start)
	analyzer:center(start,100.0e3)
	monitor:center(start,100.0e3)
		
	for freq in freq_iter(start,stop,steps) do
		siggen:freq(freq)
		
		siggen:stat('1')
		siggen:power(-40.0,'DBM')
		--analyzer:center(freq,100.0e3)
		monitor:center(freq,100.0e3)
		sleep(1000)
	end	
	
	siggen:stat('0')
	
	
	siggen:close()
	analyzer:close()
	monitor:close()
end

main()