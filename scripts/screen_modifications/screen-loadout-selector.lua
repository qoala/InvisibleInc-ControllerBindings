-- (Sim Constructor) Modal for selecting agent loadouts on team-preview-screen.

local sutil = include(SCRIPT_PATHS.qedctrl.."/screen_util")
local ctrlID = sutil.ctrlID
local skinButton = sutil.skinButton

local function modifyWidget(childIndex, modification)
	return {
		"screen-loadout-selector.lua",
		{ "widgets", 2, "children", childIndex },
		modification,
	}
end

local function modifySkin(skinIndex, modification)
	return {
		"screen-loadout-selector.lua",
		{ "skins", skinIndex },
		modification,
	}
end

local modifications = {
	-- agent, for loadoutList.
	modifySkin(3, sutil.ctrl({ bindListItemTo = "btn" })),

	modifyWidget(3, ctrlID("loadoutList")),
	modifyWidget(2, ctrlID("closeBtn")),

	sutil.setSingleLayout("screen-loadout-selector.lua",
		{
			sutil.widget("loadoutList", 1, { widgetType = "listbox" }),
			sutil.widget("closeBtn", 2),
		}
	),
}

return modifications

