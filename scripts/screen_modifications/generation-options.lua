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
local function modifyNamedWidget(childName, modification)
	return {
		"generation-options.lua",
		{ "widgets", 7 },
		{
			inheritDef =
			{
				[childName] = modification,
			},
		},
	}
end

local function modifySkin(skinIndex, modification)
	return {
		"generation-options.lua",
		{ "skins", skinIndex },
		modification,
	}
end
local function modifySkinWidget(skinIndex, childIndex, modification)
	return {
		"generation-options.lua",
		{ "skins", skinIndex, "children", childIndex },
		modification,
	}
end

local modifications = {
	-- ComboOption, for genOptsList
	modifySkin(2, sutil.ctrl({ bindListItemTo = "widget" })),
	modifySkinWidget(2, 2, sutil.ctrl({
		focusImages = sutil.SELECT_BORDER_16,
		focusHoverImage = "arrow_down_active.png",
		focusHoverColor = { 1, 1, 1, 1 },
	})),
	-- CheckOption, for genOptsList
	modifySkin(3, sutil.ctrl({ bindListItemTo = "widget" })),
	-- SectionHeader, for genOptsList
	modifySkin(4, sutil.ctrl({ bindListItemTo = "hideBtn" },
		{
			inheritDef =
			{
				["hideBtn"] = sutil.ctrl({
					focusImages = sutil.SELECT_BORDER_16,
					focusHoverImage = "arrow_down_active.png",
					focusHoverColor = { 1, 1, 1, 1 },
				}),
			},
		}
	)),

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
	modifyNamedWidget("presetBtn", skinButton(ctrlID("modPresetBtn"))), -- Mod Preset Saver
	modifyWidget(13, skinButton(ctrlID("cancelBtn"))),

	-- Center
	modifySubWidget(17, 1, ctrlID("numRewinds",
		{
			focusImages = sutil.SELECT_BORDER_16,
			focusHoverImage = "arrow_down_active.png",
			focusHoverColor = { 1, 1, 1, 1 },
		}
	)),
	modifyWidget(10, ctrlID("levelRetriesBtn")),
	modifyWidget(20, ctrlID("showOptionsBtn")),
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
					"dlcBtn", "modPresetBtn", "cancelBtn"
				),
				recallOrthogonal = true, -- TODO: set default programmaticaly to current difficulty.
			},
			{
				id = "center", coord = 2,
				children = {
					{
						id = "top", coord = 1,
						shape = [[cgrid]], w = 2, h = 3,
						children =
						{
							sutil.widget("numRewinds",      {1,1}),
							sutil.widget("levelRetriesBtn", {1,2}),
							sutil.widget("showOptionsBtn",  {1,3}),
							sutil.widget("startBtn",        {2,3}),
						},
						recallOrthogonalX = true,
						recallOrthogonalY = true,
						default = "startBtn",
					},
					sutil.widget("genOptsList", 2,
						{
							widgetType = [[listbox]],
							recallAlways = true,
							-- Sim Constructor has an onItemClicked that's a no-op on PC.
							ignoreOnItemClicked = true,
							rightTo = { "root", "center", "top", "startBtn" },
						}
					),
				},
				recallOrthogonal = true,
			},
		},
		{
			shape = [[hlist]],
			default = "center",
			cancelTo = { "root", "leftbar", "cancelBtn" },
		},
		{ combobox = true, }
	),
}

return modifications
