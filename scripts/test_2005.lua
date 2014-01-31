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
local positioner = require 'pos_2005'

	--local pos	= positioner:new{connect='TCPIP0::10.1.3.82::1203::SOCKET'}
	local pos	= positioner:new{connect='jim2005'}
	pos:bus_init()

	for degree = 0, 35 do
		pos:sk(degree*10)
	end
	pos:sk(359)
	
	pos:close()
end
main()
