local array = include("modules/array")
local mui_defs = include("mui/mui_defs")
local util = require( "client_util" )

local ctrl_defs = include(SCRIPT_PATHS.qedctrl.."/ctrl_defs")
local Grid2D = include(SCRIPT_PATHS.qedctrl.."/grid2d")
local sclass = include(SCRIPT_PATHS.qedctrl.."/simple_class")

-- == Widget-level properties
-- Widgets can specify { ctrlProperties = { ... } to be placed in the screen's control layout:
-- * id = "" (required):
--     Unique identifier within this screen. Layouts (below) reference their widgets by this ID.
-- * soloButton = true:
--     If true, then this screen does not need to define layouts.
--     This widget will automatically be placed as the screen's sole child.
--     It is an error to specify this on multiple widgets or on a screen with defined layouts.
-- * autoConfirm = true:
--     With both soloButton and autoConfirm, pressing confirm will automatically trigger this
--     widget, even from mouse mode. On its own, autoConfirm has no effect.

-- == Screen-level properties
-- Screens can specify { properties = { ctrlProperties = {...} } }:
-- * layouts = { rootLayoutDef, rootLayoutDef, ... }:
--     Specify logical layouts of widgets (see below).
--     Each entry at this level is a valid root layout for ctrl:setRoot(),
--     and may contain an arbitrary tree of child layouts.
-- * initialRoot = layoutID (default: layouts[1].id):
--     The layout that will be initially focused on this screen.
--     Unlike defaults for layout children, this sets the root even if the target has no available
--     focus targets. No fallbacks are attempted.
-- * forceController = true:
--     If true, input will be forced to controller mode immediately on screen activation.
--
-- == Layouts
-- Layouts must have one of id or widgetID:
--   * id = "":
--       Unique identifier within this layout's parent.
--   * widgetID = "":
--       Control ID of a widget specified in this screen's widgets tree.
--       The specified widget is placed at this position as a leaf-node of the layout tree.
--       Must be unique among id and widgetID values within this layout's parent.
-- Non-widget layouts can specify:
--   * shape = "VLIST"|"HLIST"|"RCGRID" (default VLIST):
--       Shape values define how coordinates for this layout's children are interpreted.
--   * children = { layoutDef, layoutDef, ... }:
--       Child layouts within this layout. Children must specify a 'coord' value, of a format
--       depending on this layout's shape. See below.
--   * default = ID:
--       Specify the default child when first entering this layout.
--       If default and defaultChain are unspecified or fail to find an available target,
--       then the first available child will be focused instead.
--   * defaultChain = { ID1, ID2, ... }:
--       Array of child identifieres to try as a default. The first available widget (accounting for
--       hidden/disabled elements) will be focused.
-- All layouts can specify:
--   * leftTo / rightTo / upTo / downTo = { navigatePath... }:
--       If control can't move any further in the specified direction within this group, move
--       focus to the layout specified by this path. This applies before navigation falls back to
--       the parent layout, so may help encode unusual layout structures.
--
-- == Layout Shapes
-- VLIST/HLIST:
--   A child's coordinate is a single number. Children are sorted in ascending order.
--   VLIST has all children in a vertical line, with low values to the top.
--   HLIST is a vertical line, with low values to the left.
-- List-specific options:
--   * defaultReverse = true
--       If set, then after checking for default and defaultChain, the last available child in the
--       list will be focused.
--
-- RGRID/CGRID:
--   The grid layout's def must additionally specify w=numCols, h=numRows.
--   A child's coordinate is an array of 2 integers {row, column}, with {1,1} in the top-left. All
--   child coordinates must fit within the limits of the grid's width and height.
--   When navigating focus within an RGRID:
--     * Horizontal movement travels within the current row.
--     * Vertical movement moves to the next/previous row, trying to maintain the current column.
--         If the current column isn't available in that row, it tries to find an available target
--         by seeking left within that row, then seeking right within that row, and finally
--         repeating this process on further columns in the same direction.
--   CGRID similarly treats vertical movement within a column as the primary direction.
-- Grid-specific options:
--   * w = #, h = #
--       Fixed bounds of the grid. Both are required.
--   * defaultXReverse = true
--       If set, then when x is unspecified, the grid starts from the right and seeks left.
--       Also, if x is specified but a horizontal direction is not, then the grid will seek to the
--       right before seeking to the left. (towards the starting point)
--   * defaultYReverse = true
--       If set, then when y is unspecified, the grid starts from the bottom and seeks up.
--

-- == ctrl:navigateTo({options}, navigatePath...)
-- Navigates focus to a specific point in the layout, as specified by the ID path in the varargs.
-- For example, ctrl:navigateTo(options, "a", "b", "c") selects
-- the root layout "a", "a"'s child layout "b", "b"'s child layout "c", and then whichever target is
-- the default within "c" and its descendants.
--
-- Recognized options:
--   * force = true:
--       If true, this will set the current focus position within each level of the layout,
--       even if there are no available widgets below that path. If relevant widgets become visible
--       later, then focus will be applied at that time. As long as there are no available widgets
--       below the specified root, navigation with controller bindings may stop responding.
--   * recall = true:
--       When a child is unspecified by the path, the most recently focused child at each node will
--       be tried before falling back to the layout's defaults.
--   * dir = UP|DOWN|LEFT|RIGHT:
--       When a child is unspecified by the path, the nearest child when approached from this
--       direction will be focused, instead of the layout's defaults.
--   * continue = true:
--       Combined with a direction, if the specified path has no available widgets, then navigation
--       will attempt to continue onwards in that direction, as if focus was starting from the
--       specified path.
--       Normally an overspecified path would be a no-op when called without force=true.


local _M = {}

_M.NAV_KEY = {
	[mui_defs.K_UPARROW] = ctrl_defs.UP,
	[mui_defs.K_DOWNARROW] = ctrl_defs.DOWN,
	[mui_defs.K_LEFTARROW] = ctrl_defs.LEFT,
	[mui_defs.K_RIGHTARROW] = ctrl_defs.RIGHT,
}

-- =================
-- base layout group
-- =================

local base_layout = sclass()
function base_layout:init( def, debugParent, debugCoord )
	self._def = def or {}
	self._id = self._id or self._def.id -- Allow subclasses to force ID before we build debugName.
	self._debugName = (debugParent or "?").."/"..tostring(self._id or "[nil]")
	simlog("LOG_QEDCTRL", "ctrl:init %s:%s%s", tostring(self._debugName), tostring(self._SHAPE), debugCoord and " @"..debugCoord or "")
end
function base_layout:getID()
	return self._id
end

-- function layout:isEmpty() : bool
-- function layout:canFocus() : bool
-- function layout:onFocus(options, coord, ...) : bool
-- optional function layout:_onInternalNav( navDir ) : bool

function base_layout:onActivate(screenCtrl)
	-- simlog("LOG_QEDCTRL", "ctrl:activate %s:%s", tostring(self._debugName), tostring(self._SHAPE))
	self._ctrl = screenCtrl
	self._focusChild = nil
end
function base_layout:onDeactivate()
	self._ctrl = nil
	self._focusChild, self._focusReady = nil
end

function base_layout:onUpdate()
	if self._focusChild then
		return self._focusChild:onUpdate()
	elseif not self:isEmpty() then
		return self:onFocus({recall=true, onUpdate=true})
	end
end

local NAV_TO_FIELDS = {
	[ctrl_defs.UP] = "upTo",
	[ctrl_defs.DOWN] = "downTo",
	[ctrl_defs.LEFT] = "leftTo",
	[ctrl_defs.RIGHT] = "rightTo",
}
function base_layout:onNav(navDir, coord, ...)
	if not coord and self._focusChild and self._focusChild:onNav(navDir) then return true end

	if self._onInternalNav and self:_onInternalNav(navDir, coord, ...) then return true end

	local toPath = self._def[NAV_TO_FIELDS[navDir]]
	if toPath then
		return self._ctrl:navigateTo({dir=navDir, continue=true}, unpack(toPath))
	end
end

function base_layout:onConfirm()
	return self._focusChild and self._focusChild:onConfirm()
end

-- ==============
-- single widgets
-- ==============

local widget_reference = sclass(base_layout)
widget_reference._SHAPE = "widget"
function widget_reference:init( def, ... )
	self._id = def and def.widgetID
	_M.widget_reference._base.init(self, def, ...)

	self._widgetID = self._def.widgetID
end

function widget_reference:isEmpty()
	return not (self._widgetID and self._ctrl:getWidget(self._widgetID))
end

function widget_reference:canFocus()
	local widget = self._widgetID and self._ctrl:getWidget(self._widgetID)
	return widget and widget:canControllerFocus()
end

function widget_reference:onFocus( options, ... )
	local widget = self._widgetID and self._ctrl:getWidget(self._widgetID)
	if widget and widget.onControllerFocus then
		widget._qedctrl_debugName = self._debugName
		return widget:onControllerFocus(options, ...)
	elseif widget or (options and options.force) then
		return self._ctrl:setFocus(widget, self._debugName)
	end
end

function widget_reference:onUpdate()
	local widget = self._widgetID and self._ctrl:getWidget(self._widgetID)
	if widget and widget.onControllerUpdate then
		return widget:onControllerUpdate()
	end
	return self._ctrl:setFocus(widget, self._debugName)
end

function widget_reference:_onInternalNav( navDir )
	local widget = self._widgetID and self._ctrl:getWidget(self._widgetID)
	if widget and widget.onControllerNav then
		return widget:onControllerNav(navDir)
	end
end

function widget_reference:onConfirm()
	local widget = self._widgetID and self._ctrl:getWidget(self._widgetID)
	if widget and widget.onControllerConfirm then
		simlog("LOG_QEDCTRL", "ctrl:confirm %s", self._debugName)
		return widget:onControllerConfirm()
	end
end

-- A solo top-level widget.
-- Only constructed in the absence of a layout.
local solo_layout = sclass(widget_reference)
solo_layout._SHAPE = "-"
function solo_layout:init( debugParent )
	self._id = "solo"
	_M.base_layout.init(self, nil, debugParent) -- Skip widget_reference:init
end
function solo_layout:getWidgetID()
	return self._widgetID
end
function solo_layout:hasAutoConfirm()
	return self._autoConfirm
end
function solo_layout:setWidget( widget )
	self._widgetID = widget and widget:getControllerID()
	self._autoConfirm = widget and widget:getControllerDef().autoConfirm
end

-- ============
-- List layouts
-- ============

local list_layout = sclass(base_layout)
function list_layout:init( def, ... )
	_M.list_layout._base.init(self, def, ...)

	self._children = {}
	assert(type(self._def.children) == "table", "Missing children for list layout "..self._debugName)
	for i, childDef in ipairs(self._def.children) do
		assert(type(childDef.coord) == "number", "Invalid coord "..tostring(childDef.coord).." for child "..tostring(self._debugName).."/"..(childDef.id or i))

		local child = _M.createLayout(childDef, self._debugName, i, childDef.coord)
		if child then
			child.parentIdx = childDef.coord
			table.insert(self._children, child)
		end
	end
	table.sort(self._children, function(a, b) return a.parentIdx < b.parentIdx end)
end

function list_layout:isEmpty()
	return util.tempty(self._children)
end

function list_layout:onActivate( ... )
	_M.list_layout._base.onActivate(self, ...)
	for i,child in ipairs(self._children) do
		child:onActivate(...)
	end
end
function list_layout:onDeactivate( ... )
	for _,child in ipairs(self._children) do
		child:onDeactivate(...)
	end
	_M.list_layout._base.onDeactivate(self, ...)
end

function list_layout:_findChild( childID )
	for i, child in ipairs(self._children) do
		if child:getID() == childID then
			return child, i
		end
	end
end

function list_layout:canFocus()
	for _,child in ipairs(self._children) do
		if child:canFocus() then return true end
	end
end

function list_layout:_doFocus(options, child, idx, ...)
	if (child and child:onFocus(options, ...)) or options.force then
		self._focusChild = child
		self._focusIdx = idx
		return true
	end
end
function list_layout:onFocus(options, childID, ...)
	options = options or {}
	if childID then
		local child, idx = self:_findChild(childID)
		local ok = child and self:_doFocus(options, child, idx, ...)
		if not ok and idx and options.dir and options.continue then
			return self:onNav(options.dir, idx)
		end
		return ok
	elseif options.recall and self._focusIdx then
		local child = self._children[self._focusIdx]
		if child and self:_doFocus(options, child, self._focusIdx, ...) then
			return true
		end
	end
	if options.dir == self.PREV_DIR then
		return self:_doFocus(options, self:_getOrPrev(#self._children))
	elseif options.dir == self.NEXT_DIR then
		return self:_doFocus(options, self:_getOrNext(1))
	end
	return self:_doFocus(options, self:_defaultChild())
end
function list_layout:_defaultChild()
	if self:isEmpty() then return end

	if self._def.default then
		local child, idx = self:_findChild(self._def.default)
		if child and child:canFocus() then
			return child, idx
		end
	end
	if self._def.defaultChain then
		for _,default in ipairs(self._def.defaultChain) do
			local child, idx = self:_findChild(default)
			if child and child:canFocus() then
				return child, idx
			end
		end
	end
	if self._def.defaultReverse then
		return self:_getOrPrev(#self._children)
	else
		return self:_getOrNext(1)
	end
end

function list_layout:_getOrPrev( i0 )
	local i = i0
	while i >= 1 do
		local child = self._children[i]
		if child:canFocus() then
			return child, i
		end
		i = i - 1
	end
end
function list_layout:_getOrNext( i0 )
	local i = i0
	local size = #self._children
	while i <= size do
		local child = self._children[i]
		if child:canFocus() then
			return child, i
		end
		i = i + 1
	end
end
function list_layout:_onInternalNav( navDir, idx )
	idx = idx or self._focusIdx
	local child
	if navDir == self.PREV_DIR and idx and idx > 1 then
		child, idx = self:_getOrPrev(idx - 1)
	elseif navDir == self.NEXT_DIR and idx and idx < #self._children then
		child, idx = self:_getOrNext(idx + 1)
	end
	if child then
		return self:_doFocus({dir=navDir}, child, idx)
	end
end

local vlist_layout = sclass(list_layout)
vlist_layout._SHAPE = "VLIST"
vlist_layout.PREV_DIR = ctrl_defs.UP
vlist_layout.NEXT_DIR = ctrl_defs.DOWN

local hlist_layout = sclass(list_layout)
hlist_layout._SHAPE = "HLIST"
hlist_layout.PREV_DIR = ctrl_defs.LEFT
hlist_layout.NEXT_DIR = ctrl_defs.RIGHT

-- ============
-- Grid layouts
-- ============

local grid_layout = sclass(base_layout)
local rgrid_layout = sclass(grid_layout)
local cgrid_layout = sclass(grid_layout)

do
	local ASC = 1
	local DESC = -1
	local _DIRMAP = {
		[ctrl_defs.UP] = DESC,
		[ctrl_defs.DOWN] = ASC,
		[ctrl_defs.LEFT] = DESC,
		[ctrl_defs.RIGHT] = ASC,
	}
	local SIGN_DBG = { [ASC] = "+", [DESC] = "-" }
	grid_layout.ASC, grid_layout.DESC = ASC, DESC

	function grid_layout:init( def, ... )
		_M.grid_layout._base.init(self, def, ...)
		assert(self._def.w and type(self._def.w) == "number" and self._def.h and type(self._def.h) == "number",
			"Missing w,h ("..tostring(self._def.w)..","..tostring(self._def.h)..") for grid layout "..self._debugName)
		assert(type(self._def.children) == "table", "Missing children for grid layout "..self._debugName)

		self._w = self._def.w
		self._h = self._def.h
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

		do
			local iMax, jMax = self:_xy2ij(self._w, self._h)
			self._children = Grid2D(iMax, jMax, self._debugName)
		end
		self._isEmpty = true
		for i, childDef in ipairs(self._def.children) do
			local t = childDef.coord
			assert(type(t) == "table" and #t == 2, "Invalid coord "..tostring(t).." for grid child "..tostring(self._debugName).."/"..(childDef.id or i))
			local x, y = t[1], t[2]
			assert(not self:getChild(x, y), "Duplicate coord "..x..","..y.." for grid child "..tostring(self._debugName).."/"..(childDef.id or i))

			local child = _M.createLayout(childDef, self._debugName, i, x..","..y)
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
		_M.grid_layout._base.onActivate(self, ...)
		for i,j,child in self._children:iter() do
			child:onActivate(...)
		end
	end
	function grid_layout:onDeactivate( ... )
		for i,j,child in self._children:iter() do
			child:onDeactivate(...)
		end
		_M.grid_layout._base.onDeactivate(self, ...)
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
		if (child and child:onFocus(options, ...)) or options.force then
			self._focusChild = child
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
		elseif options.recall and self._focusX then
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
			simlog("[QEDCTRL] Failed grid:navJI with invalid args %s%s,%s%s/%s,%s %s\n%s",
				i0, SIGN_DBG[iSign] or "=", j0, SIGN_DBG[jSign] or "?", iMax, jMax,
				self._debugName, debug.traceback())
			inputmgr.onControllerError()
			return
		end
		-- simlog("LOG_QEDCTRL", "grid:navJI %s%s,%s%s/%s,%s %s",
		-- 	i0, SIGN_DBG[iSign] or "=", j0, SIGN_DBG[jSign] or "?", iMax, jMax, self._debugName)

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
				child, x, y = self:_getOrNextXY(x,nil, y,sign, true)
			end
		elseif navDir == ctrl_defs.LEFT or navDir == ctrl_defs.RIGHT then
			x = x + sign
			if x > 0 and x <= self._w then
				child, x, y = self:_getOrNextXY(x,sign, y,nil, true)
			end
		end
		if child then
			return self:_doFocus({dir=navDir}, child, x, y)
		end
	end


	rgrid_layout._SHAPE = "RGRID"
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

	cgrid_layout._SHAPE = "CGRID"
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
end

-- ===

_M.base_layout = base_layout
_M.widget_reference = widget_reference
_M.solo_layout = solo_layout
_M.list_layout = list_layout
_M.hlist_layout = hlist_layout
_M.vlist_layout = vlist_layout
_M.grid_layout = grid_layout
_M.rgrid_layout = rgrid_layout
_M.cgrid_layout = cgrid_layout

_M.LAYOUT_FACTORY = {
	VLIST = _M.vlist_layout,
	HLIST = _M.hlist_layout,
	RGRID = _M.rgrid_layout,
	CGRID = _M.cgrid_layout,
}
function _M.createLayout(def, debugParent, debugIdx, debugCoord)
	if def.widgetID then
		return _M.widget_reference(def, debugParent, debugCoord)
	end
	assert(def.id, "Missing ID for non-widget child "..debugIdx.." of "..debugParent)
	local layoutType = _M.LAYOUT_FACTORY[def.shape or "VLIST"]
	assert(layoutType, "Unknown layout shape "..tostring(def.shape).." on "..debugParent.."/"..tostring(def.id))
	return layoutType(def, debugParent)
end

-- =====================================
-- Top-level controller for a mui_screen
-- =====================================

local screen_ctrl = sclass()
function screen_ctrl:init(def, debugName)
	self._debugName = debugName or "?"
	self._deferredNavigate = nil -- Navigation unavailable until after activate.
	self._def = def or {}
	if self._def.layouts then
		self._layouts = {}
		for i, layoutDef in ipairs(self._def.layouts) do
			assert(layoutDef.id, "Missing ID for root layout "..i.." of "..self._debugName)
			assert(not self._layouts[layoutDef.id], "Non-unique layout ID " .. tostring(layoutDef.id) .. " in " .. self._debugName)
			self._layouts[layoutDef.id] = _M.createLayout(layoutDef, self._debugName, i)
		end
	else
		self._soloLayout = _M.solo_layout(self._debugName)
		self._layouts = { self._soloLayout }
	end
end

function screen_ctrl:_initFocus()
	local initialRoot = self._def.initialRoot
	if initialRoot then
		return self:setRoot(initialRoot, {force=true})
	end

	local firstLayoutID = self._soloLayout and 1 or self._def.layouts[1].id
	return self:setRoot(firstLayoutID, {force=true})
end

function screen_ctrl:onActivate(screen)
	-- simlog("LOG_QEDCTRL", "ctrl:activate %s", self._debugName)
	self._screen = screen
	self._widgets = {}
	self._rootLayout = nil
	for _, layout in pairs(self._layouts) do
		layout:onActivate(self)
	end
end
function screen_ctrl:afterActivate()
	if not self:hasWidgets() then return end

	if self._def.forceController then
		inputmgr.setMouseEnabled(false)
	end
	if self._deferredNavigate then
		local navArgs = self._deferredNavigate
		self._deferredNavigate = false -- Navigation available.
		self:navigateTo(unpack(navArgs))
	elseif not inputmgr.isMouseEnabled() then
		self._deferredNavigate = false
		self:_initFocus()
	else
		self._deferredNavigate = false
	end

	self._screen:addEventHandler( self, mui_defs.EVENT_KeyDown )
end

function screen_ctrl:onDeactivate()
	-- simlog("LOG_QEDCTRL", "ctrl:deactivate %s", self._debugName)
	self._screen:removeEventHandler( self )
	self._deferredNavigate = nil -- Navigation unavailable until next activate.

	for _, layout in pairs(self._layouts) do
		layout:onDeactivate()
	end
	self._screen, self._widgets = nil
	self._rootLayout = nil
end

function screen_ctrl:getWidget( widgetID )
	return self._widgets and self._widgets[widgetID]
end

function screen_ctrl:attachWidget( widget )
	local id = widget:getControllerID()
	assert(self._widgets, "[QEDCTRL] Can't activate widget "..tostring(id)..
		" before screen "..tostring(self._debugName).." is activated.")
	assert(not self._widgets[id], "[QEDCTRL] Non-unique widget ID "..tostring(id)..
		" in "..tostring(self._debugName))

	self._widgets[id] = widget

	if widget:getControllerDef().soloButton then
		local soloLayout = self._soloLayout
		assert(soloLayout, "[QEDCTRL] Can't add soloButton "..tostring(id)..
			" to non-solo screen "..tostring(self._debugName))
		assert(not soloLayout:getWidgetID(), "[QEDCTRL] Can't add multiple soloButtons "..tostring(id)..
			", "..tostring(soloLayout:getWidgetID()).." to screen "..tostring(self._debugName))

		soloLayout:setWidget(widget)
		simlog("LOG_QEDCTRL", "ctrl:attachSoloWidget %s=%s auto=%s", soloLayout._debugName, id, tostring(soloLayout:hasAutoConfirm()))
	else
		simlog("LOG_QEDCTRL", "ctrl:attachWidget %s/%s", self._debugName, id)
	end
end

function screen_ctrl:detachWidget( widget )
	local id = widget:getControllerID()
	if self._widgets then
		self._widgets[id] = nil
	end

	-- Deactivate solo buttons, as needed.
	local soloLayout = self._soloLayout
	if soloLayout and soloLayout:getWidgetID() == id then
		soloLayout:setWidget(nil)
	end
end

function screen_ctrl:navigateTo( options, layoutID, ... )
	if self._deferredNavigate ~= false then
		self._deferredNavigate = { options, layoutID, ... }
		return true
	end
	if self._layouts and self._layouts[layoutID] then
		local layout = self._layouts[layoutID]
		if layout:onFocus(options or {}, ...) or (options and options.force) then
			self._rootLayout = layout
			return true
		end
	end
end
function screen_ctrl:setRoot( layoutID, options )
	return self:navigateTo(options or {}, layoutID)
end


function screen_ctrl:hasWidgets()
	-- Enable controller handling if we either have explicit layout definitions,
	-- or the default solo layout was filled.
	return not self._soloLayout or not self._soloLayout:isEmpty()
end

function screen_ctrl:setFocus( focusWidget, debugName )
	if not inputmgr.isMouseEnabled() and focusWidget ~= self._screen._focusWidget then
		simlog("LOG_QEDCTRL", "ctrl:%s %s", focusWidget == nil and "unfocus" or "focus", tostring(debugName))
		self._screen:dispatchEvent({eventType = mui_defs.EVENT_FocusChanged, newFocus = focusWidget, oldFocus = self._screen._focusWidget })
		self._screen._focusWidget = focusWidget
	end
	return true
end

function screen_ctrl:onUpdate()
	if self._rootLayout then
		if not self._rootLayout:onUpdate() then
			self:setFocus(nil, "onUpdate")
		end
	end
	return true
end

local function maybeAutoClick(self)
	-- Confirm button can click immediately if there's a solo widget in the screen.
	if self._soloLayout and self._soloLayout:hasAutoConfirm() then
		simlog("LOG_QEDCTRL", "ctrl:autoConfirm %s", self._debugName)
		return self._soloLayout:onConfirm()
	end
	return true
end

function screen_ctrl:handleEvent( ev )
	-- simlog("LOG_QEDCTRL", "ctrl:handleEvent %s (%s,%s) root=%s", self._debugName, tostring(ev.eventType), tostring(ev.key), tostring(self._rootLayout and self._rootLayout:getID()))
	local isConfirmBinding = util.isKeyBindingEvent("QEDCTRL_CONFIRM", ev)
	if not (ev.eventType == mui_defs.EVENT_KeyDown
			and (isConfirmBinding or _M.NAV_KEY[ev.key])
			and self:hasWidgets()
	) then
		return
	end

	if not self._rootLayout then
		-- Focus the default widget.
		inputmgr.setMouseEnabled(false)
		self:_initFocus()

		if isConfirmBinding then maybeAutoClick(self) end
		return true
	elseif inputmgr.isMouseEnabled() then
		-- Refocus the most recent controller focus.
		inputmgr.setMouseEnabled(false)
		self:onUpdate()

		if isConfirmBinding then maybeAutoClick(self) end
		return true
	elseif isConfirmBinding then
		if self._rootLayout then
			if not self._rootLayout:onConfirm() then
				simlog("LOG_QEDCTRL", "ctrl:emptyConfirm %s", self._debugName)
			end
		end
		return true
	end

	-- Navigation key pressed.
	local navDir = _M.NAV_KEY[ev.key]

	self._rootLayout:onNav(navDir)
	return true
end

-- ==============
-- widget helpers
-- ==============

local widget = {}

function widget.init(self, def)
	if def.ctrlProperties then
		assert(type(def.ctrlProperties) == "table", def.name)
		assert(def.ctrlProperties.id, def.name)
		self._qedctrl_ctrl = nil -- set on activate.
		self._qedctrl_def = def.ctrlProperties
		self._qedctrl_id = def.ctrlProperties.id
		return true
	end
end

-- function widget:canControllerFocus()
-- optional function widget:onControllerFocus()
-- optional function widget:onControllerUpdate() -- Required if onControllerFocus is defined.
-- optional function widget:onControllerNav( navDir )
-- optional function widget:onControllerConfirm()

function widget.defineCtrlMethods(cls, appends)
	function cls:getControllerID()
		return self._qedctrl_id
	end
	function cls:getControllerDef()
		return self._qedctrl_def
	end

	-- Widgets are added/removed on activate/deactivate,
	-- because some of them are mui_component, and components aren't added directly to the screen.
	local oldOnActivate = cls.onActivate
	function cls:onActivate( screen, ... )
		oldOnActivate(self, screen, ...)
		if self._qedctrl_id then
			self._qedctrl_ctrl = screen:getControllerControl()
			self._qedctrl_ctrl:attachWidget(self)

			if appends and appends.onActivate then
				appends.onActivate(self, screen, ...)
			end
		end
	end

	local oldOnDeactivate = cls.onDeactivate
	function cls:onDeactivate( screen, ... )
		if self._qedctrl_ctrl then
			self._qedctrl_ctrl:detachWidget(self)

			if appends and appends.onDeactivate then
				appends.onDeactivate(self, screen, ...)
			end
		end
		self._qedctrl_ctrl = nil
		oldOnDeactivate(self, screen, ...)
	end
end


return {
	_M = _M,
	screen_ctrl = screen_ctrl,
	widget = widget,
}
