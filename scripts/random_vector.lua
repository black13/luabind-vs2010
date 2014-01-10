
local ffi = require("ffi")
ffi.cdef[[
void Sleep(int ms);
]]
function sleep(ms)
    ffi.C.Sleep(ms)
end
local inspect = require 'inspect'
local vclass = require 'vclass'
local analyzer = require 'rs_esr'
ana = analyzer:new{connect='GPIB0::30::INSTR'}
	
ana:bus_init()

print( myobj3.copyString( 'hi' ) );
vm = myobj3.copyVariantMap( {key1=1,key2='hello'} );
print( vm['key1'] .. ' ' .. vm['key2'] );
print( myobj3.createObject().objectName );

fl = myobj3.copyFloatList( {1.0,2.0,3.0} );
print( fl[1] .. ' ' .. fl[ 3 ] );