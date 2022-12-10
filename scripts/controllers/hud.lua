local mui_defs = include("mui/mui_defs")
local util = include( "client_util" )

local hud = include( "hud/hud" )

local end_turn_dialog = include(SCRIPT_PATHS.qedctrl.."/controllers/end_turn_dialog")

--

function onClickEndTurnMenu( hud )
	if hud._state ~= hud.STATE_NULL then
		hud:transitionNull()
	else
		local result = hud._qedctrl_endTurnDialog:show()
		if result == end_turn_dialog.END_TURN then
			local button = hud._endTurnButton._button
			button:dispatchEvent({eventType = mui_defs.EVENT_ButtonClick, widget=button, ie = {}})
		elseif result == end_turn_dialog.REWIND then
			local button = hud._screen.binder.rewindBtn._button
			button:dispatchEvent({eventType = mui_defs.EVENT_ButtonClick, widget=button, ie = {}})
		end
	end
end

--

local oldCreateHud = hud.createHud
hud.createHud = function( ... )
	local hudObject = oldCreateHud( ... )

	do
		local btnEndTurnMenu = hudObject._screen.binder.qedctrlEndTurnMenu
		if btnEndTurnMenu and not btnEndTurnMenu.isnull then
			hudObject._qedctrl_endTurnDialog = end_turn_dialog(hudObject._game)

			btnEndTurnMenu.onClick = util.makeDelegate(nil, onClickEndTurnMenu, hudObject)
		end
	end

	local oldDestroyHud = hudObject.destroyHud
	function hudObject:destroyHud()
		if self._qedctrl_endTurnDialog then
			self._qedctrl_endTurnDialog:hide()
			self._qedctrl_endTurnDialog = nil
		end

		oldDestroyHud(self)
	end

	return hudObject
end
