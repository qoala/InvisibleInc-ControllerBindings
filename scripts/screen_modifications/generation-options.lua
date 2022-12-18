local sutil = include(SCRIPT_PATHS.qedctrl.."/screen_util")
local ctrlID = sutil.ctrlID
local skinButton = sutil.skinButton

local function modifyWidget(childIndex, modification)
	return {
		"generation-options.lua",
		{ "widgets", 7, "children", childIndex },
		modification,
	}
end
local function modifySubWidget(cid1, cid2, modification)
	return {
		"generation-options.lua",
		{ "widgets", 7, "children", cid1, "children", cid2 },
		modification,
	}
end
local function modifySubSubWidget(cid1, cid2, cid3, modification)
	return {
		"generation-options.lua",
		{ "widgets", 7, "children", cid1, "children", cid2, "children", cid3 },
		modification,
	}
end

local function modifySkinCtrl(skinIndex, properties)
	return {
		"generation-options.lua",
		{ "skins", skinIndex },
		{ ctrlProperties = properties },
	}
end

local modifications = {
	modifySkinCtrl(2, { bindListItemTo = "widget" }), -- ComboOption, for genOptsList
	modifySkinCtrl(3, { bindListItemTo = "widget" }), -- CheckOption, for genOptsList
	modifySkinCtrl(4, { bindListItemTo = "hideBtn" }), -- SectionHeader, for genOptsList

	-- Left Bar
	modifyWidget(2, skinButton(ctrlID("difficulty1"))),
	modifyWidget(3, skinButton(ctrlID("difficulty2"))),
	modifyWidget(6, skinButton(ctrlID("difficulty3"))),
	modifyWidget(4, skinButton(ctrlID("difficulty4"))),
	modifyWidget(5, skinButton(ctrlID("difficulty5"))),
	modifyWidget(7, skinButton(ctrlID("difficulty6"))),
	modifyWidget(18, skinButton(ctrlID("difficulty7"))),
	modifyWidget(19, skinButton(ctrlID("difficulty8"))),
	modifyWidget(21, skinButton(ctrlID("dlcBtn"))),
	-- TODO: Custom Presets (preset saver mod)
	modifyWidget(13, skinButton(ctrlID("cancelBtn"))),

	-- Center
	modifySubWidget(17, 1, ctrlID("numRewinds")), -- TODO: combobox
	modifyWidget(10, ctrlID("levelRetriesBtn")), -- TODO: checkbox
	modifyWidget(20, ctrlID("showOptionsBtn")), -- TODO: checkbox
	modifySubSubWidget(12, 2, 1, ctrlID("genOptsList")),

	-- Start button, visibly to the right of the Center-Top options, but above the listbox.
	-- Treat it as to the right of all of those.
	modifyWidget(11, ctrlID("startBtn")),

	sutil.setSingleLayout("generation-options.lua",
		{
			{
				id = "leftbar", coord = 1,
				children = sutil.widgetList(
					-- Standard
					"difficulty1", "difficulty2", "difficulty3",
					-- Advanced
					"difficulty4", "difficulty5", "difficulty6", "difficulty7", "difficulty8",
					-- DLC + Mods
					"dlcBtn", "cancelBtn"
				),
				alwaysRecall = true, -- TODO: set default programmaticaly to current difficulty.
			},
			{
				id = "center", coord = 2,
				children = {
					sutil.widget("numRewinds", 1),
					sutil.widget("levelRetriesBtn", 2),
					sutil.widget("showOptionsBtn", 3),
					sutil.widget("genOptsList", 4,
						{
							widgetType = [[listbox]],
							alwaysRecall = true,
							-- Sim Constructor has an onItemClicked that's a no-op on PC.
							ignoreOnItemClicked = true,
						}
					),
				},
				alwaysRecall = true,
			},
			sutil.widget("startBtn", 3),
		},
		{ shape = [[hlist]], default = "startBtn", }
	),
}

return modifications
