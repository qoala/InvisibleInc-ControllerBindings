local sutil = include(SCRIPT_PATHS.qedctrl.."/screen_util")

local function assignID(childIndex, id)
	return {
		"modal-monst3r.lua",
		{ "widgets", 2, "children", childIndex },
		{ ctrlProperties = { id = id } },
	}
end

local modifications = {
	assignID(9, "closeBtn"),
	-- TODO: inventory & shop item.

	sutil.setSingleLayout("modal-monst3r.lua", sutil.widgetList("closeBtn")),
}

return modifications
