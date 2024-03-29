local util = include("client_util")

local dialog = include("fe/saveslots-dialog")

local STATE_SELECT_SAVE = 1
local STATE_CONTINUE_GAME = 2
local STATE_NEW_GAME = 3

local oldShow = dialog.show
function dialog:show(...)
    oldShow(self, ...)

    local user = savefiles.getCurrentGame()
    local ctrl = self._screen:getControllerControl()
    ctrl:navigateTo({force = true}, "main", "saveSlots", user.data.lastSaveSlot)
end

local oldShowState = dialog.showState
function dialog:showState(state, campaign, ...)
    oldShowState(self, state, campaign, ...)

    local ctrl = self._screen:getControllerControl()
    if state == STATE_NEW_GAME then
        ctrl:setRoot("newGame", {force = true})
    elseif state == STATE_CONTINUE_GAME then
        ctrl:setRoot("continueGame", {force = true})
    else -- STATE_SELECT_SAVE
        ctrl:navigateTo({force = true, recall = true}, "main", "saveSlots")
    end
end
