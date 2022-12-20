local sutil = include(SCRIPT_PATHS.qedctrl.."/screen_util")
local ctrlID = sutil.ctrlID

local function skinAgentItem(modification)
	return { inheritDef = { ["item"] = sutil.skinButton(modification), }, }
end

local function modifyWidget(childIndex, modification)
	return {
		"modal-monst3r.lua",
		{ "widgets", 2, "children", childIndex },
		modification,
	}
end
local function modifySubWidget(childIndex1, childIndex2, modification)
	return {
		"modal-monst3r.lua",
		{ "widgets", 2, "children", childIndex1, "children", childIndex2 },
		modification,
	}
end

local modifications = {
	modifyWidget(13, ctrlID("taswellInfoBtn")),
	modifyWidget(7, skinAgentItem(ctrlID("monst3rSellItem"))),
	modifySubWidget(5, 9, ctrlID("cycleStashLeftBtn")),
	modifySubWidget(5, 2, skinAgentItem(ctrlID("stashItem1"))),
	modifySubWidget(5, 3, skinAgentItem(ctrlID("stashItem2"))),
	modifySubWidget(5, 4, skinAgentItem(ctrlID("stashItem3"))),
	modifySubWidget(5, 5, skinAgentItem(ctrlID("stashItem4"))),
	modifySubWidget(5, 11, skinAgentItem(ctrlID("stashItem5"))),
	modifySubWidget(5, 12, skinAgentItem(ctrlID("stashItem6"))),
	modifySubWidget(5, 13, skinAgentItem(ctrlID("stashItem7"))),
	modifySubWidget(5, 14, skinAgentItem(ctrlID("stashItem8"))),
	modifySubWidget(5, 10, ctrlID("cycleStashNextBtn")),
	modifyWidget(9, ctrlID("closeBtn")),

	sutil.setSingleLayout("modal-monst3r.lua",
		{
			{
				id = "top", coord = 1,
				shape = [[hlist]],
				children = sutil.widgetList("taswellInfoBtn", "monst3rSellItem"),
				defaultReverse = true,
			},
			{
				-- TODO: pseudo-listbox.
				id = "stash", coord = 2,
				shape = [[hlist]],
				children = sutil.widgetList(
						"cycleStashLeftBtn", "stashItem1", "stashItem2","stashItem3", "stashItem4",
						"stashItem5", "stashItem6", "stashItem7", "stashItem8",  "cycleStashRightBtn"),
				recallOrthogonal = true,
			},
			sutil.widget("closeBtn", 3),
		}
	),
}

return modifications
