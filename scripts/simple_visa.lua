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


visession 		= ffi.new("uint32_t[1]")
visa_session    = ffi.new("uint32_t[1]")
ret       		= ffi.new("uint32_t[1]")
count     		= ffi.new("uint32_t[1]")
buf       		= ffi.new("uint8_t[256]")

local ret = visa.viOpenDefaultRM(visession)
print (visession)
print (ret)

str = "GPIB0::30::INSTR"
psa = ffi.new('char [?]', #str+1, str)

print (visession[0])
ret=visa.viOpen (visession[0],psa,ffi.C.VI_NULL,ffi.C.VI_NULL,visa_session)
print(ret)

str = '*IDN?\n'
id = ffi.new('char [?]', #str+1, str)

ret = visa.viWrite(visa_session[0],id,#str,count)

ret = visa.viRead(visa_session[0],buf,256,count);
n=count[0]
print(n)
local str = ffi.string(buf)
print(str)

ret = visa.viClose(visa_session[0]);
ret=visa.viClose (visession[0])
