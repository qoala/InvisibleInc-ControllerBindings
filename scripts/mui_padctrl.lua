local array = include("modules/array")
local util = require( "modules/util" )
local mui_defs = include("mui/mui_defs")

-- Widgets can specify the following fields in their def to be placed in the controller-accessible grid:
-- * ctrlCoord = { index }:
--     Index position of this widget. Widgets will be sorted within their group, so this need not be densely packed.
-- * ctrlGroup = groupID (default 1):
--     Allows placing widgets in independent grids for better logical arrangement.

-- Screens can specify details of their controller-accessible grids in { properties = { ctrlLayout = {} } }.
--
-- * groups = { group1Def, group2Def, ... }:
--     Specify properties of a widget group.
--   * shape = shapeID (default VLIST=1):
--       Shape values (below) define how coordinates for this group's widgets are interpreted.
--   * defaultCoords = { {index}, {fallbackIndex}, ... }:
--       Specify the default widget when first entering this group. The first available index (accounting for hidden/disabled elements) will be focused.

-- Group shape values
local VLIST = 1 -- Vertical list, starting from the top.
local HLIST = 2 -- Horizontal list, starting from the left.



local function insertSorted(t, widget)
	local idx = widget:getControllerCoord()[1]
	for i, other in ipairs(t) do
		if other:getControllerCoord()[1] > idx then
			table.insert(t, i, widget)
			return
		end
	end
	table.insert(t, widget)
end

local function isAvailableWidget( widget )
	return widget:isVisible() and (not widget.isDisabled or not widget:isDisabled())
end

local function nextActiveWidget( widgetLine, idx )
	local i = idx + 1
	local size = #widgetLine
	while i <= size do
		local widget = widgetLine[i]
		if isAvailableWidget(widget) then
			return widget
		end
		i = i + 1
	end
end

local function prevActiveWidget( widgetLine, idx )
	local i = idx - 1
	while i >= 1 do
		local widget = widgetLine[i]
		if isAvailableWidget(widget) then
			return widget
		end
		i = i - 1
	end
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

function screenctrl:_groupDef(group)
	return (self._def.groups and self._def.groups[group]) or {}
end

local function matchSameCoord(coord)
	return function(w)
		local wc = w:getControllerCoord()
		return wc[1] == coord[1]
	end
end

function screenctrl:_getDefaultWidget()
	local groupDef = self:_groupDef(self._focusGroup)
	local widgetLine = self._widgetGrid[self._focusGroup]
	if not widgetLine[1] then
		return
	end
	local widget = nil

	if groupDef.defaultCoords then
		for _,default in ipairs(groupDef.defaultCoords) do
			widget = array.findIf(widgetLine, matchSameCoord(default))
			if widget and isAvailableWidget(widget) then
				return widget
			end
		end
	end

	return nextActiveWidget(widgetLine, 0)
end

function screenctrl:onActivate(screen, layout)
	simlog("LOG_QEDCTRL", "padctrl:onActivate %s", tostring(screen._filename))
	self._screen = screen
	self._def = layout or {}
	self._widgetGrid = {}
	self._focusWidget = nil
	self._focusGroup = 1
	screen:addEventHandler( self, mui_defs.EVENT_KeyDown )
end

function screenctrl:afterActivate()
	if not inputmgr.isMouseEnabled() and self:hasWidgets() then
		self:setFocus(self._focusWidget or self:_getDefaultWidget())
	end
end

function screenctrl:onDeactivate()
	simlog("LOG_QEDCTRL", "padctrl:onDeactivate %s", tostring(self._screen._filename))
	self._screen:removeEventHandler( self )
	self._screen, self._focusWidget = nil
	self._widgetGrid = nil
end

function screenctrl:addWidget( widget )
	local group = widget:getControllerGroup()
	local coord = widget:getControllerCoord()
	simlog("LOG_QEDCTRL", "padctrl:addWidget %s/%s %s g=%s", self._screen._filename, widget._def.name or "?ui?", util.tostringl(coord), tostring(group))

	local idx = coord[1]
	self._widgetGrid[group] = self._widgetGrid[group] or {}
	insertSorted(self._widgetGrid[group], widget)
end

function screenctrl:removeWidget( widget )
	local group = widget:getControllerGroup()
	if self._widgetGrid[group] then
		array.removeElement(self._widgetGrid[group], widget)
	end
end

function screenctrl:hasWidgets()
	return self._widgetGrid[1] and self._widgetGrid[1][1]
end

function screenctrl:setFocus( focusWidget )
	self._focusWidget = focusWidget
	self._focusGroup = focusWidget:getControllerGroup()
	if focusWidget then
		simlog("LOG_QEDCTRL", "padctrl:focus %s/%s %s g=%s", self._screen._filename, focusWidget._def.name or "?ui?", util.tostringl(focusWidget:getControllerCoord()), tostring(focusWidget:getControllerGroup()))
	else
		simlog("LOG_QEDCTRL", "padctrl:focus %s/nil", self._screen._filename)
	end
	self._screen:dispatchEvent({eventType = mui_defs.EVENT_FocusChanged, newFocus = focusWidget, oldFocus = self._screen._focusWidget })
	self._screen._focusWidget = focusWidget
end

local function isPadCtrlKey( key )
	return (
		key == mui_defs.K_LEFTARROW or
		key == mui_defs.K_UPARROW or
		key == mui_defs.K_RIGHTARROW or
		key == mui_defs.K_DOWNARROW or
		key == mui_defs.K_PERIOD
	)
end

local function maybeAutoClick(self)
	-- Confirm button can click immediately if there's only one widget in the screen.
	local singleWidget = #self._widgetGrid == 1 and #self._widgetGrid[self._focusGroup] == 1
	if self._focusWidget.handleControllerClick and singleWidget then
		simlog("LOG_QEDCTRL", "padctrl:click %s %s AUTO", self._screen._filename, self._focusWidget._def.name or "?ui?")
		return self._focusWidget:handleControllerClick()
	end
	return true
end

local function isPrevBinding(key, shape)
	return (
		(shape == VLIST and key == mui_defs.K_UPARROW)
		or (shape == HLIST and key == mui_defs.K_LEFTARROW)
	)
end
local function isNextBinding(key, shape)
	return (
		(shape == VLIST and key == mui_defs.K_DOWNARROW)
		or (shape == HLIST and key == mui_defs.K_RIGHTARROW)
	)
end

function screenctrl:handleEvent( ev )
	-- simlog("LOG_QEDCTRL", "padctrl:handleEvent %s %s %s", self._screen._filename, tostring(ev.eventType), tostring(ev.key))
	if not (ev.eventType == mui_defs.EVENT_KeyDown and self:hasWidgets() and isPadCtrlKey( ev.key )) then
		return
	end

	if not self._focusWidget then
		-- Focus the default widget.
		inputmgr.setMouseEnabled(false)
		self:setFocus(self:_getDefaultWidget())

		if ev.key == mui_defs.K_PERIOD and self._focusWidget then
			return maybeAutoClick(self)
		end
		return true
	elseif inputmgr.isMouseEnabled() then
		-- Refocus the most recent controller focus.
		inputmgr.setMouseEnabled(false)
		self:setFocus(self._focusWidget)

		if ev.key == mui_defs.K_PERIOD and self._focusWidget then
			return maybeAutoClick(self)
		end
		return true
	elseif ev.key == mui_defs.K_PERIOD and self._focusWidget.handleControllerClick then
		simlog("LOG_QEDCTRL", "padctrl:click %s %s", self._screen._filename, self._focusWidget._def.name or "?ui?")
		return self._focusWidget:handleControllerClick()
	end

	-- Navigation key pressed.
	local groupDef = self:_groupDef(self._focusGroup)
	local widgetLine = self._widgetGrid[self._focusGroup]
	local idx = array.find(widgetLine, self._focusWidget)
	if isPrevBinding(ev.key, groupDef.shape or 1) and idx > 1 then
		local prevWidget = prevActiveWidget(widgetLine, idx)
		if prevWidget then
			self:setFocus(prevWidget)
		end
		return true
	elseif isNextBinding(ev.key, groupDef.shape or 1) and idx < #widgetLine then
		local nextWidget = nextActiveWidget(widgetLine, idx)
		if nextWidget then
			self:setFocus(nextWidget)
		end
		return true
	end
end

return {
	screenctrl = screenctrl,
}
