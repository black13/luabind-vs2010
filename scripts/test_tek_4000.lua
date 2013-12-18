local ffi = require("ffi")

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
local siggen   = require 'ag_n5181a'
local scope    = require 'tek_dpo4000'
	local siggen   = siggen:new{connect='GPIB0::21::INSTR'}
	local tek    = scope:new{connect='USB0::0x0699::0x0401::C020189::INSTR'}
	--siggen:bus_init()
	siggen:freq(500.0e3)
	siggen:power(-20.0,'dbm')	
	siggen:stat('1')
	-- 
	tek:bus_init()
	--see if we can get data out this sucka!
	tek:trace{channel='1'}
	siggen:close()
	tek:close()
end

main()
