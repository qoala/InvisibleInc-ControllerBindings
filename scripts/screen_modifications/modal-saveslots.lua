local sutil = include(SCRIPT_PATHS.qedctrl.."/screen_util")
local ctrlID = sutil.ctrlID
local skinButton = sutil.skinButton

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
	modifyWidget(3, ctrlID("saveSlots")), -- listbox[SaveSlot]
	modifyWidget(8, skinButton(ctrlID"cancelGame")),
	-- panel/newGame/
	modifySubWidget(6,1, ctrlID"storyBtn"),
	modifySubWidget(6,2, ctrlID"tutorialBtn"),
	modifySubWidget(6,3, ctrlID"cancelGameBtn"),
	-- panel/continueGame/
	modifySubWidget(7,1, ctrlID"continueBtn"),
	modifySubWidget(7,2, ctrlID"deleteBtn"),
	modifySubWidget(7,3, ctrlID"cancelContinueBtn"),

	sutil.setLayouts("modal-saveslots.lua",
		{ -- 3 independent roots; saveslot-dialog.lua swaps them out as submenus open/close.
			{
				id = "main",
				children =
				{
					sutil.widget("saveSlots", 1, { widgetType = [[listbox]] }),
					sutil.widget("cancelGame", 2),
				},
			},
			{
				id = "newGame",
				children = sutil.widgetList("storyBtn", "tutorialBtn", "cancelGameBtn"),
			},
			{
				id = "continueGame",
				children = sutil.widgetList("continueBtn", "deleteBtn", "cancelContinueBtn"),
				defaultChain = {"continueBtn", "cancelContinueBtn"}, -- skip deleteBtn if continueBtn is disabled.
			},
		}
	),
}

return modifications
