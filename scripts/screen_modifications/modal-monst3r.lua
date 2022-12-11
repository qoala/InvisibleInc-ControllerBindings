local util = include(SCRIPT_PATHS.qedctrl.."/screen_util")
local widgetList = util.layoutDef.widgetList

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

	util.setSingleLayout("modal-monst3r.lua", widgetList("closeBtn")),
}

return modifications
