local ffi = require("ffi")

local concat , insert = table.concat , table.insert

str1 = 'ID'
id1 = ffi.new('char [?]', #str1+1, str1)
-- convert to lua string.
id1_str=ffi.string(id1,#str1+1)

str2 = 'JE'
id2 = ffi.new('char [?]', #str2+1, str2)
id2_str=ffi.string(id1,#str2+1)
buff={}
insert(buff,id1_str)
insert(buff,id2_str)
-- concat(buff)
print(buff)

local n = 50000

-- Version #1: naive approach
local t = os.clock()
local s = ''
-- loopy
for i=1,n do
    s = s .. i
end
t = os.clock() -t
print(t, #s)

-- Version #2: FFI buffers
local l, p, c = 0, 0, 100
t = os.clock()
s = ffi.new('char[?]', c)
for i=1,n do
   l = tostring(i)
   -- print(p+#l+1)
   if p+#l+1 > c then -- need buffer space
       c = math.ceil(c * 3/2 +1)
       local ns = ffi.new('char[?]', c)
       ffi.copy(ns, s, p)
       s = ns
   end
   ffi.copy(s+p, l)
   p = p + #l
end
s[p]=0 -- Final NULL char
s = ffi.string(s)
t = os.clock() -t
print(t, #s)

-- Version #3: table.concat
t = os.clock()
local tab = {}
for i=1,n do
table.insert(tab,i)
end
s = table.concat(tab)
t = os.clock() -t
print(t, #s)
