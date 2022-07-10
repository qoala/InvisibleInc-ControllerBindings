local array = include("modules/array")
local mui_defs = include("mui/mui_defs")

local mui_padctrl = class()

-- Widgets can specify ctrlindex = { column, row } to be placed in the controller-accessible grid.
-- Column is densely specified (c=2 is inserted into the second column)
-- Row can be an arbitrary number that will be sorted within that column

function mui_padctrl:init()
	-- _widgetGrid[column][row]
	self._widgetGrid = {}
	self._focusWidget = nil
end

function mui_padctrl:onActivate(screen)
	simlog("LOG_QEDCTRL", "padctrl:onActivate %s", tostring(screen._filename))
	self._screen = screen
	self._focusWidget = nil
	screen:addEventHandler( self, mui_defs.EVENT_KeyDown )
end

function mui_padctrl:onDeactivate()
	simlog("LOG_QEDCTRL", "padctrl:onDeactivate %s", tostring(self._screen._filename))
	self._screen:removeEventHandler( self )
	self._screen, self._focusWidget = nil
end

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

function mui_padctrl:addWidget( widget )
	c,r = widget:getControllerIndex()[1], widget:getControllerIndex()[2]
	simlog("LOG_QEDCTRL", "padctrl:addWidget %s %s %s,%s", self._screen._filename, widget._def.name or "?ui?", tostring(c), tostring(r))
	local c = widget:getControllerIndex()[1]
	self._widgetGrid[c] = self._widgetGrid[c] or {}
	insertSorted(self._widgetGrid[c], widget)
end

function mui_padctrl:removeWidget( widget )
	local c = widget:getControllerIndex()[1]
	if self._widgetGrid[c] then
		array.removeElement(self._widgetGrid[c], widget)
	end
end

function mui_padctrl:hasWidgets()
	return self._widgetGrid[1] and self._widgetGrid[1][1]
end

local function isPadCtrlKey( key )
	return (
		key == mui_defs.K_LEFTARROW or
		key == mui_defs.K_UPARROW or
		key == mui_defs.K_RIGHTARROW or
		key == mui_defs.K_DOWNARROW or
		key == mui_defs.K_COMMA or
		key == mui_defs.K_PERIOD
	)
end

local function setFocus( screen, focusWidget )
	c,r = focusWidget:getControllerIndex()[1], focusWidget:getControllerIndex()[2]
	simlog("LOG_QEDCTRL", "padctrl:focus %s %s %s,%s", screen._filename, focusWidget._def.name or "?ui?", tostring(c), tostring(r) )
	screen:dispatchEvent({eventType = mui_defs.EVENT_FocusChanged, newFocus = focusWidget, oldFocus = screen._focusWidget })
	screen._focusWidget = focusWidget
end

function mui_padctrl:handleEvent( ev )
	-- simlog("LOG_QEDCTRL", "padctrl:handleEvent %s %s %s", self._screen._filename, tostring(ev.eventType), tostring(ev.key))
	if ev.eventType == mui_defs.EVENT_KeyDown and self:hasWidgets() and isPadCtrlKey( ev.key ) then
		if not self._focusWidget then
			self._focusWidget = self._widgetGrid[1][1]
			inputmgr.setMouseEnabled(false)
			setFocus(self._screen, self._focusWidget)
			return true
		elseif inputmgr.isMouseEnabled() then
			inputmgr.setMouseEnabled(false)
			setFocus(self._screen, self._focusWidget)
			return true
		else
			local widgetLine = self._widgetGrid[self._focusWidget:getControllerIndex()[1]]
			local idx = array.find(widgetLine, self._focusWidget)
			if ev.key == mui_defs.K_UPARROW and idx > 1 then
				self._focusWidget = widgetLine[idx - 1]
				setFocus(self._screen, self._focusWidget)
				return true
			elseif ev.key == mui_defs.K_DOWNARROW and idx < #widgetLine then
				self._focusWidget = widgetLine[idx + 1]
				setFocus(self._screen, self._focusWidget)
				return true
			elseif ev.key == mui_defs.K_PERIOD then
				simlog("LOG_QEDCTRL", "padctrl:focus %s %s CLICK", self._screen._filename, self._focusWidget._def.name or "?ui?")
				self._focusWidget:dispatchEvent({eventType = mui_defs.EVENT_ButtonClick, widget=self._focusWidget, ie = {}})
			end
		end
	end
end

return mui_padctrl
