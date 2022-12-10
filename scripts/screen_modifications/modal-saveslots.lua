local util = include(SCRIPT_PATHS.qedctrl.."/screen_util")
local ctrlGroupCoord = util.ctrlGroupCoord
local skinButton = util.skinButton

local function modifyWidget(childIndex, modification)
	return {
		"modal-saveslots.lua",
		{ "widgets", 2, "children", childIndex },
		modification,
	}
end
local function modifySubWidget(childIndex1, childIndex2, modification)
	return {
		"modal-saveslots.lua",
		{ "widgets", 2, "children", childIndex1, "children", childIndex2 },
		modification,
	}
end

local modifications = {
	util.setLayout("modal-saveslots.lua", {
		{}, -- panel
		{}, -- newGame
		{ defaultCoordChain = {{1}, {3}} }, -- continueGame prefers continue, but falls back to cancel before delete.
	}),
	-- panel/
	modifyWidget(3, ctrlGroupCoord(1, {1}, { listBoxSelectsItems = true })), -- listbox[SaveSlot]
	modifyWidget(8, skinButton(ctrlGroupCoord(1, {2}))), -- cancelGame
	-- panel/newGame/
	modifySubWidget(6,1, ctrlGroupCoord(2, {1})), -- storyBtn
	modifySubWidget(6,2, ctrlGroupCoord(2, {2})), -- tutorialBtn
	modifySubWidget(6,3, ctrlGroupCoord(2, {3})), -- cancelGameBtn
	-- panel/continueGame/
	modifySubWidget(7,1, ctrlGroupCoord(3, {1})), -- continueBtn
	modifySubWidget(7,2, ctrlGroupCoord(3, {2})), -- deleteBtn
	modifySubWidget(7,3, ctrlGroupCoord(3, {3})), -- cancelContinueBtn
}

return modifications
