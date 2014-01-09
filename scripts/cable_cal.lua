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
local siggen   = require 'ag_n5181a'
	local ana	=analyzer:new{connect='USB0::0x1AB1::0x0960::DSA8A134700019::INSTR'}
	local siggen=siggen:new{connect='GPIB0::21::INSTR'}
	-- 
	siggen:bus_init()
	
	ana:bus_init()
	
	siggen:freq(500e3)
	siggen:power(-20.0,'DBM')
	siggen:stat('1')
	--ana:stop_freq(10.0e6)
	--ana:start_freq(200.0e3)
	
	buff   = ffi.new("uint8_t[256]")
	
	local ret = ana:marker()
	
	sleep(1000)
	local start=100.0e3
	local stop=15.0e6
	local steps=100
	
	ana:stop_freq(stop)
	ana:start_freq(start)
	
	for freq in freq_iter(start,stop,steps) do
		siggen:freq(freq)
		siggen:power(-20.0,'DBM')
		siggen:stat('1')
		ana:center(freq,10.0e3)
		local ret = ana:marker()
		print (string.format("%.2f , %.2f",freq,ret.value))
		-- print(string.format(ret.value))
	end
	
	ana:close()
	siggen:close()
--analyzer.visa  = 'USB0::0x1AB1::0x0960::DSA8A134700019::INSTR'
--analyzer.power = '-10 DBM'
end
main()
