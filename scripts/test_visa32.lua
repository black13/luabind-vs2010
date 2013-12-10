-- tests visa
local ffi = require("ffi")
ffi.cdef[[
void Sleep(int ms);
]]
function sleep(ms)
    ffi.C.Sleep(ms)
end
local v = require "vclass"

local rigol = v:new()
local ag_n518x = v:new()
local ret
ret = ag_n518x:open("GPIB0::21::INSTR")
ret = rigol:open("USB0::0x1AB1::0x0960::DSA8A134700019::INSTR")
print (ret.ret)

ag_n518x:write("*RST;*RST;\n")
rigol:write("*RST")
rigol:write(":POW:GAIN 0")

ag_n518x:write("POW:ALC:STAT ON")
ag_n518x:write("FREQ:FIXED 100.0KHZ;")
ag_n518x:write("POW:AMPL -20.0DBM;")
ag_n518x:write("OUTP:STAT ON;")


rigol:write("DISP:WIND:TRAC:Y:RLEV -10.00")
rigol:write(":BAND:RES 3.0KHZ")
rigol:write(":BAND:VID 3.0KHZ")
rigol:write(":SENS:SWE:TIME 11.11MS")

sleep(1000)

rigol:write(":FREQ:CENT 100KHZ")
rigol:write(":FREQ:SPAN 100KHZ")

rigol:write(":CALC:MARK1:MAX:MAX")
sleep(1000)
rigol:write(":CALC:MARK:Y?")
sleep(1000)
ret=rigol:read(256)
id=ffi.string(ret.buf,ret.count[0])
print(id)

-- clean up
ag_n518x:close()
rigol:close()
-- close session
v:close_session()
