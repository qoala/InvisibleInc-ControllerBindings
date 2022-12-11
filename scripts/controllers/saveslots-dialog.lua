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
	local listbox = self._screen.binder.listbox
	if user.data.lastSaveSlot then
		listbox:setControllerFocus(user.data.lastSaveSlot)
	else
		listbox:onControllerFocus()
	end
end

local oldShowState = dialog.showState
function dialog:showState( state, campaign, ... )
	oldShowState( self, state, campaign, ... )

	-- TODO: Changing groups here doesn't work. Because of the transitions, the popup widgets aren't visible yet.
	local ctrl = self._screen:getControllerControl()
	if state == STATE_NEW_GAME then
		ctrl:enterGroup(2)
	elseif state == STATE_CONTINUE_GAME then
		ctrl:enterGroup(3)
	else -- STATE_SELECT_SAVE
		ctrl:enterGroup(1)
	end
end
