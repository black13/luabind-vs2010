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
--local siggen   = require 'hp_33120a'
local siggen   = require 'ag_n5181a'
local analyzer = require 'hp_8562a'
local monitor  = require 'rigol'

	local siggen   = siggen:new{connect='GPIB0::21::INSTR'}
	local analyzer = analyzer:new{connect='GPIB0::23::INSTR'}
	local monitor  = monitor:new{connect='USB0::0x1AB1::0x0960::DSA8A134700019::INSTR'}
	-- 
	siggen:bus_init()	
	
	siggen:power(-20.0,'DBM')
	--Init the analyzer
	analyzer:bus_init()
	analyzer:bus_init()
	monitor:bus_init()
	
	local start=100.0e3
	local stop=1.0e9
	local steps=10
	
	siggen:freq(start)
	analyzer:center(start,100.0e3)
	monitor:center(start,100.0e3)
	
	
	analyzer:raw("ST AUTO")
	
	for freq in freq_iter(start,stop,steps) do
		siggen:freq(freq)
		
		siggen:stat('1')
		
		--analyzer:center(freq,100.0e3)
		monitor:center(freq,100.0e3)
		ret = monitor:marker()
		print(ret.value)
		ret = analyzer:marker{center=freq,single=true}
		print(ret.value)
	end
	
	analyzer:raw("CONTS;")
	--analyzer:stop(1.0e6)
	--analyzer:start(100.0e3)
	--ret= analyzer:marker()
	--print (ret.value)
	--analyzer:center(500.0e3,1.0e6)
	siggen:close()
	analyzer:close()
	monitor:close()
end

main()
