function hello()
	print("hello!")
end

function add(x,y)
	return x + y
end

function concat(x,y)
	return x .. y
end

function randstring(size)
	local t = {}
    for i = 1, size do
      table.insert(t,math.random())
    end
    s = table.concat(t, ",")
	return s
end