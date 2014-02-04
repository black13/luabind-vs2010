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
local analyzer = require 'rigol'
local siggen   = require 'hp_33120a'
	local ana	=analyzer:new{connect='USB0::0x1AB1::0x0960::DSA8A134700019::INSTR'}
	local siggen=siggen:new{connect='GPIB0::15::INSTR'}
	-- 
	siggen:bus_init()
	
	--ana:bus_init()
	
	siggen:freq{freq=15e6}
	siggen:power(-20.0,'DBM')
	siggen:stat('1')
	ana:stop_freq(20.0e6)
	ana:start_freq(1.0e6)
	
	ana:sweep{sweeps=2,swtime=10}
	
	--local ret = ana:marker()
	--[[
	sleep(1000)
	local start=100.0e3
	local stop=15.0e6
	local steps=10
	
	for freq in freq_iter(start,stop,steps) do
		siggen:freq{freq=freq}
		siggen:power(-20.0,'DBM')
		siggen:stat('1')
		ana:center(freq,10.0e3)
		local ret = ana:marker()
		print (string.format("%.2f , %.2f",freq,ret.value))
		print(string.format(ret.value))
	end
	--]]
	--ana:count{count=100,swetime=10}
	--print ("sweep should be done")
	ana:close()
	siggen:close()
--analyzer.visa  = 'USB0::0x1AB1::0x0960::DSA8A134700019::INSTR'
--analyzer.power = '-10 DBM'
end
main()