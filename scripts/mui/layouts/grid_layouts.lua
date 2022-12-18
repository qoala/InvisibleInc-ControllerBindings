-- Layouts with children in a 2D grid.

local ctrl_defs = include(SCRIPT_PATHS.qedctrl.."/ctrl_defs")
local Grid2D = include(SCRIPT_PATHS.qedctrl.."/grid2d")
local base_layout = include(SCRIPT_PATHS.qedctrl.."/mui/layouts/base_layout")


local ASC = 1
local DESC = -1
local _DIRMAP = {
	[ctrl_defs.UP] = DESC,
	[ctrl_defs.DOWN] = ASC,
	[ctrl_defs.LEFT] = DESC,
	[ctrl_defs.RIGHT] = ASC,
}
local SIGN_DBG = { [ASC] = "+", [DESC] = "-" }


local grid_layout = class(base_layout)
grid_layout.ASC, grid_layout.DESC = ASC, DESC

function grid_layout:init( def, ... )
	grid_layout._base.init(self, def, ...)
	assert(self._def.w and type(self._def.w) == "number" and self._def.h and type(self._def.h) == "number",
		"[QEDCTRL] Missing w,h ("..tostring(self._def.w)..","..tostring(self._def.h)..") for grid layout "..self._debugName)
	assert(type(self._def.children) == "table", "[QEDCTRL] Missing children for grid layout "..self._debugName)

	local scale = self._def.coordScale or 1
	self._w = self._def.w * scale
	self._h = self._def.h * scale
	-- The initial x/y values when unspecified in navigation and which direction to vary it.
	if self._def.defaultXReverse then
		self._defaultX, self._defaultXNext = self._w, DESC
	else
		self._defaultX, self._defaultXNext = 1, ASC
	end
	if self._def.defaultYReverse then
		self._defaultY, self._defaultYNext = self._h, DESC
	else
		self._defaultY, self._defaultYNext = 1, ASC
	end

	local ctrl_layouts = include(SCRIPT_PATHS.qedctrl.."/mui/ctrl_layouts")
	do
		local iMax, jMax = self:_xy2ij(self._w, self._h)
		self._children = Grid2D(iMax, jMax, self._debugName)
	end
	self._isEmpty = true
	for i, childDef in ipairs(self._def.children) do
		local t = childDef.coord
		assert(type(t) == "table" and #t == 2, "[QEDCTRL] Invalid coord "..tostring(t).." for grid child "..tostring(self._debugName).."/"..(childDef.id or i))
		local x, y = t[1]*scale, t[2]*scale
		assert(not self:getChild(x, y), "[QEDCTRL] Duplicate coord "..x..","..y.." for grid child "..tostring(self._debugName).."/"..(childDef.id or i))

		local child = ctrl_layouts.createLayoutNode(childDef, self._debugName, i, x..","..y)
		if child then
			child.parentX, child.parentY = x, y
			local i, j = self:_xy2ij(x, y)
			self._children:set(i, j, child)

			self._isEmpty = false
		end
	end
end

function grid_layout:isEmpty()
	return self._isEmpty
end

function grid_layout:onActivate( ... )
	grid_layout._base.onActivate(self, ...)
	self._focusX, self._focusY = nil
	for i,j,child in self._children:iter() do
		child:onActivate(...)
	end
end
function grid_layout:onDeactivate( ... )
	for i,j,child in self._children:iter() do
		child:onDeactivate(...)
	end
	self._focusX, self._focusY = nil
	grid_layout._base.onDeactivate(self, ...)
end

function grid_layout:getChild(x, y)
	return self._children:get(self:_xy2ij(x, y))
end
function grid_layout:_findChild( childID )
	for i,j,child in self._children:iter() do
		if child:getID() == childID then
			return child, child.parentX, child.parentY
		end
	end
end

function grid_layout:canFocus()
	for i,j,child in self._children:iter() do
		if child:canFocus() then return true end
	end
end

function grid_layout:_doFocus(options, child, x, y, ...)
	local ok
	if child then
		ok = child:onFocus(options, ...)
	elseif options.force then
		ok = self._ctrl:setFocus(nil, self._debugName)
	end
	if ok then
		self._focusChild = ok and child or nil
		self._focusX = x
		self._focusY = y
		return true
	end
end

function grid_layout:onFocus(options, childID, ...)
	options = options or {}
	if childID then
		local child, x, y = self:_findChild(childID)
		local ok = child and self:_doFocus(options, child, x, y, ...)
		if not ok and x and options.dir and options.continue then
			return self:onNav(options.dir, x, y)
		end
		return ok
	elseif (options.recall or self._def.alwaysRecall) and self._focusX then
		local oldForce = options.force
		if options.onUpdate then options.force = true end

		local child = self:getChild(self._focusX, self._focusY)
		if child and self:_doFocus(options, child, self._focusX, self._focusY, ...) then
			options.force = oldForce
			return true
		end
		options.force = oldForce
	end
	local dir = options.dir
	if dir == ctrl_defs.UP then
		return self:_doFocus(options,
			self:_getOrNextXY(self._defaultX,self._defaultXNext, self._h,DESC))
	elseif dir == ctrl_defs.DOWN then
		return self:_doFocus(options,
			self:_getOrNextXY(self._defaultX,self._defaultXNext, 1,ASC))
	elseif dir == ctrl_defs.LEFT then
		return self:_doFocus(options,
			self:_getOrNextXY(self._w,DESC, self._defaultY,self._defaultYNext))
	elseif dir == ctrl_defs.RIGHT then
		return self:_doFocus(options,
			self:_getOrNextXY(1,ASC, self._defaultY,self._defaultYNext))
	end
	return self:_doFocus(options, self:_defaultChild())
end
function grid_layout:_defaultChild()
	if self:isEmpty() then return end

	if self._def.default then
		local child, x, y = self:_findChild(self._def.default)
		if child and child:canFocus() then
			return child, x, y
		end
	end
	if self._def.defaultChain then
		for _,default in ipairs(self._def.defaultChain) do
			local child, x, y = self:_findChild(default)
			if child and child:canFocus() then
				return child, x, y
			end
		end
	end
	return self:_getOrNextXY(self._defaultX,self._defaultXNext, self._defaultY,self._defaultYNext)
end

-- Find the first available widget, varying the j coordinate first, then the i coordinate.
-- If bounceBack is set, it will try j0 and j values in the jSign direction, then j values in the
-- (-jSign) direction, before it will proceed to the next i value.
function grid_layout:_getOrNextJI(j0, jSign, i0, iSign, bounceBack)
	local iMax, jMax = self:_xy2ij(self._w, self._h)
	if (not jSign
		or not i0 or i0 < 1 or i0 > iMax
		or not j0 or j0 < 1 or j0 > jMax)
	then
		simlog("[QEDCTRL] Failed grid:navJI with invalid args %s%s,%s%s%s / %s,%s %s\n%s",
			i0, SIGN_DBG[iSign] or "=", j0, SIGN_DBG[jSign] or "?", bounceBack and "*" or "",
			iMax, jMax, self._debugName, debug.traceback())
		inputmgr.onControllerError()
		return
	end
	-- simlog("LOG_QEDCTRL", "grid:navJI %s%s,%s%s%s / %s,%s %s",
	-- 	i0, SIGN_DBG[iSign] or "=", j0, SIGN_DBG[jSign] or "?", bounceBack and "*" or "",
	-- 	iMax, jMax, self._debugName)

	local iIterFn, jIter, jBounceIter, jB0
	if iSign == ASC then
		iIterFn = self._children.rowIter
	elseif iSign == DESC then
		iIterFn = self._children.reverseRowIter
	else
		iIterFn = self._children.getIterRow
	end
	if jSign == ASC then
		jIter, jBounceIter, jB0 = "iter", "reverseIter", j0 - 1
	else
		jIter, jBounceIter, jB0 = "reverseIter", "iter", j0 + 1
	end

	for i, row in iIterFn(self._children, i0) do
		for j, child in row[jIter](row, j0) do
			if child:canFocus() then
				return child, child.parentX, child.parentY
			end
		end
		if bounceBack then
			for j, child in row[jBounceIter](row, jB0) do
				if child:canFocus() then
					return child, child.parentX, child.parentY
				end
			end
		end
	end
end

function grid_layout:_onInternalNav( navDir, x, y )
	x = x or self._focusX
	y = y or self._focusY
	if not x or not y then return end
	local child
	local sign = _DIRMAP[navDir]
	if navDir == ctrl_defs.UP or navDir == ctrl_defs.DOWN then
		y = y + sign
		if y > 0 and y <= self._h then
			child, x, y = self:_getOrNextXY(x,nil, y,sign)
		end
	elseif navDir == ctrl_defs.LEFT or navDir == ctrl_defs.RIGHT then
		x = x + sign
		if x > 0 and x <= self._w then
			child, x, y = self:_getOrNextXY(x,sign, y,nil)
		end
	end
	if child then
		return self:_doFocus({dir=navDir}, child, x, y)
	end
end


local rgrid_layout = class(grid_layout)
rgrid_layout._SHAPE = "rgrid"
function rgrid_layout:_xy2ij(x, y) -- (x/w<->j, y/h<->i)
	return y, x
end
function rgrid_layout:_getOrNextXY(x, xSign, y, ySign, bounceBack)
	if not xSign then -- Always consider variation within a row.
		xSign = self._def.defaultXReverse and ASC or DESC
		bounceBack = true
	end
	return self:_getOrNextJI(x,xSign, y,ySign, bounceBack)
end

local cgrid_layout = class(grid_layout)
cgrid_layout._SHAPE = "cgrid"
function cgrid_layout:_xy2ij(x, y) -- (x/w<->i, y/h<->j)
	return x, y
end
function cgrid_layout:_getOrNextXY(x, xSign, y, ySign, bounceBack)
	if not ySign then -- Always consider variation within a column.
		ySign = self._def.defaultYReverse and ASC or DESC
		bounceBack = true
	end
	return self:_getOrNextJI(y,ySign, x,xSign, bounceBack)
end

return {
	grid_layout = grid_layout,
	rgrid_layout = rgrid_layout,
	cgrid_layout = cgrid_layout,
}
