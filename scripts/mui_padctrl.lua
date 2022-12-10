local array = include("modules/array")
local util = require( "modules/util" )
local mui_defs = include("mui/mui_defs")
local mui_util = include("mui/mui_util")

-- Widgets can specify { ctrlProperties = {...} } to be placed in the screens control layout:
-- * coord = { index }:
--     Index position of this widget. Widgets will be sorted within their group, so this need not be densely packed.
-- * group = groupID (default 1):
--     Allows placing widgets in independent grids for better logical arrangement.
-- * autoConfirm = true:
--     If true and this is the default widget, pressing the confirm key will automatically trigger this widget from non-controller mode.
--     Usually used if this is the only possible interaction on the screen.

-- Screens can specify { properties = { ctrlProperties = {...} } }:
-- * groups = { group1Def, group2Def, ... }:
--     Specify properties of a widget group.
--   * shape = 'VLIST'|'HLIST' (default VLIST):
--       Shape values define how coordinates for this group's widgets are interpreted.
--   * defaultCoord = {index} (default first available widget):
--       Specify the default widget when first entering this group.
--   * defaultCoordChain = { {index}, {fallbackIndex}, ... }:
--       Array of widget indices to try as a default. The first available widget (accounting for hidden/disabled elements) will be focused.
--   * leftToGroup = { groupID } / rightTo = / upTo = / downTo =:
--       If control can't move any further in the specified direction within this group, move to the specified group.
--   * forceController = true:
--       If true, input will be forced to controller mode immediately on screen activation.
-- * defaultGroup = groupID (default 1):
--     The group that will be initially focused on this screen.
-- * defaultGroupChain = { groupID, fallback, ... }:
--     Array of groups to try as default. The first group that succeeds will be focused.


local function isAvailableWidget( widget )
	return widget:isVisible() and (not widget.isDisabled or not widget:isDisabled())
end

local function matchSameCoord(coord)
	return function(w)
		local wc = w:getControllerCoord()
		return wc[1] == coord[1]
	end
end

-- ===

local widget_group = class()
function widget_group:init( ctrl, def )
	self._ctrl = ctrl
	self._def = def or {}
end

-- function widget_group:addWidget( widget )
-- function widget_group:removeWidget( widget )
-- function widget_group:hasWidgets()
-- function widget_group:defaultWidget()

function widget_group:onEnter(options)
	options = options or {}
	local widget = self:defaultWidget()
	if widget or options.force then
		self._ctrl:setFocus(widget)
		return widget and true
	end
end

function widget_group:_onNavigateToGroup(toGroup)
	if toGroup then
		return self._ctrl:enterGroup(unpack(toGroup))
	end
end

function widget_group:onNavigateUp()
	return self:_onNavigateToGroup(self._def.upToGroup)
end

function widget_group:onNavigateDown()
	return self:_onNavigateToGroup(self._def.downToGroup)
end

function widget_group:onNavigateLeft()
	return self:_onNavigateToGroup(self._def.leftToGroup)
end

function widget_group:onNavigateRight()
	return self:_onNavigateToGroup(self._def.rightToGroup)
end

-- ===

local list_group = class(widget_group)

function list_group:init( ctrl, def )
	widget_group.init(self, ctrl, def)
	self._widgets = {}
end

function list_group:addWidget( widget )
	-- Insert into a sorted list.
	local coord = widget:getControllerCoord()[1]
	for i, other in ipairs(self._widgets) do
		if other:getControllerCoord()[1] > coord then
			table.insert(self._widgets, i, widget)
			return
		end
	end
	table.insert(self._widgets, widget)
end
function list_group:removeWidget( widget )
	array.removeElement(self._widgets, widget)
end

function list_group:hasWidgets()
	return self._widgets[1] and true
end

function list_group:defaultWidget()
	if not self:hasWidgets() then
		return
	end

	if self._def.defaultCoord then
		local widget = array.findIf(self._widgets, matchSameCoord(self._def.defaultCoord))
		if widget and isAvailableWidget(widget) then
			return widget
		end
	end
	if self._def.defaultCoordChain then
		for _,default in ipairs(self._def.defaultCoordChain) do
			local widget = array.findIf(self._widgets, matchSameCoord(default))
			if widget and isAvailableWidget(widget) then
				return widget
			end
		end
	end
	return self:_nextActiveWidget(0)
end

function list_group:_prevActiveWidget( idx )
	local i = idx - 1
	while i >= 1 do
		local widget = self._widgets[i]
		if isAvailableWidget(widget) then
			return widget
		end
		i = i - 1
	end
end
function list_group:onNavigatePrev()
	local idx = array.find(self._widgets, self._ctrl._focusWidget)
	if idx > 1 then
		local prevWidget = self:_prevActiveWidget(idx)
		if prevWidget then
			self._ctrl:setFocus(prevWidget)
			return true
		end
	end
end

function list_group:_nextActiveWidget( idx )
	local i = idx + 1
	local size = #self._widgets
	while i <= size do
		local widget = self._widgets[i]
		if isAvailableWidget(widget) then
			return widget
		end
		i = i + 1
	end
end
function list_group:onNavigateNext()
	local idx = array.find(self._widgets, self._ctrl._focusWidget)
	if idx < #self._widgets then
		local nextWidget = self:_nextActiveWidget(idx)
		if nextWidget then
			self._ctrl:setFocus(nextWidget)
			return true
		end
	end
end

local hlist_group = class(list_group)
function hlist_group:onNavigateLeft()
	if self:onNavigatePrev() then
		return true
	end
	return widget_group.onNavigateLeft(self)
end
function hlist_group:onNavigateRight()
	if self:onNavigateNext() then
		return true
	end
	return widget_group.onNavigateRight(self)
end

local vlist_group = class(list_group)
function vlist_group:onNavigateUp()
	if self:onNavigatePrev() then
		return true
	end
	return widget_group.onNavigateUp(self)
end
function vlist_group:onNavigateDown()
	if self:onNavigateNext() then
		return true
	end
	return widget_group.onNavigateDown(self)
end


-- ==========
-- mui_screen
-- ==========

local screenctrl = class()

function screenctrl:init()
	self._screen = nil
	-- _widgetGrid[column][row]
	self._widgetGrid = nil
	self._focusWidget = nil
end

function screenctrl:_initFocus()
	local defaultGroup = self._def.defaultGroup
	if defaultGroup and self._groups[defaultGroup] and self._groups[defaultGroup]:onEnter() then
		return true
	end
	local defaultGroupChain = self._def.defaultGroupChain
	if defaultGroupChain then
		for _, defaultGroup in ipairs(defaultGroupChain) do
			if self._groups[defaultGroup] and self._groups[defaultGroup]:onEnter() then
				return true
			end
		end
	end
	if self._groups[1] then
		return self._groups[1]:onEnter()
	end
end

local GROUP_FACTORY = {
	VLIST = vlist_group,
	HLIST = hlist_group,
}

function screenctrl:onActivate(screen, layout)
	simlog("LOG_QEDCTRL", "padctrl:onActivate %s", tostring(screen._filename))
	self._screen = screen
	self._def = layout or {}
	self._focusWidget = nil
	self._groups = {}
	for i, groupDef in ipairs(self._def.groups or {}) do
		self._groups[i] = GROUP_FACTORY[groupDef.shape or 'VLIST'](self, groupDef)
	end

	screen:addEventHandler( self, mui_defs.EVENT_KeyDown )
end

function screenctrl:afterActivate()
	if self._def.forceController then
		inputmgr.setMouseEnabled(false)
	end
	if not inputmgr.isMouseEnabled() and self:hasWidgets() then
		self:_initFocus()
	end
end

function screenctrl:onDeactivate()
	simlog("LOG_QEDCTRL", "padctrl:onDeactivate %s", tostring(self._screen._filename))
	self._screen:removeEventHandler( self )
	self._screen, self._def = nil
	self._focusWidget, self._groups = nil
end

function screenctrl:addWidget( widget )
	local group = widget:getControllerGroup()
	local coord = widget:getControllerCoord()
	simlog("LOG_QEDCTRL", "padctrl:addWidget %s/%s %s g=%s", self._screen._filename, widget._def.name or "?ui?", util.tostringl(coord), tostring(group))

	self._groups[group] = self._groups[group] or vlist_group(self)
	self._groups[group]:addWidget(widget)
end

function screenctrl:removeWidget( widget )
	local group = widget:getControllerGroup()
	if self._groups[group] then
		self._groups[group]:removeWidget(widget)
	end
end

function screenctrl:enterGroup( group, ... )
	if self._groups[group] then
		return self._groups[group]:onEnter(...)
	end
end


function screenctrl:hasWidgets()
	return self._groups[1] and self._groups[1]:hasWidgets()
end

function screenctrl:setFocus( focusWidget )
	self._focusWidget = focusWidget
	if focusWidget then
		simlog("LOG_QEDCTRL", "padctrl:focus %s/%s %s g=%s", self._screen._filename, focusWidget._def.name or "?ui?", util.tostringl(focusWidget:getControllerCoord()), tostring(focusWidget:getControllerGroup()))
	else
		simlog("LOG_QEDCTRL", "padctrl:focus %s/nil", self._screen._filename)
	end
	self._screen:dispatchEvent({eventType = mui_defs.EVENT_FocusChanged, newFocus = focusWidget, oldFocus = self._screen._focusWidget })
	self._screen._focusWidget = focusWidget
end

local NAV_KEY = {
	[mui_defs.K_UPARROW] = [[onNavigateUp]],
	[mui_defs.K_DOWNARROW] = [[onNavigateDown]],
	[mui_defs.K_LEFTARROW] = [[onNavigateLeft]],
	[mui_defs.K_RIGHTARROW] = [[onNavigateRight]],
}

local function maybeAutoClick(self, widget)
	-- Confirm button can click immediately if there's only one widget in the screen.
	if widget and widget:getControllerDef().autoConfirm and widget.handleControllerClick then
		simlog("LOG_QEDCTRL", "padctrl:click %s %s AUTO", self._screen._filename, widget._def.name or "?ui?")
		return widget:handleControllerClick()
	end
	return true
end

function screenctrl:handleEvent( ev )
	-- simlog("LOG_QEDCTRL", "padctrl:handleEvent %s %s %s", self._screen._filename, tostring(ev.eventType), tostring(ev.key))
	local isConfirmBinding = mui_util.isBinding(ev, mui_defs.K_PERIOD)
	if not (ev.eventType == mui_defs.EVENT_KeyDown
			and (isConfirmBinding or NAV_KEY[ev.key])
			and self:hasWidgets()
	) then
		return
	end

	if not self._focusWidget then
		-- Focus the default widget.
		inputmgr.setMouseEnabled(false)
		self:_initFocus()

		if isConfirmBinding then
			return maybeAutoClick(self, self._focusWidget)
		end
		return true
	elseif inputmgr.isMouseEnabled() then
		-- Refocus the most recent controller focus.
		inputmgr.setMouseEnabled(false)
		self:setFocus(self._focusWidget)

		if isConfirmBinding then
			return maybeAutoClick(self, self._focusWidget)
		end
		return true
	elseif isConfirmBinding then
		if self._focusWidget.handleControllerClick then
			simlog("LOG_QEDCTRL", "padctrl:click %s %s", self._screen._filename, self._focusWidget._def.name or "?ui?")
			return self._focusWidget:handleControllerClick()
		end
		return true
	end

	-- Navigation key pressed.
	local navCall = NAV_KEY[ev.key]
	local widget = self._focusWidget
	local group = self._groups[widget:getControllerGroup()]

	if widget[navCall] and widget[navCall](widget) then
		return true
	end
	if group[navCall](group) then
		return true
	end
	return true
end

return {
	screenctrl = screenctrl,
}
