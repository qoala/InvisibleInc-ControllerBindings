local sutil = include(SCRIPT_PATHS.qedctrl .. "/screen_util")
local ctrlID = sutil.ctrlID

local function modifyWidget(childIndex, modification)
    return {"modal-logs.lua", {"widgets", 4, "children", childIndex}, modification}
end

local function modifySkinCtrl(skinIndex, properties)
    return {"modal-logs.lua", {"skins", skinIndex}, {ctrlProperties = properties}}
end

local modifications = {
    modifySkinCtrl(4, {bindListItemTo = "btn"}), -- logItem, for logsList.

    modifyWidget(4, ctrlID("closeBtn")),
    modifyWidget(6, ctrlID("logsList")),
    modifyWidget(8, ctrlID("nextBtn")),
    modifyWidget(9, ctrlID("prevBtn")),
    modifyWidget(12, ctrlID("deleteBtn")),

    sutil.setSingleLayout(
            "modal-logs.lua", {
                -- TODO: focus the selected entry on click.
                sutil.widget("logsList", {1, 1}, {widgetType = [[listbox]], wrap = true}),
                {
                    -- TODO: pseudo-spinner
                    id = "logSpinner",
                    coord = {2, 1},
                    shape = [[hlist]],
                    children = sutil.widgetList("prevBtn", "nextBtn"),
                },
                sutil.widget("deleteBtn", {2, 2}),
                sutil.widget(
                        "closeBtn", {3, 2}, {upTo = {"logSpinner", options = {dir = sutil.LEFT}}}),
            }, { --
                shape = [[cgrid]],
                w = 3,
                h = 2,
                cancelTo = "closeBtn",
            }),
}

return modifications
