local util = include(SCRIPT_PATHS.qedctrl.."/screen_util")
local widgetList = util.layoutDef.widgetList

local function assignID(widgetIndex, id)
	return {
		"main-menu.lua",
		{ "widgets", widgetIndex },
		{ ctrlProperties = { id = id } },
	}
end

local modifications = {
	assignID(9,  "playBtn"),
	assignID(13, "optionsBtn"),
	assignID(12, "creditsBtn"),
	assignID(11, "exitBtn"),
	assignID(10, "signUpBtn"),

	util.setSingleLayout("main-menu.lua",
		widgetList("playBtn", "optionsBtn", "creditsBtn", "exitBtn", "signUpBtn")
	),
}

return modifications
