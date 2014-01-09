local ffi = require("ffi")
ffi.cdef[[
void Sleep(int ms);
]]
function sleep(ms)
    ffi.C.Sleep(ms)
end
function iter(start,stop,n)
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
local siggen   = require 'ag_n5181a'
local scope    = require 'tek_tds7254'
	local siggen   = siggen:new{connect='GPIB0::21::INSTR'}
	local tek    = scope:new{connect='GPIB0::30::INSTR'}
	siggen:bus_init()
	siggen:freq(500.0e3)
	siggen:power(-20.0,'dbm')	
	siggen:stat('1')
	-- 
	--tek:bus_init()
	
	--see if we can get data out this sucka!
	tek:trace{channel='1'}
	--tek:powerset{channel='1'}
	--[[
	tek:readpt{channel='1',type='RMS'}
	siggen:stat('1')
	local start=200.0e3
	local stop =1.0e6
	local steps=100
	
	for freq in iter(start,stop,steps) do
		siggen:freq(freq)
		
		
		for power in iter(-20,-10,10) do
			siggen:power(power,'DBM')
			sleep(500)
			tek:powerset{channel='1',frequency=freq}
		end
		print (string.format("%.2f",freq))
	end
	--]]
	siggen:power(-20.0,'dbm')
	siggen:close()
	tek:close()
end

--while true do
	main()
--end
