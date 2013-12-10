local ffi = require("ffi")
local perlin = ffi.load("perlin")

ffi.cdef[[
unsigned long noise_cache(float *  buf,unsigned long * size);
]]

buf   = ffi.new("float[256]")
size  = ffi.new("uint32_t[1]")
size[0]  = 256
local ret = perlin.noise_cache(buf,size)

print (size[0])

for i = 0, ret do
  print (buf[i])
end