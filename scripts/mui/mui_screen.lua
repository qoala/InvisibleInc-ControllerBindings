local mui_defs = include("mui/mui_defs")
local util = include( "client_util" )

local mui_screen = include("mui/mui_screen")

local mui_padctrl = include(SCRIPT_PATHS.qedctrl.."/mui/mui_padctrl")

local oldInit = mui_screen.init
function mui_screen:init( ... )
	oldInit( self, ... )

	self._qedctrl_ctrl = mui_padctrl.screenctrl(self._props.ctrlProperties)

	-- Hide the sinksInput flag from the vanilla handleInputEvent.
	self._qedctrl_sinksInput = self._props.sinksInput
	self._props = util.tdupe(self._props)
	self._props.sinksInput = false
end

function mui_screen:getControllerControl()
	return self._qedctrl_ctrl
end

local oldOnActivate = mui_screen.onActivate
function mui_screen:onActivate( ... )
	self._qedctrl_ctrl:onActivate(self) -- Prepare to receive widgets.

	oldOnActivate( self, ... )

	self._qedctrl_ctrl:afterActivate() -- Finalize for input.
end

local oldOnDeactivate = mui_screen.onDeactivate
function mui_screen:onDeactivate( ... )
	-- Don't leave widgets focused, in case this screen is reused.
	if self._focusWidget then
		self:dispatchEvent({eventType = mui_defs.EVENT_FocusChanged, newFocus = nil, oldFocus = self._focusWidget })
	end

	self._qedctrl_ctrl:onDeactivate()
	oldOnDeactivate( self, ... )
end

local oldHandleInputEvent = mui_screen.handleInputEvent
function mui_screen:handleInputEvent( ev, ... )
	local handled = oldHandleInputEvent( self, ev, ... )

	if (not handled and ev.eventType == mui_defs.EVENT_KeyDown and util.isKeyBindingEvent("QEDCTRL_CANCEL", ev)) then
		-- Treat "cancel" as "Esc" in screens that don't have a native cancel binding.
		local fakeEv = util.tdupe(ev)
		fakeEv.key = mui_defs.K_ESCAPE
		handled = oldHandleInputEvent( self, fakeEv, ... )
	end

	return handled or self._qedctrl_sinksInput
end
