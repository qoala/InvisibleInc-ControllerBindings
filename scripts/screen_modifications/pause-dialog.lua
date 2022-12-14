local sutil = include(SCRIPT_PATHS.qedctrl.."/screen_util")

local function assignID(childIndex, id)
	return {
		"pause_dialog_screen.lua",
		{ "widgets", 2, "children", childIndex },
		{ ctrlProperties = { id = id } },
	}
end

local modifications = {
	assignID(7,  "resumeBtn"),
	assignID(5,  "optionsBtn"),
	assignID(10, "helpBtn"),
	assignID(4,  "quitBtn"),
	assignID(9,  "abortBtn"),
	assignID(8,  "retireBtn"),

	sutil.setSingleLayout("pause_dialog_screen.lua",
		sutil.widgetList(
			"resumeBtn",
			"optionsBtn",
			"helpBtn",
			"quitBtn",
			"abortBtn",
			"retireBtn"
		),
		{ forceController = true }
	),
}

return modifications

