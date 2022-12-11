local util = include(SCRIPT_PATHS.qedctrl.."/screen_util")
local ctrlID = util.modificationDef.ctrlID
local skinButton = util.modificationDef.skinButton
local widgetList = util.layoutDef.widgetList

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
	-- panel/
	modifyWidget(3, ctrlID("saveSlots", { listBoxSelectsItems = true })), -- listbox[SaveSlot]
	modifyWidget(8, skinButton(ctrlID"cancelGame")),
	-- panel/newGame/
	modifySubWidget(6,1, ctrlID"storyBtn"),
	modifySubWidget(6,2, ctrlID"tutorialBtn"),
	modifySubWidget(6,3, ctrlID"cancelGameBtn"),
	-- panel/continueGame/
	modifySubWidget(7,1, ctrlID"continueBtn"),
	modifySubWidget(7,2, ctrlID"deleteBtn"),
	modifySubWidget(7,3, ctrlID"cancelContinueBtn"),

	util.setLayouts("modal-saveslots.lua",
		{
			{
				id = "main",
				children = widgetList("saveSlots", "cancelGame"),
			},
			{
				id = "newGame",
				children = widgetList("storyBtn", "tutorialBtn", "cancelGameBtn"),
			},
			{
				id = "continueGame",
				children = widgetList("continueBtn", "deleteBtn", "cancelContinueBtn"),
				defaultChain = {"continueBtn", "cancelContinueBtn"}, -- skip deleteBtn if continueBtn is disabled.
			},
		},
		{ defaultLayout = "main" }
	),
}

return modifications
