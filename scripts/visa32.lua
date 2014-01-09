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

-- vihandle.defaulthp = VI_NULL

local vihandle = {} 
vihandle.__index = vihandle 

-- syntax equivalent to "vihandle.new = function..."
function vihandle.new()
  local self = setmetatable({}, vihandle)
  
  local visession = ffi.new("uint32_t[1]")
  local ret = visa.viOpenDefaultRM(visession)
  print (ret) 
  self.visession = visession
  return self
end


function vihandle:get_value()
  return self.visession
end

local v_handle = vihandle.new()
print(v_handle:get_value())

local visa_device = {}
visa_device.__index = visa_device

function visa_device.new(connect)
  local self = setmetatable({}, visa_device)
  self.visession = handle

  psa = ffi.new('char [?]', #connect+1, connect)
  visa_handle      = ffi.new("uint32_t[1]")
  ret=visa.viOpen (handle[0],psa,ffi.C.VI_NULL,ffi.C.VI_NULL,visa_handle)
  self.visa_handle = visa_handle
  return self
end

function visa_device:get_value()
  return self.visa_handle
end

function visa_device:write(command)
	local id = ffi.new('char [?]', #command+1, command)
	local count     = ffi.new("uint32_t[1]")
	print(command)
	ret = visa.viWrite(self.visa_handle[0],id,#command,count)
	return ret,count
end

function visa_device:read(buf,size)
    local count     = ffi.new("uint32_t[1]")
    ret = visa.viRead(self.visa_handle[0],buf,size,count);
	return ret,count
end

return visa_device
