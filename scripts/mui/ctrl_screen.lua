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
--   * alwaysRecall = true:
--       If true and this layout node has previously been focused, then navigating into this node
--       will always try to refocus its most recently focused child first.
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
--   * coordScale = # (default 1)
--       If set, coordinates and width/height bounds will be multiplied by this value.
--       For example, if trying to insert a value between {1,1} and {1,2} after the fact, setting
--       the scale to 10, would allow inserting a value at {1,1.5}
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

local mui_defs = include("mui/mui_defs")
local util = require( "client_util" )

local ctrl_defs = include(SCRIPT_PATHS.qedctrl.."/ctrl_defs")
local ctrl_layouts = include(SCRIPT_PATHS.qedctrl.."/mui/ctrl_layouts")


local NAV_KEY = {
	[mui_defs.K_UPARROW] = ctrl_defs.UP,
	[mui_defs.K_DOWNARROW] = ctrl_defs.DOWN,
	[mui_defs.K_LEFTARROW] = ctrl_defs.LEFT,
	[mui_defs.K_RIGHTARROW] = ctrl_defs.RIGHT,
}
local CMD_KEYS = {
	-- { binding = "QEDCTRL_CONFIRM", cmd = ctrl_defs.CONFIRM }, -- Handled directly.
	{ binding = "QEDCTRL_CANCEL",  cmd = ctrl_defs.CANCEL },
	{ binding = "cameraRotateL",   cmd = ctrl_defs.PPREV },
	{ binding = "cameraRotateR",   cmd = ctrl_defs.PNEXT },
	{ binding = "cycleSelection",  cmd = ctrl_defs.PNEXT },
}

-- =====================================
-- Top-level controller for a mui_screen
-- =====================================

-- LayoutID for the shared combobox layout.
local COMBOBOX_L_ID = "_combobox"

local ctrl_screen = class()
function ctrl_screen:init(def, debugName)
	self._debugName = debugName or "?"
	self._deferredNavigate = nil -- Navigation unavailable until after activate.
	self._def = def or {}
	if self._def.layouts then
		self._layouts = {}
		for i, layoutDef in ipairs(self._def.layouts) do
			assert(layoutDef.id, "[QEDCTRL] Missing ID for root layout "..i.." of "..self._debugName)
			assert(self._layouts[layoutDef.id] == nil, "[QEDCTRL] Non-unique layout ID " .. tostring(layoutDef.id) .. " in " .. self._debugName)
			self._layouts[layoutDef.id] = ctrl_layouts.createLayoutNode(layoutDef, {}, self._debugName, i)
		end
	else
		self._soloLayout = ctrl_layouts.solo_layout(self._debugName)
		self._layouts = { self._soloLayout }
	end
	if self._def.combobox then
		assert(self._layouts[COMBOBOX_L_ID] == nil, "[QEDCTRL] Non-unique layout ID "..COMBOBOX_L_ID.." in " .. self._debugName)
		self._comboboxLayout = ctrl_layouts.combobox_layout(COMBOBOX_L_ID, self._debugName)
		self._layouts[COMBOBOX_L_ID] = self._comboboxLayout
	end
end

function ctrl_screen:_initFocus()
	local initialRoot = self._def.initialRoot
	if initialRoot then
		return self:setRoot(initialRoot, {force=true})
	end

	local firstLayoutID = self._soloLayout and 1 or self._def.layouts[1].id
	return self:setRoot(firstLayoutID, {force=true})
end

function ctrl_screen:onActivate(screen)
	-- simlog("LOG_QEDCTRL", "ctrl:activate %s", self._debugName)
	self._screen = screen
	self._widgets, self._typedWidgets = {}, {}
	self._listeners = {}
	self._rootLayout = nil
	for _, layout in pairs(self._layouts) do
		layout:onActivate(self)
	end
end
function ctrl_screen:afterActivate()
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

function ctrl_screen:onDeactivate()
	-- simlog("LOG_QEDCTRL", "ctrl:deactivate %s", self._debugName)
	self._screen:removeEventHandler( self )
	self._deferredNavigate = nil -- Navigation unavailable until next activate.

	for _, layout in pairs(self._layouts) do
		layout:onDeactivate()
	end
	self._screen, self._widgets, self._typedWidgets = nil
	self._rootLayout, self._listeners = nil
end

-- These events are sent through the layout hierarchy, so we don't track the listener objects here.
-- We just want to know if there's a point to reporting the command.
function ctrl_screen:incrementListenerCount( rootID, cmd )
	local listeners = self._listeners[rootID] or {}
	self._listeners[rootID] = listeners
	listeners[cmd] = (listeners[cmd] or 0) + 1
end
function ctrl_screen:decrementListenerCount( rootID, cmd )
	local listeners = self._listeners[rootID]
	if listeners and listeners[cmd] then
		listeners[cmd] = math.max(listeners[cmd] - 1, 0)
	end
end

function ctrl_screen:getWidget( widgetID )
	return self._widgets and self._widgets[widgetID]
end

function ctrl_screen:getTypedWidget( widgetType, widgetID )
	local tbl = self._typedWidgets and self._typedWidgets[widgetType]
	return tbl and tbl[widgetID]
end

function ctrl_screen:attachWidget( widget )
	local id = widget:getControllerID()
	assert(self._widgets, "[QEDCTRL] Can't activate widget "..tostring(id)..
		" before screen "..tostring(self._debugName).." is activated.")

	local tbl = self._widgets
	if widget.CONTROLLER_TYPE then
		self._typedWidgets[widget.CONTROLLER_TYPE] = self._typedWidgets[widget.CONTROLLER_TYPE] or {}
		tbl = self._typedWidgets[widget.CONTROLLER_TYPE]
	end
	assert(not tbl[id], "[QEDCTRL] Non-unique widget ID "..tostring(id)..
		" in "..tostring(self._debugName))

	tbl[id] = widget

	if widget:getControllerDef().soloButton then
		local soloLayout = self._soloLayout
		assert(soloLayout, "[QEDCTRL] Can't add soloButton "..tostring(id)..
			" to non-solo screen "..tostring(self._debugName))
		assert(not soloLayout:getWidgetID(), "[QEDCTRL] Can't add multiple soloButtons "..tostring(id)..
			", "..tostring(soloLayout:getWidgetID()).." to screen "..tostring(self._debugName))

		soloLayout:setWidget(widget)
		simlog("LOG_QEDCTRL", "ctrl:attachSoloWidget %s=%s auto=%s", soloLayout._debugName, id, tostring(soloLayout:hasAutoConfirm()))
	elseif widget.CONTROLLER_TYPE then
		simlog("LOG_QEDCTRL", "ctrl:attachWidget %s/[%s]/%s", self._debugName, widget.CONTROLLER_TYPE, id)
	else
		simlog("LOG_QEDCTRL", "ctrl:attachWidget %s/%s", self._debugName, id)
	end
end

function ctrl_screen:detachWidget( widget )
	local id = widget:getControllerID()
	local tbl = self._widgets
	if tbl and widget.CONTROLLER_TYPE then tbl = self._typedWidgets[widget.CONTROLLER_TYPE] end
	if tbl then
		tbl[id] = nil
	end

	-- Deactivate solo buttons, as needed.
	local soloLayout = self._soloLayout
	if soloLayout and soloLayout:getWidgetID() == id then
		soloLayout:setWidget(nil)
	end
end

function ctrl_screen:navigateTo( options, layoutID, ... )
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
function ctrl_screen:setRoot( layoutID, options )
	return self:navigateTo(options or {}, layoutID)
end

function ctrl_screen:canCombobox()
	return self._comboboxLayout ~= nil
end
function ctrl_screen:startCombobox( listboxWidget, returnPath, initialIdx )
	if not self._comboboxLayout then
		simlog("[QEDCTRL] Cannot open undeclared combobox on %s", self._debugName)
		return
	elseif self._comboboxLayout == self._rootLayout then
		simlog("[QEDCTRL] Cannot nest combobox invocations on %s", self._debugName)
		return
	end
	self._comboboxLayout:setListWidget(listboxWidget)
	self._comboboxLayout:setReturnPath(returnPath or { self._rootLayout:getID() })
	self:incrementListenerCount(COMBOBOX_L_ID, ctrl_defs.CANCEL)

	self:navigateTo({force=true}, COMBOBOX_L_ID, initialIdx)
end
function ctrl_screen:finishCombobox()
	if not self._comboboxLayout then return end
	self._comboboxLayout:setListWidget(nil)
	local returnPath = self._comboboxLayout:setReturnPath(nil)
	if returnPath then
		self:decrementListenerCount(COMBOBOX_L_ID, ctrl_defs.CANCEL)
	end

	if self._comboboxLayout == self._rootLayout then
		self:navigateTo({force=true, recall=true}, unpack(returnPath))
	end
end

function ctrl_screen:hasWidgets()
	-- Enable controller handling if we either have explicit layout definitions,
	-- or the default solo layout was filled.
	return not self._soloLayout or not self._soloLayout:isEmpty()
end

function ctrl_screen:setFocus( focusWidget, debugName )
	if not inputmgr.isMouseEnabled() and focusWidget ~= self._screen._focusWidget then
		simlog("LOG_QEDCTRL", "ctrl:%s %s", focusWidget == nil and "unfocus" or "focus", tostring(debugName))
		self._screen:dispatchEvent({eventType = mui_defs.EVENT_FocusChanged, newFocus = focusWidget, oldFocus = self._screen._focusWidget })
		self._screen._focusWidget = focusWidget
	end
	return true
end

function ctrl_screen:onUpdate()
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
		return self._soloLayout:onCommand(ctrl_defs.CONFIRM, {})
	end
	return true
end

function ctrl_screen:handleEvent( ev )
	-- simlog("LOG_QEDCTRL", "ctrl:handleEvent %s (%s,%s) root=%s", self._debugName, tostring(ev.eventType), tostring(ev.key), tostring(self._rootLayout and self._rootLayout:getID()))
	if not (ev.eventType == mui_defs.EVENT_KeyDown and self:hasWidgets()) then return end

	local navDir = NAV_KEY[ev.key]
	local isConfirmBinding
	if navDir then
		-- continue
	elseif util.isKeyBindingEvent("QEDCTRL_CONFIRM", ev) then
		isConfirmBinding = true
	elseif self._rootLayout and not inputmgr.isMouseEnabled() then
		-- Remaining commands are only intercepted in controller mode
		-- and cannot be used to enter controller mode.

		local listeners = self._listeners[self._rootLayout:getID()] or {}
		for _, cmdkey in ipairs(CMD_KEYS) do
			if ((listeners[cmdkey.cmd] or 0) > 0
				and util.isKeyBindingEvent(cmdkey.binding, ev))
			then
				return self._rootLayout:onCommand(cmdkey.cmd, {})
			end
		end
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
	elseif navDir then
		self._rootLayout:onNav(navDir)
		return true
	elseif isConfirmBinding then
		if not self._rootLayout:onCommand(ctrl_defs.CONFIRM, {}) then
			simlog("LOG_QEDCTRL", "ctrl:emptyConfirm %s", self._debugName)
		end
		return true
	end
end


return ctrl_screen
