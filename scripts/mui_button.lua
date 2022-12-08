local mui_defs = include("mui/mui_defs")
local mui_util = include("mui/mui_util")
local mui_button = include("mui/widgets/mui_button")

local oldInit = mui_button.init
function mui_button:init( def, ... )
	oldInit( self, def, ... )

	self._ctrlindex = def.ctrlindex
	if def.ctrlindex then
		assert(type(def.ctrlindex) == "table", def.name)
	end
end

function mui_button:setControllerIndex(c, r)
	self._ctrlindex = {c, r}
end

function mui_button:getControllerIndex()
	return self._ctrlindex
end

function mui_button:isDisabled()
	return self._buttonState == mui_button.BUTTON_Disabled
end


local oldOnActivate = mui_button.onActivate
function mui_button:onActivate( screen, ... )
	oldOnActivate(self, screen, ...)
	if self._ctrlindex then
		screen._padctrl:addWidget(self)
	end
end

local oldOnDeactivate = mui_button.onDeactivate
function mui_button:onDeactivate( screen, ... )
	if self._ctrlindex then
		screen._padctrl:removeWidget(self)
	end
	oldOnDeactivate(self, screen, ...)
end

local function isCancelBtn( self )
	-- "Cancel" is an alternate binding for all hard-coded ESC bindings and most "pause" bindings.
	return self._hotkey == mui_defs.K_ESCAPE or (
	  self._hotkey == "pause" and not self._def.name ~= "menuBtn"
	)
end

local oldHandleEvent = mui_button.handleEvent
function mui_button:handleEvent( ev, ... )
	if isCancelBtn(self) and ev.eventType == mui_defs.EVENT_KeyDown and self:isVisible() then
		local cancelBinding = mui_defs.K_COMMA
		if mui_util.isBinding(ev, cancelBinding) then
			self:dispatchEvent( {
                eventType = mui_defs.EVENT_ButtonHotkey,
                widget = self,
                disabled = (self._buttonState == mui_button.BUTTON_Disabled),
                ie = ev } )
			return true
		end
	end

	return oldHandleEvent(self, ev, ...)
end
