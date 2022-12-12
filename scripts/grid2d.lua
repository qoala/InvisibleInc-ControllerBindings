-- Sparse 2D grid with fixed bounds.
--
-- Iterating using ipairs only yields the non-nil elements.
--     for coord, v in ipairs(grid) do coord.i, coord.j, ... end
--
-- Iteration over all coordinates is supported as:
--     for i, j, v in grid:ijIter() do ... end
--
-- Access can be through get/set. Indexing is currently disabled.
--    grid:get(i,j)
--    grid:set(i,j,v)
--    -- grid[i][j]
--

local sclass = include(SCRIPT_PATHS.qedctrl.."/simple_class")

local Grid2D = sclass()
function Grid2D:init(iMax, jMax, debugName)
	rawset(self, "_dbg", (debugName and debugName..":" or "")..tostring(iMax)..","..tostring(jMax))
	assert(type(iMax) == "number" and iMax >= 1 and math.floor(iMax) == iMax, "Invalid iMax "..self._dbg)
	assert(type(jMax) == "number" and jMax >= 1 and math.floor(jMax) == jMax, "Invalid jMax "..self._dbg)

	rawset(self, "_iMax", iMax)
	rawset(self, "_jMax", jMax)
	rawset(self, "_data", {}) -- Flattened grid.)
	rawset(self, "_elems", {}) -- Unordered non-nil elements.)
	rawset(self, "_views", {}) -- Views over constant-i lines, for indexed access.
end
function Grid2D:get(i, j)
	if Grid2D._ijValid(self, i, j) then
		-- simlog("LOG_QEDCTRL", "g2d:get %s,%s:%s -- %s", i, j, Grid2D._ij2n(self, i, j), self._dbg)
		return self._data[Grid2D._ij2n(self, i, j)]
	else
		simlog("[QEDCTRL] Out of bounds access to grid: %s,%s into %s\n%s",
			tostring(i), tostring(j), self._dbg, debug.traceback())
		inputmgr.onControllerError()
	end
end
function Grid2D:set(i, j, v)
	if Grid2D._ijValid(self, i, j) then
		local n = Grid2D._ij2n(self, i, j)
		local old = self._data[n]
		-- simlog("LOG_QEDCTRL", "g2d:set %s,%s:%s %s->%s count=%s -- %s", i, j, n,
		-- 	tostring(old), tostring(v), #self._elems - (old and 1 or 0) + (v and 1 or 0), self._dbg)
		if n then
			for p, elem in ipairs(self._elems) do
				if i == elem.i and j == elem.j then
					table.remove(self._elems, p)
					break
				end
			end
		end
		self._data[n] = v
		if v ~= nil then
			table.insert(self._elems, { i=i, j=j, v=v })
		end
	else
		simlog("[QEDCTRL] Out of bounds assignment to grid: %s,%s=%s into %s\n%s",
			tostring(i), tostring(j), tostring(v), self._dbg, debug.traceback())
		inputmgr.onControllerError()
	end
end

local function sparseSkippingIter(grid, dat)
	dat._n = dat._n + 1
	local elem = grid._elems[dat._n]
	if elem then
		dat.i, dat.j = elem.i, elem.j
		-- simlog("LOG_QEDCTRL", "grid:ipairs %s:%s,%s -- %s", tostring(dat._n), tostring(dat.i), tostring(dat.j), grid._dbg)
		return dat, elem.v
	-- else
	--	simlog("LOG_QEDCTRL", "grid:ipairs %s end -- %s", tostring(dat._n), grid._dbg)
	end
end
function Grid2D:iter()
	return sparseSkippingIter, self, { _n=0 }
end
function Grid2D:ijIter()
	local n = 0
	local function ijIter(grid)
		n = n + 1
		local i, j = grid:_n2ij(n)
		if i <= grid._iMax then
			return i, j, grid._data[n]
		end
	end
	return ijIter, self
end

-- function Grid2D:__index(i)
-- 	if Grid2D._ijValid(self, i, 1) then
-- 		local views = rawget(self, "_views")
-- 		if not views[i] then views[i] = Grid2D._LineView(self, i) end
-- 		return views[i]
-- 	elseif type(i) ~= "number" then
-- 		return Grid2D[i]
-- 	end
-- 	local dbg = rawget(self, "dbg")
-- 	simlog("[QEDCTRL] Out of bounds access to grid: %s,? into %s\n%s",
-- 		tostring(i), dbg, debug.traceback())
--	inputmgr.onControllerError()
-- end
function Grid2D:__newindex(k, v)
	local dbg = rawget(self, "dbg")
	simlog("[QEDCTRL] Illegal assignment to 2D grid: [%s]=%s into %s\n%s",
		tostring(k), tostring(v), tostring(dbg), debug.traceback())
	inputmgr.onControllerError()
end

function Grid2D:_ijValid(i, j)
	local iMax, jMax = rawget(self, "_iMax"), rawget(self, "_jMax")
	return (type(i) == "number" and  i >= 1 and i <= iMax and math.floor(i) == i
		and type(j) == "number" and  j >= 1 and j <= jMax and math.floor(j) == j)
end
function Grid2D:_ij2n(i, j)
	return i * rawget(self, "_jMax") + j
end
function Grid2D:_n2ij(n)
	local jMax = rawget(self, "_jMax")
	return (n % jMax), math.floor(n / jMax)
end

-- Grid2D._LineView = sclass()
-- function Grid2D._LineView:init(grid, i)
-- 	rawset(self, "_g", grid)
-- 	rawset(self, "_i", i)
-- end
-- function Grid2D._LineView:__ipairs()
-- 	local function iter(line, j)
-- 		local grid = line._g
-- 		if j <= grid._jMax then
-- 			return line._i, j, grid._data[n]
-- 		end
-- 	end
-- 	return iter, self
-- end
-- function Grid2D._LineView:__index(j)
-- 	local grid, i = rawget(self, "_g"), rawget(self, "_i")
-- 	if Grid2D._ijValid(grid, i, j) then
-- 		return rawget(grid, "_data")[Grid2D._ij2n(grid, i, j)]
-- 	elseif type(j) ~= number then
-- 		return Grid2D._LineView[j]
-- 	end
-- 	simlog("[QEDCTRL] Out of bounds access to grid: %s,%s into %s\n%s",
-- 		tostring(i), tostring(j), grid._dbg, debug.traceback())
--	inputmgr.onControllerError()
-- end
-- function Grid2D._LineView:__newindex(j, v)
-- 	local grid, i = rawget(self, "_g"), rawget(self, "_i")
-- 	return Grid2D.set(grid, i, j, v)
-- end

return Grid2D
