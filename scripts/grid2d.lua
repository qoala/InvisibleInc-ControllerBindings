-- Sparse 2D grid with fixed bounds.
--
-- Access values through get/set.
--    grid:get(i,j)
--    grid:set(i,j,v)
--
-- Iterating over all non-nil elements in i,j order:
--     for i, j, v in grid:iter() do ... end
--
-- Iterating over non-nil elements from specified points and/or specified directions:
-- (Use grid:reverseRowIter and row:reverseIter to go in the reverse direction.)
--     for i, row in grid:rowIter(i0) do
--         for j, v in row:iter(j0) do
--             ...
--         end
--     end
--

local array = include("modules/array")

local Grid2D = class()
function Grid2D:init(iMax, jMax, debugName)
	rawset(self, "_dbg", (debugName and debugName..":" or "")..tostring(iMax)..","..tostring(jMax))
	assert(type(iMax) == "number" and iMax >= 1 and math.floor(iMax) == iMax, "Invalid iMax "..self._dbg)
	assert(type(jMax) == "number" and jMax >= 1 and math.floor(jMax) == jMax, "Invalid jMax "..self._dbg)

	rawset(self, "_iMax", iMax)
	rawset(self, "_jMax", jMax)
	rawset(self, "_data", {}) -- Elements indexed by the flattened-grid transform of the coordinates.
	rawset(self, "_array", {}) -- Dense array of non-nil elements, in i,j iteration order.
	rawset(self, "_cache", false) -- Index of row start/stop indexes into array.
end

function Grid2D:get(i, j)
	if Grid2D._ijValid(self, i, j) then
		-- simlog("LOG_QEDCTRL", "g2d:get %s,%s:%s -- %s", i, j, Grid2D._ij2n(self, i, j), self._dbg)
		local entry = self._data[Grid2D._ij2n(self, i, j)]
		return entry and entry.v
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

		if old and v == nil then -- Delete entry.
			self._cache = false -- Invalidate cache.
			self._data[n] = nil
			array.removeElement(self._array, old)
		elseif old then -- Update in place.
			old.v = v
		elseif v ~= nil then -- New entry.
			local entry = { i=i, j=j, v=v }

			self._cache = false -- Invalidate cache.
			self._data[n] = entry
			Grid2D._insertSortedEntry(self._array, entry)
		end
	else
		simlog("[QEDCTRL] Out of bounds assignment to grid: %s,%s=%s into %s\n%s",
			tostring(i), tostring(j), tostring(v), self._dbg, debug.traceback())
		inputmgr.onControllerError()
	end
end
function Grid2D._insertSortedEntry(ary, entry)
	local i, j = entry.i, entry.j
	for t = #ary, 1, -1 do -- Reverse-search for the common case of "inserts already in order".
		local other = ary[t]
		if (other.i == i and other.j < j) or other.i < i then
			table.insert(ary, t+1, entry)
			return
		end
	end
	table.insert(ary, 1, entry)
end
function Grid2D:_refreshCache()
	local i2row = {} -- Rows index by i.
	local rows = {} -- Dense array of non-empty rows.

	local i, rowT = 0, 0
	local row
	for t, entry in ipairs(self._array) do
		entry.t = t
		if entry.i > i then
			if row then row.finish = t-1 end

			i, rowT = entry.i, rowT + 1
			row = { rowT=rowT, i=i, start=t }
			i2row[i] = row
			rows[rowT] = row
		end
	end
	row.finish = #self._array

	self._cache = { i2row = i2row, rows = rows }
end
function Grid2D:_ijValid(i, j)
	local iMax, jMax = rawget(self, "_iMax"), rawget(self, "_jMax")
	return (type(i) == "number" and  i >= 1 and i <= iMax and math.floor(i) == i
		and type(j) == "number" and  j >= 1 and j <= jMax and math.floor(j) == j)
end
function Grid2D:_ij2n(i, j)
	return i * rawget(self, "_jMax") + j
end


-- ===
-- Iteration over non-nil entries in i,j order.
local function doArrayIter(dat)
	dat.t = dat.t + 1
	local entry = dat.grid._array[dat.t]
	if entry then
		return entry.i, entry.j, entry.v
	end
end
function Grid2D:iter()
	return doArrayIter, { grid=self, t=0 }
end


-- ===
-- Iteration over non-empty rows in order.
Grid2D._IteratorRow = class()
function Grid2D._IteratorRow:init(grid)
	assert(grid and grid:is_a(Grid2D), type(grid))
	rawset(self, "_g", grid)
	rawset(self, "_r", false)
	rawset(self, "_last", false)
end

local function doRowIter(dat)
	if dat.row then
		local row = dat.row
		dat.view._r, dat.view._last = row, false

		if dat.delta then -- Prep next row.
			dat.row = dat.grid._cache.rows[row.rowT + dat.delta]
		else
			dat.row = nil
		end
		return row.i, dat.view
	end
end
local function doRowIterIter(dat)
	local entry = dat.entry
	if entry then
		if entry.t == dat.limit then -- Prep next entry.
			dat.entry = nil
		else
			dat.entry = dat.grid._array[entry.t + dat.delta]
		end
		return entry.j, entry.v
	end
end
local function emptyIter()
end
function Grid2D:rowIter(i0)
	if not self._cache then self:_refreshCache() end
	local c = self._cache
	local dat = { grid = self, delta = 1, view = Grid2D._IteratorRow(self) }

	-- Find the starting row.
	i0 = i0 or 1
	dat.row = c.i2row[i0]
	if dat.row then return doRowIter, dat end

	for rowT, row in ipairs(c.rows) do
		if row.i > i0 then
			dat.row = row
			return doRowIter, dat
		end
	end
	return emptyIter
end
function Grid2D:reverseRowIter(i0)
	if not self._cache then self:_refreshCache() end
	local c = self._cache
	local dat = { grid = self, delta = -1, view = Grid2D._IteratorRow(self) }

	-- Find the starting row.
	i0 = i0 or self._iMax
	dat.row = c.i2row[i0]
	if dat.row then return doRowIter, dat end

	for rowT = #c.rows, 1, -1 do
		dat.row = c.rows[rowT]
		if dat.row.i < i0 then return doRowIter, dat end
	end
	return emptyIter
end
function Grid2D:getIterRow(i0)
	if not self._cache then self:_refreshCache() end
	local c = self._cache
	local dat = { grid = self, delta = 0, view = Grid2D._IteratorRow(self) }

	dat.row = c.i2row[i0]
	return doRowIter, dat
end
function Grid2D._IteratorRow:iter(j0)
	local grid, row, lastEntry = self._g, self._r, self._last
	local i = row.i
	local dat = { grid = grid, delta = 1, limit = row.finish }

	-- Find the starting value.
	j0 = j0 or 1
	dat.entry = grid._data[grid:_ij2n(i, j0)]
	if dat.entry then
		self._last = dat.entry
		return doRowIterIter, dat
	end
	if lastEntry then
		if lastEntry.j == j0 then
			dat.entry = lastEntry
			return doRowIterIter, dat
		end
		dat.entry = grid._array[lastEntry.t + 1]
		if dat.entry and dat.entry.i == row.i and dat.entry.j == j0 then
			self._last = dat.entry
			return doRowIterIter, dat
		end
	end

	for t = row.start, row.finish do
		dat.entry = grid._array[t]
		if dat.entry.j > j0 then
			self._last = dat.entry
			return doRowIterIter, dat
		end
	end
	return emptyIter
end
function Grid2D._IteratorRow:reverseIter(j0)
	local grid, row, lastEntry = self._g, self._r, self._last
	local i = row.i
	local dat = { grid = grid, delta = -1, limit = row.start }

	-- Find the starting entry.
	j0 = j0 or self._jMax
	dat.entry = grid._data[grid:_ij2n(i, j0)]
	if dat.entry then
		self._last = dat.entry
		return doRowIterIter, dat
	end
	if lastEntry then
		if lastEntry.j == j0 then
			dat.entry = lastEntry
			return doRowIterIter, dat
		end
		dat.entry = grid._array[lastEntry.t - 1]
		if dat.entry and dat.entry.i == row.i and dat.entry.j == j0 then
			self._last = dat.entry
			return doRowIterIter, dat
		end
	end

	for t = row.finish, row.start, -1 do
		dat.entry = grid._array[t]
		if dat.entry.j < j0 then
			self._last = dat.entry
			return doRowIterIter, dat
		end
	end
	return emptyIter
end


function Grid2D:__newindex(k, v)
	simlog("[QEDCTRL] Grid2D disallows assignment\n%s", debug.traceback())
	inputmgr.onControllerError()
end
Grid2D._IteratorRow.__newIndex = Grid2D.__newIndex

return Grid2D
