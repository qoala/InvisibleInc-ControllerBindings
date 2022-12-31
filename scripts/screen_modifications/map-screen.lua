local sutil = include(SCRIPT_PATHS.qedctrl .. "/screen_util")
local ctrlID = sutil.ctrlID

-- local function modifySubWidget(cid1, cid2, modification)
-- 	return {
-- 		"modal-saveslots.lua",
-- 		{ "widgets", 4, "children", cid1, "children", cid2 },
-- 		modification,
-- 	}
-- end
local function modifySubSubWidget(cid1, cid2, cid3, modification)
    return {
        "map_screen.lua",
        {"widgets", 4, "children", cid1, "children", cid2, "children", cid3},
        modification,
    }
end

local modifications = {
    -- 4 : panel
    -- 4 > 1 : maproot
    -- 4 > 1 > 2 : under
    -- modifySubWidget(4, 1, 2, ???) -- Group containing all locations as children.
    -- modifySubWidget(4, 1, 4, ctrlID("jet")) -- TODO: non-interactive focusable.
    -- 4 > 3 : controls
    -- 4 > 3 > 5 : cornerMenu
    modifySubSubWidget(3, 5, 2, ctrlID("menuBtn")),
    modifySubSubWidget(3, 5, 3, ctrlID("achievementsBtn")),
    modifySubSubWidget(3, 5, 4, ctrlID("upgradeBtn")),
    modifySubSubWidget(3, 5, 5, ctrlID("datalogsBtn")),

    sutil.setSingleLayout(
            "map_screen.lua", {
                -- TODO: scatter-layout
                {
                    id = "cornerMenu",
                    coord = 2,
                    shape = [[hlist]],
                    children = sutil.widgetList(
                            "datalogsBtn", "upgradeBtn", "achievementsBtn", "menuBtn"),
                    default = "upgradeBtn",
                },
            }, {cancelTo = "menuBtn"}, -- TODO: (X) to jet.
            nil),
}

return modifications
