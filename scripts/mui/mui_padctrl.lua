local array = include("modules/array")
local mui_defs = include("mui/mui_defs")
local util = require( "client_util" )

local ctrl_defs = include(SCRIPT_PATHS.qedctrl.."/ctrl_defs")

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
-- * initialRoot = layoutID (default "root"):
--     The layout that will be initially focused on this screen.
--     Unlike defaults for layout children, this sets the root even if the target has no available focus targets.
-- * forceController = true:
--     If true, input will be forced to controller mode immediately on screen activation.
--
-- == Layouts
-- Layouts must have one of id or widgetID:
--   * id = "":
--     Unique identifier within this layout's parent.
--   * widgetID = "":
--     Control ID of a widget specified in this screen's widgets tree.
--     The specified widget is placed at this position as a leaf-node of the layout tree.
--     Must be unique among id and widgetID values within this layout's parent.
-- Non-widget layouts can specify:
--   * shape = "VLIST"|"HLIST" (default VLIST):
--       Shape values define how coordinates for this layout's children are interpreted.
--   * children = { layoutDef, layoutDef, ... }
--       Child layouts within this layout.
--   * default = ID:
--       Specify the default child when first entering this layout.
--       If default and defaultChain are unspecified or fail to find an available target,
--       then the first available child will be focused instead.
--   * defaultChain = { ID1, ID2, ... }:
--       Array of child identifieres to try as a default. The first available widget (accounting for hidden/disabled elements) will be focused.
-- All layouts can specify:
--   * leftTo = { navigatePath... } / rightTo = / upTo = / downTo =:
--       If control can't move any further in the specified direction within this group, move
--       focus to the layout specified by this path. This applies before navigation falls back to
--       the parent layout, so may help encode unusual layout structures.

-- == ctrl:navigateTo({options}, navigatePath...)
-- Navigates focus to a specific point in the layout, as specified by the ID path in the varargs.
-- For example, ctrl:navigateTo(options, "a", "b", "c") selects
-- the root layout "a", "a"'s child layout "b", "b"'s child layout "c", and then whichever target is the default within "c" and its descendants.
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

_M.layout_group = class()
function _M.layout_group:init( def, debugName )
	self._def = def or {}
	self._id = self._id or self._def.id -- Allow subclasses to force ID before we build debugName.
	self._debugName = (debugName or "?").."/"..tostring(self._id or "[nil]")
	simlog("LOG_QEDCTRL", "ctrl:init %s %s", tostring(self._debugName), tostring(self._SHAPE))
end
function _M.layout_group:getID()
	return self._id
end

-- function layout_group:isEmpty() : bool
-- function layout_group:canFocus() : bool
-- function layout_group:onFocus(options, coord, ...) : bool
-- optional function layout_group:_onInternalNav( navDir ) : bool

function _M.layout_group:onActivate(screenCtrl)
	self._ctrl = screenCtrl
	self._focusChild = nil
end
function _M.layout_group:onDeactivate()
	self._ctrl = nil
	self._focusChild, self._focusReady = nil
end

function _M.layout_group:onUpdate()
	if self._focusChild then
		self._focusChild:onUpdate()
	elseif not self:isEmpty() then
		self:onFocus()
	end
end

local NAV_TO_FIELDS = {
	[ctrl_defs.UP] = "upTo",
	[ctrl_defs.DOWN] = "downTo",
	[ctrl_defs.LEFT] = "leftTo",
	[ctrl_defs.RIGHT] = "rightTo",
}
function _M.layout_group:onNav(navDir, coord, ...)
	if not coord and self._focusChild and self._focusChild:onNav(navDir) then return true end

	if self._onInternalNav and self:_onInternalNav(navDir, coord, ...) then return true end

	local toPath = self._def[NAV_TO_FIELDS[navDir]]
	if toPath then
		return self._ctrl:navigateTo({dir=navDir, continue=true}, unpack(toPath))
	end
end

function _M.layout_group:onConfirm()
	return self._focusChild and self._focusChild:onConfirm()
end

-- ==============
-- single widgets
-- ==============

_M.widget_reference = class(_M.layout_group)
_M.widget_reference._SHAPE = "widget"
function _M.widget_reference:init( def, debugName )
	self._id = self._id or def.widgetID
	_M.layout_group.init(self, def, debugName)

	self._widgetID = self._def.widgetID
end

function _M.widget_reference:isEmpty()
	return not (self._widgetID and self._ctrl:getWidget(self._widgetID))
end

function _M.widget_reference:canFocus()
	local widget = self._widgetID and self._ctrl:getWidget(self._widgetID)
	return widget and widget:canControllerFocus()
end

function _M.widget_reference:onFocus( options, ... )
	local widget = self._widgetID and self._ctrl:getWidget(self._widgetID)
	if widget and widget.onControllerFocus then
		widget._qedctrl_debugName = self._debugName
		return widget:onControllerFocus(options, ...)
	elseif widget or (options and options.force) then
		return self._ctrl:setFocus(widget, self._debugName)
	end
end

function _M.widget_reference:onUpdate()
	local widget = self._widgetID and self._ctrl:getWidget(self._widgetID)
	if widget and widget.onControllerUpdate then
		return widget:onControllerUpdate()
	end
	return self._ctrl:setFocus(widget, self._debugName)
end

function _M.widget_reference:_onInternalNav( navDir )
	local widget = self._widgetID and self._ctrl:getWidget(self._widgetID)
	if widget and widget.onControllerNav then
		return widget:onControllerNav(navDir)
	end
end

function _M.widget_reference:onConfirm()
	local widget = self._widgetID and self._ctrl:getWidget(self._widgetID)
	if widget and widget.onControllerConfirm then
		return widget:onControllerConfirm()
	end
end

-- A solo top-level widget.
-- Only constructed in the absence of a layout.
_M.solo_layout = class(_M.widget_reference)
_M.solo_layout._SHAPE = "-"
function _M.solo_layout:init()
	self._id = "solo"
	_M.widget_reference.init(self)
end
function _M.solo_layout:getWidgetID()
	return self._widgetID
end
function _M.solo_layout:hasAutoConfirm()
	return self._autoConfirm
end
function _M.solo_layout:setWidget( widget )
	self._widgetID = widget and widget:getControllerID()
	self._autoConfirm = widget and widget:getControllerDef().autoConfirm
end

-- ===

_M.list_layout = class(_M.layout_group)
function _M.list_layout:init( def, debugName )
	_M.layout_group.init(self, def, debugName)

	self._children = {}
	assert(type(self._def.children) == "table", self._debugName)
	for _, childDef in ipairs(self._def.children) do
		local child = _M.createLayout(childDef, self._debugName)
		if child then
			self:_addChild( child, childDef.coord )
		end
	end
end

function _M.list_layout:_addChild( child, index )
	-- Insert into a sorted list.
	assert(index, "Missing coord for child "..tostring(child._debugName))
	child.parentIndex = index
	for i, other in ipairs(self._children) do
		if other.parentIndex > index then
			table.insert(self._children, i, child)
			return
		end
	end
	table.insert(self._children, child)
end

function _M.list_layout:isEmpty()
	return #self._children <= 0
end

function _M.list_layout:onActivate( ... )
	_M.layout_group.onActivate(self, ...)
	for _,child in ipairs(self._children) do
		child:onActivate(...)
	end
end
function _M.list_layout:onDeactivate( ... )
	_M.layout_group.onDeactivate(self, ...)
	for _,child in ipairs(self._children) do
		child:onDeactivate(...)
	end
end

function _M.list_layout:_doFocus(options, child, idx, ...)
	if (child and child:onFocus(options, ...)) or options.force then
		self._focusChild = child
		self._focusIdx = idx
		return true
	end
end

function _M.list_layout:onFocus(options, childID, ...)
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
		return self:_doFocus(options, self:_prevChild(#self._children + 1))
	elseif options.dir == self.NEXT_DIR then
		return self:_doFocus(options, self:_nextChild(0))
	end
	return self:_doFocus(options, self:_defaultChild())
end

function _M.list_layout:_findChild( childID )
	return array.findIf(self._children, function(c) return childID == c:getID() end)
end
function _M.list_layout:_defaultChild()
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
	return self:_nextChild(0)
end

function _M.list_layout:canFocus()
	for _,child in ipairs(self._children) do
		if child:canFocus() then return true end
	end
end

function _M.list_layout:_prevChild( idx )
	local i = idx - 1
	while i >= 1 do
		local child = self._children[i]
		if child:canFocus() then
			return child, i
		end
		i = i - 1
	end
end
function _M.list_layout:_nextChild( idx )
	local i = idx + 1
	local size = #self._children
	while i <= size do
		local child = self._children[i]
		if child:canFocus() then
			return child, i
		end
		i = i + 1
	end
end
function _M.list_layout:_onInternalNav( navDir, idx )
	idx = idx or self._focusIdx
	local child
	if navDir == self.PREV_DIR and idx and idx > 1 then
		child, idx = self:_prevChild(idx)
	elseif navDir == self.NEXT_DIR and idx and idx < #self._children then
		child, idx = self:_nextChild(idx)
	end
	if child then
		return self:_doFocus({dir=navDir}, child, idx)
	end
end

_M.vlist_layout = class(_M.list_layout)
_M.vlist_layout._SHAPE = "VLIST"
_M.vlist_layout.PREV_DIR = ctrl_defs.UP
_M.vlist_layout.NEXT_DIR = ctrl_defs.DOWN

_M.hlist_layout = class(_M.list_layout)
_M.hlist_layout._SHAPE = "HLIST"
_M.hlist_layout.PREV_DIR = ctrl_defs.LEFT
_M.hlist_layout.NEXT_DIR = ctrl_defs.RIGHT

-- ===

_M.LAYOUT_FACTORY = {
	VLIST = _M.vlist_layout,
	HLIST = _M.hlist_layout,
}
function _M.createLayout(def, debugName)
	if def.widgetID then
		return _M.widget_reference(def, debugName)
	end
	assert(def.id, "Missing ID for non-widget child of "..debugName)
	local layoutType = _M.LAYOUT_FACTORY[def.shape or "VLIST"]
	assert(layoutType, "Unknown layout shape "..tostring(def.shape).." on "..debugName.."/"..tostring(def.id))
	return layoutType(def, debugName)
end

-- ==========
-- mui_screen
-- ==========

local screen_ctrl = class()
function screen_ctrl:init(def, debugName)
	self._debugName = debugName or "?"
	self._def = def or {}
	self._layouts = {}
	if self._def.layouts then
		for i, layoutDef in ipairs(self._def.layouts) do
			assert(layoutDef.id, "Missing ID for root layout "..i.." of "..self._debugName)
			assert(not self._layouts[layoutDef.id], "Non-unique layout ID " .. tostring(layoutDef.id) .. " in " .. self._debugName)
			self._layouts[layoutDef.id] = _M.createLayout(layoutDef, self._debugName)
		end
	else
		self._soloLayout = _M.solo_layout()
		self._layouts[ctrl_defs.DEFAULT_LAYOUT] = self._soloLayout
	end
end

function screen_ctrl:_initFocus()
	local defaultLayout = self._def.defaultLayout
	if defaultLayout then
		return self:setRoot(defaultLayout, {force=true})
	end

	return self:setRoot(ctrl_defs.DEFAULT_LAYOUT, {force=true})
end

function screen_ctrl:onActivate(screen)
	simlog("LOG_QEDCTRL", "ctrl:onActivate %s", self._debugName..(10))
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
		self:navigateTo(unpack(self._deferredNavigate))
		self._deferredNavigate = nil
	elseif not inputmgr.isMouseEnabled() then
		self:_initFocus()
	end

	self._screen:addEventHandler( self, mui_defs.EVENT_KeyDown )
end

function screen_ctrl:onDeactivate()
	simlog("LOG_QEDCTRL", "ctrl:onDeactivate %s", self._debugName)
	self._screen:removeEventHandler( self )

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
	if not self._widgets then
		simlog("[QEDCTRL] Can't activate widget %s before screen %s is activated.", id, self._debugName)
	end
	if self._widgets[id] then
		simlog("[QEDCTRL] Non-unique widget ID %s in %s.", id, self._debugName)
		return
	end
	self._widgets[id] = widget

	if widget:getControllerDef().soloButton then
		local soloLayout = self._soloLayout
		if not soloLayout then
			simlog("[QEDCTRL] Can't add soloButton %s to non-solo screen %s.", id, self._debugName)
		elseif soloLayout:getWidgetID() then
			simlog("[QEDCTRL] Can't add multiple soloButtons %s,... to screen %s.", id, self._debugName)
		else
			soloLayout:setWidget(widget)
			simlog("LOG_QEDCTRL", "ctrl:attachSoloWidget %s=%s auto=%s", soloLayout._debugName, id, tostring(soloLayout:hasAutoConfirm()))
		end
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
	if not self._screen then
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
	-- An explicit layout implies that we have widgets.
	-- Alternatively, the default solo layout is filled.
	return not self._soloLayout or not self._soloLayout:isEmpty()
end

function screen_ctrl:setFocus( focusWidget, debugName )
	if focusWidget ~= self._screen._focusWidget then
		simlog("LOG_QEDCTRL", "ctrl:focus %s", debugName)
		if not inputmgr.isMouseEnabled() then
			self._screen:dispatchEvent({eventType = mui_defs.EVENT_FocusChanged, newFocus = focusWidget, oldFocus = self._screen._focusWidget })
			self._screen._focusWidget = focusWidget
		end
	end
	return true
end

function screen_ctrl:onUpdate()
	if self._rootLayout then
		self._rootLayout:onUpdate()
	end
	return true
end

local function maybeAutoClick(self)
	-- Confirm button can click immediately if there's a solo widget in the screen.
	if self._soloLayout and self._soloLayout:hasAutoConfirm() then
		simlog("LOG_QEDCTRL", "ctrl:confirm %s AUTO", self._debugName)
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
			simlog("LOG_QEDCTRL", "ctrl:confirm %s", self._debugName)
			self._rootLayout:onConfirm()
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
