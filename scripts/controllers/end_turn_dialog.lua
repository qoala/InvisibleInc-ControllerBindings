local mui = include( "mui/mui" )
local cdefs = include( "client_defs" )
local util = include( "client_util" )

--

local RESULT_RESUME = 0
local RESULT_END_TURN = 1
local RESULT_REWIND = 2

function onClickResult( dialog, result )
	dialog:hide()
	dialog.result = result
end

--

local end_turn_dialog = class()

end_turn_dialog.RESUME = RESULT_RESUME
end_turn_dialog.END_TURN = RESULT_END_TURN
end_turn_dialog.REWIND = RESULT_REWIND

function end_turn_dialog:init( game )
	local screen = mui.createScreen("qedctrl-end-turn-dialog.lua")
	self._game = game
	self._screen = screen

	screen.binder.pnl.binder.resumeBtn.onClick = util.makeDelegate(nil, onClickResult, self, RESULT_RESUME)
	local endTurnBtn = screen.binder.pnl.binder.endTurnBtn
	endTurnBtn.onClick = util.makeDelegate(nil, onClickResult, self, RESULT_END_TURN)
	local rewindBtn = screen.binder.pnl.binder.rewindBtn
	rewindBtn.onClick = util.makeDelegate(nil, onClickResult, self, RESULT_REWIND)
end

function end_turn_dialog:show()
	mui.activateScreen( self._screen )
	FMODMixer:pushMix( "quiet" )
	MOAIFmodDesigner.playSound( cdefs.SOUND_HUD_GAME_POPUP )

	if self._game then
		local sim = self._game.simCore
		local rewindsAvailable = (sim:getTags().rewindsLeft or 0) > 0 and not sim:getTags().isTutorial and self._game.hud:canShowElement( "rewindBtn" )
		self._screen.binder.rewindBtn:setDisabled(not rewindsAvailable)
	end

	self.result = nil

	while self.result == nil do
		coroutine.yield()
	end

	return self.result
end

function end_turn_dialog:hide()
	if self._screen:isActive() then
		mui.deactivateScreen( self._screen )
		FMODMixer:popMix( "quiet" )
	end
end

return end_turn_dialog
