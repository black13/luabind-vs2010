local ffi = require("ffi")
local visa = ffi.load("visa32")

ffi.cdef[[
static const long VI_SUCCESS = 0;
static const long VI_NULL = 0;
static const long VI_TRUE = 1;
static const long VI_FALSE= 0;
long viOpenDefaultRM(unsigned long *vi);  
long viOpen(unsigned long sesn, char * name, long mode,long timeout,unsigned long * vi);
long viWrite(unsigned long sesn,char *  buf,unsigned long cnt,unsigned long * retCnt);
long viRead(unsigned long sesn,char *  buf,unsigned long cnt,unsigned long * retCnt);
long viClose(unsigned long vi);
int printf(const char *fmt, ...);
]]


visession = ffi.new("uint32_t[1]")
viSA      = ffi.new("uint32_t[1]")
ret       = ffi.new("uint32_t[1]")
count     = ffi.new("uint32_t[1]")
buf       = ffi.new("uint8_t[256]")

local ret = visa.viOpenDefaultRM(visession)
print (visession)
print (ret)

--str = 'USB0::0x1AB1::0x0960::DSA8A134700019::INSTR'
str = 'USB0::0x0699::0x0401::C020189::INSTR'
psa = ffi.new('char [?]', #str+1, str)

print (visession[0])
ret=visa.viOpen (visession[0],psa,ffi.C.VI_NULL,ffi.C.VI_NULL,viSA)

print(ret)

str = '*IDN?\n'
id = ffi.new('char [?]', #str+1, str)

ret = visa.viWrite(viSA[0],id,#str,count)
--print (ret)

--ret = visa.viRead(viSA[0],buf,256,count);
ret = visa.viRead(viSA[0],buf,0,count);
print(ret)
print('count')
print(count[0])
print(buf[0])
print(buf[1])
n=count[0]
print(n)
local string = ffi.string(buf)
print(str)
-- read a trace 
-- init the the instrument.
local function ip(visa_handle)
   str = 'IP'
   id = ffi.new('char [?]', #str+1, str)   
   local ret = visa.viWrite(visa_handle,id,#str,count)
   return ret
end

--ret = ip(viSA[0])
--print ret

-- end read a trace
ret = visa.viClose(viSA[0]);
--print (ret)

ret=visa.viClose (visession[0])
--print (ret)

-- write something to the device
