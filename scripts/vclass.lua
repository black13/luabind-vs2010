
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
int atoi (const char*);
]]

local visa_class = {}
visa_class.__index = visa_class

function visa_class:new (o)
  local o = o or {}   -- create object if user does not provide one
  o.visession = ffi.new("uint32_t[1]")
  o.ret = visa.viOpenDefaultRM(o.visession)
  visa_class.visession = o.visession
  --print (o.ret)
  --print (o.visession)
  setmetatable(o, visa_class)
  return o
end

function visa_class:open(connect)
  local ret={}
  connect_string = ffi.new('char [?]', #connect+1, connect)
  self.visa_handle      = ffi.new("uint32_t[1]")
  ret.ret=visa.viOpen (self.visession[0],connect_string,ffi.C.VI_NULL,ffi.C.VI_NULL,self.visa_handle)
  ret.visa_handle = self.visa_handle
  ret.visa_session = self.visession
  return ret
end

function visa_class:write(command)
	local ret = {}
	local id = ffi.new('char [?]', #command+1, command)
	local count     = ffi.new("uint32_t[1]")
	ret.ret = visa.viWrite(self.visa_handle[0],id,#command,count)
	return ret
end

--similar to pyvisa 'ask'
function visa_class:ask(command)
	local ret = {}
	
	local id = ffi.new('char [?]', #command+1, command)
	local count     = ffi.new("uint32_t[1]")
	ret.ret = visa.viWrite(self.visa_handle[0],id,#command,count)

	local count     = ffi.new("uint32_t[1]")
	local buf       = ffi.new('uint8_t [?]',256)
	ret.ret = visa.viRead(self.visa_handle[0],buf,256,count);
	ret.value = ffi.string(buf)
	ret.count = count
	return ret
end


function visa_class:read(buff,n)
	local ret = {}
	local count     = ffi.new("uint32_t[1]")
	ret.ret = visa.viRead(self.visa_handle[0],buff,n,count);
	ret.count = count
	return ret
end


function visa_class:close()
	local ret = {}
	ret.ret = visa.viClose(self.visa_handle[0]);
	return (ret)
end

function visa_class:close_session()
	local ret = {}
	ret.ret = visa.viClose (visa_class.visession[0])
	return (ret)
end


return visa_class