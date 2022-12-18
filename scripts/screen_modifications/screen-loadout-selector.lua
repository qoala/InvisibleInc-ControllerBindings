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

local modifications = {
	modifyWidget(3, ctrlID("loadoutList")), -- TODO: non-hitbox listbox
	modifyWidget(2, ctrlID("closeBtn")),

	sutil.setSingleLayout("screen-loadout-selector.lua",
		{
			sutil.widget("loadoutList", 1, { widgetType = "listbox" }),
			sutil.widget("closeBtn", 2),
		}
	),
}

return modifications

