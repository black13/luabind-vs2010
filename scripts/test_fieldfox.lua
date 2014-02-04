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
local analyzer = require 'ag_fieldfox'
local siggen   = require 'hp_33120a'
	local ana	=analyzer:new{connect='A-N9917A-01608'}
	local siggen=siggen:new{connect='GPIB0::15::INSTR'}
	-- 
	siggen:bus_init()
	
	ana:bus_init()
	
	siggen:freq{freq=1.0e3}
	siggen:power(-20.0,'DBM')
	siggen:stat('1')
	
	ana:close()
	siggen:close()
end
main()
