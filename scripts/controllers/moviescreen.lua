local mui_defs = include("mui/mui_defs")
local util = include( "client_util" )

local moviescreen = include( "client/fe/moviescreen" )

local oldOnInputEvent = moviescreen.onInputEvent
function moviescreen:onInputEvent( event, ... )
	-- Intercept CANCEL here. This class binds as an input listener directly,
	-- bypassing the mui_screen redirect from CANCEL to PAUSE.
	if (event.eventType == mui_defs.EVENT_KeyUp
		and util.isKeyBindingEvent("QEDCTRL_CANCEL", event))
	then
		self.done_playing = true
		return true
	end

	return oldOnInputEvent(self, event, ...)
end
