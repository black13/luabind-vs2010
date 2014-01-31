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
	local siggen   = require 'hp_33120a'
	local hp_33120a   = siggen:new{connect='GPIB0::15::INSTR'}
	hp_33120a:bus_init()
	hp_33120a:freq{freq=15.0e6}
	hp_33120a:freq{freq=15.0e6,mod='SQU',modfreq=20.e3}
	hp_33120a:stat(1)
	hp_33120a:close()
end
main()
