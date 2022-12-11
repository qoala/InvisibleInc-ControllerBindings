local array = include("modules/array")
local mui_defs = include("mui/mui_defs")
local util = require( "client_util" )

local ctrl_defs = include(SCRIPT_PATHS.qedctrl.."/ctrl_defs")

-- Widgets can specify { ctrlProperties = { ... } to be placed in the screen's control layout:
-- * id = "" (required):
--     Unique identifier within this screen. Used by widget references in the layout.
-- * soloButton = true, autoConfirm = true:
--     If true and the only interactive widget, then this screen does not need to define layouts.
--     This widget will automatically be the screen's sole child.
--     Pressing confirm will automatically trigger this widget, even from mouse mode.

-- Screens can specify { properties = { ctrlProperties = {...} } }:
-- * layouts = { layout1Def, layout2Def, ... }:
--     Specify properties of each widget layout group.
--   * id = "":
--     Unique identifier within this layout's parent.
--   * shape = "VLIST"|"HLIST" (default VLIST):
--       Shape values define how coordinates for this layout's children are interpreted.
--   * default = ID (default first available child):
--       Specify the default child when first entering this layout.
--   * defaultChain = { ID1, ID2, ... }:
--       Array of child identifieres to try as a default. The first available widget (accounting for hidden/disabled elements) will be focused.
--   * leftTo = { layoutID } / rightTo = / upTo = / downTo =:
--       If control can't move any further in the specified direction within this group, move to the specified group.
-- * defaultLayout = layoutID (default 1):
--     The layout that will be initially focused on this screen.
-- * defaultLayoutChain = { layoutID1, layoutID2, ... }:
--     Array of layouts to try as default. The first layout that succeeds will be focused.
-- * forceController = true:
--     If true, input will be forced to controller mode immediately on screen activation.


local NAV_KEY = {
	[mui_defs.K_UPARROW] = ctrl_defs.UP,
	[mui_defs.K_DOWNARROW] = ctrl_defs.DOWN,
	[mui_defs.K_LEFTARROW] = ctrl_defs.LEFT,
	[mui_defs.K_RIGHTARROW] = ctrl_defs.RIGHT,
}

-- =================
-- base layout group
-- =================

local layout_group = class()
function layout_group:init( def )
	self._def = def or {}
	self._id = self._def.id
end
function layout_group:getID()
	return self._id
end

-- function layout_group:isEmpty() : bool
-- function layout_group:canFocus() : bool
-- function layout_group:onFocus(options, coord, ...) : bool
-- optional function layout_group:_onInternalNav( navDir ) : bool

function layout_group:onActivate(screenCtrl)
	self._ctrl = screenCtrl
	self._focusChild, self._focusReady = nil
end
function layout_group:onDeactivate()
	self._ctrl = nil
	self._focusChild, self._focusReady = nil
end

local NAV_TO_FIELDS = {
	[ctrl_defs.UP] = "upTo",
	[ctrl_defs.DOWN] = "downTo",
	[ctrl_defs.LEFT] = "leftTo",
	[ctrl_defs.RIGHT] = "rightTo",
}
function layout_group:onNav(navDir)
	if not self._focusChild and not self._focusReady then
		return not self:isEmpty() and self:onFocus()
	end
	if self._focusChild and self._focusChild:onNav(navDir) then return true end

	if self._onInternalNav and self:_onInternalNav(navDir) then return true end

	local toID = self._def[NAV_TO_FIELDS[navDir]]
	if toID then
		return self._ctrl:setRoot(unpack(toID))
	end
end

function layout_group:onConfirm()
	return self._focusChild and self._focusChild:onConfirm()
end

-- ==============
-- single widgets
-- ==============

widget_reference = class(layout_group)

function widget_reference:init( def )
	layout_group.init(self, def)
	self._widgetID = self._def.widgetID
	self._id = self._widgetID
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
		if widget:onControllerFocus(options, ...) or (options and options.force) then
			self._focusReady = true -- Tell the base class that we're ready despite no child layout.
			return true
		end
	elseif widget or (options and options.force) then
		self._focusReady = true
		return self._ctrl:setFocus(widget)
	end
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
		return widget:onControllerConfirm()
	end
end

-- A solo top-level widget.
-- Only constructed in the absence of a layout.
solo_layout = class(widget_reference)
function solo_layout:init()
	widget_reference.init(self)
	self._id = "solo"
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

-- ===

local list_layout = class(layout_group)

function list_layout:init( def )
	layout_group.init(self, def)
	self._children = {}

	assert(type(self._def.children) == "table", tostring(self:getID()))
	for _, childDef in ipairs(self._def.children) do
		local child
		-- TODO: Support nested layouts
		assert(childDef.widgetID)
		if childDef.widgetID then
			child = widget_reference(childDef)
		end

		if child then
			self:_addChild( child, childDef.coord )
		end
	end
end

function list_layout:_addChild( child, index )
	-- Insert into a sorted list.
	assert(index, tostring(child:getID()))
	child.parentIndex = index
	for i, other in ipairs(self._children) do
		if other.parentIndex > index then
			table.insert(self._children, i, child)
			return
		end
	end
	table.insert(self._children, child)
end

function list_layout:isEmpty()
	return #self._children <= 0
end

function list_layout:onActivate( ... )
	layout_group.onActivate(self, ...)
	for _,child in ipairs(self._children) do
		child:onActivate(...)
	end
end
function list_layout:onDeactivate( ... )
	layout_group.onDeactivate(self, ...)
	for _,child in ipairs(self._children) do
		child:onDeactivate(...)
	end
end

function list_layout:_doFocus(options, child, idx, ...)
	self._focusChild = child
	self._focusIdx = idx
	if child then
		return child:onFocus(options, ...)
	end
end

function list_layout:onFocus(options, childID, ...)
	if childID then
		local child, idx = self:_findChild(childID)
		if child then
			return self:_doFocus(options, child, idx, ...)
		end
	elseif options and options.recall and self._focusIdx then
		return self:_doFocus(options, self._children[self._focusIdx], self._focusIdx, ...)
	end
	return self:_doFocus(options, self:_defaultChild())
end

function list_layout:_findChild( childID )
	return array.findIf(self._children, function(c) return childID == c:getID() end)
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
	return self:_nextChild(0)
end

function list_layout:canFocus()
	for _,child in ipairs(self._children) do
		if child:canFocus() then return true end
	end
end

function list_layout:_prevChild( idx )
	local i = idx - 1
	while i >= 1 do
		local child = self._children[i]
		if child:canFocus() then
			return child, i
		end
		i = i - 1
	end
end
function list_layout:onNavigatePrev()
	if self._focusIdx > 1 then
		local child, idx = self:_prevChild(self._focusIdx)
		if child then
			return self:_doFocus({force=true}, child, idx)
		end
	end
end

function list_layout:_nextChild( idx )
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
function list_layout:onNavigateNext()
	if self._focusIdx < #self._children then
		local child, idx = self:_nextChild(self._focusIdx)
		if child then
			return self:_doFocus({force=true}, child, idx)
		end
	end
end

local hlist_layout = class(list_layout)
function hlist_layout:_onInternalNav( navDir )
	if navDir == ctrl_defs.LEFT then
		return self:onNavigatePrev()
	elseif navDir == ctrl_defs.RIGHT then
		return self:onNavigateNext()
	end
end

local vlist_layout = class(list_layout)
function vlist_layout:_onInternalNav( navDir )
	if navDir == ctrl_defs.UP then
		return self:onNavigatePrev()
	elseif navDir == ctrl_defs.DOWN then
		return self:onNavigateNext()
	end
end


-- ==========
-- mui_screen
-- ==========

local LAYOUT_FACTORY = {
	VLIST = vlist_layout,
	HLIST = hlist_layout,
}

local screen_ctrl = class()

function screen_ctrl:init(def, debugName)
	self._def = def or {}
	self._layouts = {}
	if self._def.layouts then
		for _, layoutDef in ipairs(self._def.layouts) do
			assert(layoutDef.id, debugName)
			assert(not self._layouts[layoutDef.id], "Non-unique layout " .. tostring(layoutDef.id) .. " in " .. debugName)
			self._layouts[layoutDef.id] = LAYOUT_FACTORY[layoutDef.shape or "VLIST"](layoutDef)
		end
	else
		self._soloLayout = solo_layout()
		self._layouts[1] = self._soloLayout
	end
end

function screen_ctrl:_initFocus()
	local defaultLayout = self._def.defaultLayout
	if defaultLayout and self:setRoot(defaultLayout) then
		return true
	end

	if self._def.defaultLayoutChain then
		for _, defaultLayout in ipairs(self._def.defaultLayoutChain) do
			if self:setRoot(defaultLayout) then
				return true
			end
		end
	end
	if self:setRoot(1) then
		return true
	end
	simlog("[QEDCTRL] Failed to initialize controller focus on %s.", tostring(self._screen._filename))
end

function screen_ctrl:onActivate(screen)
	simlog("LOG_QEDCTRL", "ctrl:onActivate %s", tostring(screen._filename))
	self._screen = screen
	self._widgets = {}
	self._rootLayout, self._focusWidget = nil
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
	simlog("LOG_QEDCTRL", "ctrl:onDeactivate %s", tostring(self._screen._filename))
	self._screen:removeEventHandler( self )

	for _, layout in pairs(self._layouts) do
		layout:onDeactivate()
	end
	self._screen, self._widgets = nil
	self._rootLayout, self._focusWidget = nil
end

function screen_ctrl:getWidget( widgetID )
	return self._widgets and self._widgets[widgetID]
end

function screen_ctrl:attachWidget( widget )
	local id = widget:getControllerID()
	simlog("LOG_QEDCTRL", "ctrl:addWidget %s/%s", self._screen._filename, id)
	if not self._widgets then
		simlog("[QEDCTRL] screen_ctrl:addWidget Can't activate widget before screen %s is activated.", tostring(self._screen, self._screen._filename))
	end
	if self._widgets[id] then
		simlog("[QEDCTRL] screen_ctrl:addWidget Non-unique widget ID %s in %s.", id, tostring(self._screen, self._screen._filename))
		return
	end
	self._widgets[id] = widget

	if widget:getControllerDef().soloButton then
		local soloLayout = self._soloLayout
		if not soloLayout then
			simlog("[QEDCTRL] Can't add soloButton %s to non-solo screen %s.", id, tostring(self._screen, self._screen._filename))
		elseif soloLayout:getWidgetID() then
			simlog("[QEDCTRL] Can't add multiple soloButtons %s,... to screen %s.", id, tostring(self._screen, self._screen._filename))
		else
			soloLayout:setWidget(widget)
		end
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
		self._rootLayout = self._layouts[layoutID]
		return self._rootLayout:onFocus(options, ...)
	end
end
function screen_ctrl:setRoot( layoutID )
	return self:navigateTo({}, layoutID)
end


function screen_ctrl:hasWidgets()
	-- An explicit layout implies that we have widgets.
	-- Alternatively, the default solo layout is filled.
	return not self._soloLayout or not self._soloLayout:isEmpty()
end

function screen_ctrl:setFocus( focusWidget )
	self._focusWidget = focusWidget
	simlog("LOG_QEDCTRL", "ctrl:focus %s/%s", tostring(self._screen._filename), tostring(focusWidget:getControllerID()))
	if not inputmgr.isMouseEnabled() then
		self._screen:dispatchEvent({eventType = mui_defs.EVENT_FocusChanged, newFocus = focusWidget, oldFocus = self._screen._focusWidget })
	end
	self._screen._focusWidget = focusWidget
	return true
end

function screen_ctrl:onUpdate()
	if not self:hasWidgets() then
		return
	end
	if self._focusWidget ~= self._screen._focusWidget then
		self:setFocus(self._focusWidget)
		return true
	end
end

local function maybeAutoClick(self)
	-- Confirm button can click immediately if there's a solo widget in the screen.
	if self._soloGroup and self._soloGroup:hasAutoConfirm() then
		simlog("LOG_QEDCTRL", "ctrl:click %s AUTO", self._screen._filename)
		return self._soloGroup:onConfirm()
	end
	return true
end

function screen_ctrl:handleEvent( ev )
	-- simlog("LOG_QEDCTRL", "ctrl:handleEvent %s (%s,%s) root=%s", self._screen._filename, tostring(ev.eventType), tostring(ev.key), tostring(self._rootLayout and self._rootLayout:getID()))
	local isConfirmBinding = util.isKeyBindingEvent("QEDCTRL_CONFIRM", ev)
	if not (ev.eventType == mui_defs.EVENT_KeyDown
			and (isConfirmBinding or NAV_KEY[ev.key])
			and self:hasWidgets()
	) then
		return
	end

	if not self._rootLayout then
		-- Focus the default widget.
		inputmgr.setMouseEnabled(false)
		self:_initFocus()

		if isConfirmBinding then
			maybeAutoClick(self, self._focusWidget)
		end
		return true
	elseif inputmgr.isMouseEnabled() then
		-- Refocus the most recent controller focus.
		inputmgr.setMouseEnabled(false)
		self:setFocus(self._focusWidget)

		if isConfirmBinding then
			maybeAutoClick(self, self._focusWidget)
		end
		return true
	elseif isConfirmBinding then
		if self._rootLayout then
			simlog("LOG_QEDCTRL", "ctrl:click %s", self._screen._filename)
			self._rootLayout:onConfirm()
		end
		return true
	end

	-- Navigation key pressed.
	local navDir = NAV_KEY[ev.key]

	self._rootLayout:onNav(navDir)
	return true
end

-- ==============
-- widget helpers
-- ==============

widget = {}

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
	screen_ctrl = screen_ctrl,
	widget = widget,
}
