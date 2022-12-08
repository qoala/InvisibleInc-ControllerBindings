local mui_defs = include("mui/mui_defs")
local mui_screen = include("mui/mui_screen")
local mui_util = include("mui/mui_util")
local util = include( "client_util" )

local mui_padctrl = include(SCRIPT_PATHS.qedctrl.."/mui_padctrl")

local oldInit = mui_screen.init
function mui_screen:init( ... )
	oldInit( self, ... )

	-- simlog("LOG_QEDCTRL", "screen:init %s", self._filename )
	self._padctrl = mui_padctrl.screenctrl()

	-- Hide the sinksInput flag from the vanilla handleInputEvent.
	self._qedctrl_sinksInput = self._props.sinksInput
	self._props = util.tdupe(self._props)
	self._props.sinksInput = false
end

local oldOnActivate = mui_screen.onActivate
function mui_screen:onActivate( ... )
	self._padctrl:onActivate( self )
	oldOnActivate( self, ... )
	self._padctrl:afterActivate()
end

local oldOnDeactivate = mui_screen.onDeactivate
function mui_screen:onDeactivate( ... )
	oldOnDeactivate( self, ... )
	self._padctrl:onDeactivate()
end

local oldHandleInputEvent = mui_screen.handleInputEvent
function mui_screen:handleInputEvent( ev, ... )
	local handled = oldHandleInputEvent( self, ev, ... )

	if (not handled and ev.eventType == mui_defs.EVENT_KeyDown and mui_util.isBinding(ev, mui_defs.K_COMMA)) then
		-- Treat "cancel" as "Esc" in screens that don't have a native cancel binding.
		local fakeEv = util.tdupe(ev)
		fakeEv.key = mui_defs.K_ESCAPE
		handled = oldHandleInputEvent( self, fakeEv, ... )
	end

	return handled or self._qedctrl_sinksInput
end
