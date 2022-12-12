-- 2D grid with fixed bounds and an initial fill value.

local grid2D = {}
local mt = {}
setmetatable(grid2D, mt)
function mt.__call(_, iMax, jMax, fill, debugName)
	debugName = (debugName and debugName..":" or "")..tostring(iMax)..","..tostring(jMax)
	assert(type(iMax) == "number" and iMax >= 1 and math.floor(iMax) == iMax, "Invalid iMax "..debugName)
	assert(type(jMax) == "number" and jMax >= 1 and math.floor(jMax) == jMax, "Invalid jMax "..debugName)
	t = { _iMax = iMax, _jMax = jMax, _fill = fill, _dbg = debugName }
	setmetatable(t, grid2D)
	return t
end
function grid2D._grid1D(i, jMax, fill, debugName)
	t = { _i = i, _jMax = jMax, _fill = fill, _dbg = debugName }
	setmetatable(t, grid2D._grid1DMeta)
	return t
end

function grid2D.__index(t, i)
	if i == "is_a" then return grid2D._is_a end
	if type(i) == "number" and  i >= 1 and i <= t._iMax and math.floor(i) == i then
		local line = grid2D._grid1D(i, t._jMax, t._fill, t._dbg)
		rawset(t, i, line)
		return line
	end
	simlog("[QEDCTRL] Out of bounds access to 2D grid: %s,? into %s", tostring(i), t._dbg)
end
function grid2D.__newindex(t, i)
	simlog("[QEDCTRL] Illegal assignment to 2D grid: %s,? into %s", tostring(i), t._dbg)
end
function grid2D._is_a(t, cls)
	return cls == grid2D
end

grid2D._grid1DMeta = {}
function grid2D._grid1DMeta.__index(t, j)
	if j == "is_a" then return grid2D._grid1DMeta._is_a end
	if type(j) == "number" and  j >= 1 and j <= t._jMax and math.floor(j) == j then
		local v = t._fill
		rawset(t, j, v)
		return v
	end
	simlog("[QEDCTRL] Out of bounds access to 2D grid: %s,%s into %s", t._i, tostring(j), t._dbg)
end
function grid2D._grid1DMeta.__newindex(t, j, v)
	if type(j) == "number" and  j >= 1 and j <= t._jMax and math.floor(j) == j then
		rawset(t, j, v)
	end
	simlog("[QEDCTRL] Out of bounds assignment to 2D grid: %s,%s:%s into %s", t._i, tostring(j), tostring(v), t._dbg)
end
function grid2D._grid1DMeta._is_a(t, cls)
	return cls == grid2D._grid1D
end

return grid2D
