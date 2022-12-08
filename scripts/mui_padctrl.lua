local array = include("modules/array")
local mui_defs = include("mui/mui_defs")

-- Widgets can specify ctrlindex = { column, row } to be placed in the controller-accessible grid.
-- Column is densely specified (c=2 is inserted into the second column)
-- Row can be an arbitrary number that will be sorted within that column


local function insertSorted(t, widget)
	local r = widget:getControllerIndex()[2]
	for i, v in ipairs(t) do
		if v:getControllerIndex()[2] > r then
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

function screenctrl:onActivate(screen)
	simlog("LOG_QEDCTRL", "padctrl:onActivate %s", tostring(screen._filename))
	self._screen = screen
	self._widgetGrid = {}
	self._focusWidget = nil
	screen:addEventHandler( self, mui_defs.EVENT_KeyDown )
end

function screenctrl:afterActivate()
	if not inputmgr.isMouseEnabled() and self:hasWidgets() then
		self:setFocus(self._focusWidget or nextActiveWidget(self._widgetGrid[1], 0))
	end
end

function screenctrl:onDeactivate()
	simlog("LOG_QEDCTRL", "padctrl:onDeactivate %s", tostring(self._screen._filename))
	self._screen:removeEventHandler( self )
	self._screen, self._focusWidget = nil
	self._widgetGrid = nil
end

function screenctrl:addWidget( widget )
	c,r = widget:getControllerIndex()[1], widget:getControllerIndex()[2]
	simlog("LOG_QEDCTRL", "padctrl:addWidget %s %s %s,%s", self._screen._filename, widget._def.name or "?ui?", tostring(c), tostring(r))
	local c = widget:getControllerIndex()[1]
	self._widgetGrid[c] = self._widgetGrid[c] or {}
	insertSorted(self._widgetGrid[c], widget)
end

function screenctrl:removeWidget( widget )
	local c = widget:getControllerIndex()[1]
	if self._widgetGrid[c] then
		array.removeElement(self._widgetGrid[c], widget)
	end
end

function screenctrl:hasWidgets()
	return self._widgetGrid[1] and self._widgetGrid[1][1]
end

function screenctrl:setFocus( focusWidget )
	self._focusWidget = focusWidget
	c,r = focusWidget:getControllerIndex()[1], focusWidget:getControllerIndex()[2]
	simlog("LOG_QEDCTRL", "padctrl:focus %s %s %s,%s", self._screen._filename, focusWidget._def.name or "?ui?", tostring(c), tostring(r) )
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

function screenctrl:handleEvent( ev )
	-- simlog("LOG_QEDCTRL", "padctrl:handleEvent %s %s %s", self._screen._filename, tostring(ev.eventType), tostring(ev.key))
	if ev.eventType == mui_defs.EVENT_KeyDown and self:hasWidgets() and isPadCtrlKey( ev.key ) then
		if not self._focusWidget then
			inputmgr.setMouseEnabled(false)
			self:setFocus(nextActiveWidget(self._widgetGrid[1], 0))
			return true
		elseif inputmgr.isMouseEnabled() then
			inputmgr.setMouseEnabled(false)
			self:setFocus(self._focusWidget)
			return true
		else
			local widgetLine = self._widgetGrid[self._focusWidget:getControllerIndex()[1]]
			local idx = array.find(widgetLine, self._focusWidget)
			if ev.key == mui_defs.K_UPARROW and idx > 1 then
				local prevWidget = prevActiveWidget(widgetLine, idx)
				if prevWidget then
					self:setFocus(prevWidget)
				end
				return true
			elseif ev.key == mui_defs.K_DOWNARROW and idx < #widgetLine then
				local nextWidget = nextActiveWidget(widgetLine, idx)
				if nextWidget then
					self:setFocus(nextWidget)
				end
				return true
			elseif ev.key == mui_defs.K_PERIOD and self._focusWidget.dispatchEvent then
				simlog("LOG_QEDCTRL", "padctrl:focus %s %s CLICK", self._screen._filename, self._focusWidget._def.name or "?ui?")
				self._focusWidget:dispatchEvent({eventType = mui_defs.EVENT_ButtonClick, widget=self._focusWidget, ie = {}})
				return true
			end
		end
	end
end

return {
	screenctrl = screenctrl,
}
