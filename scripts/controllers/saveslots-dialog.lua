local util = include( "client_util" )

local dialog = include( "fe/saveslots-dialog" )

local STATE_SELECT_SAVE = 1
local STATE_CONTINUE_GAME = 2
local STATE_NEW_GAME = 3


local oldShow = dialog.show
function dialog:show( ... )
	oldShow( self, ... )
 
	-- TODO: Set these as hidden selections if mouse is active.
	local user = savefiles.getCurrentGame()
	local ctrl = self._screen:getControllerControl()
	ctrl:navigateTo({}, "main", "saveSlots", user.data.lastSaveSlot)
end

local oldShowState = dialog.showState
function dialog:showState( state, campaign, ... )
	oldShowState( self, state, campaign, ... )

	-- TODO: Changing layouts here doesn't work. Because of the transitions, the popup widgets aren't visible yet.
	local ctrl = self._screen:getControllerControl()
	if state == STATE_NEW_GAME then
		ctrl:setRoot("newGame")
	elseif state == STATE_CONTINUE_GAME then
		ctrl:setRoot("continueGame")
	else -- STATE_SELECT_SAVE
		ctrl:navigateTo({recall=true}, "main", "saveSlots")
	end
end
