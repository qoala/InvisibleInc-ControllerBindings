local sutil = include(SCRIPT_PATHS.qedctrl .. "/screen_util")
local ctrlID = sutil.ctrlID
local skinButton = sutil.skinButton

local function modifyWidget(childIndex, modification)
    return {"mission_recap_screen.lua", {"widgets", 2, "children", childIndex}, modification}
end

local modifications = {
    modifyWidget(4, skinButton(ctrlID("okBtn"))),
    modifyWidget(11, skinButton(ctrlID("logBtn"))),

    sutil.setSingleLayout(
            "mission_recap_screen.lua", sutil.widgetList("logBtn", "okBtn"),
            {shape = [[hlist]], default = "okBtn"}),
}

return modifications

