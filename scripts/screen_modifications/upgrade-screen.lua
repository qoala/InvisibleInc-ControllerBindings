local sutil = include(SCRIPT_PATHS.qedctrl .. "/screen_util")
local ctrlID = sutil.ctrlID
local named = sutil.named
local skinButton = sutil.skinButton

local function skinSkill(baseID)
    return {
        inheritDef = { -- TODO: pseudo-spinner
            ["btnBack"] = ctrlID(baseID .. ".lowerBtn"),
            ["btnFwd"] = ctrlID(baseID .. ".raiseBtn"),
        },
    }
end

local function modifyNamedWidget(childName, modification)
    return {"upgrade_screen.lua", {"widgets", 4, "children"}, named(childName, modification)}
end
local function modifyWidget(childIndex, modification)
    return {"upgrade_screen.lua", {"widgets", 4, "children", childIndex}, modification}
end
local function modifySubWidget(cid1, cid2, modification)
    return {"upgrade_screen.lua", {"widgets", 4, "children", cid1, "children", cid2}, modification}
end
local function modifySubSubWidget(cid1, cid2, cid3, modification)
    return {
        "upgrade_screen.lua",
        {"widgets", 4, "children", cid1, "children", cid2, "children", cid3},
        modification,
    }
end
local function modifySkinWidget(skinIndex, childIndex, modification)
    return {"upgrade_screen.lua", {"skins", skinIndex, "children", childIndex}, modification}
end

-- ===

local modifications = {
    -- TODO: non-interactive focusable with hover.
    -- modifySkinCtrl(6, { bindListItemTo = "???" }),

    -- agentbutton > btn
    modifySkinWidget(5, 1, sutil.ctrl({focusImages = sutil.SELECT_BORDER_64})),
    -- inventory > btn
    modifySkinWidget(6, 3, sutil.ctrl({focusImages = sutil.SELECT_BORDER_64})),

    -- 4 : panel
    -- 4 > 2 : agentPnl
    -- 4 > 2 > 6 : skillGroup
    -- Agent skills.
    modifySubSubWidget(2, 6, 1, skinSkill("skill1")),
    modifySubSubWidget(2, 6, 2, skinSkill("skill2")),
    modifySubSubWidget(2, 6, 3, skinSkill("skill3")),
    modifySubSubWidget(2, 6, 4, skinSkill("skill4")),
    modifySubWidget(2, 6, named("skill5", skinSkill("skill5"))), -- Marksmanship mod.

    -- 4 > 2 : agentPnl
    -- Agent items/augments.
    modifySubWidget(2, 9, skinButton(ctrlID("inv1"))),
    modifySubWidget(2, 10, skinButton(ctrlID("inv2"))),
    modifySubWidget(2, 11, skinButton(ctrlID("inv3"))),
    modifySubWidget(2, 12, skinButton(ctrlID("inv4"))),
    modifySubWidget(2, 13, skinButton(ctrlID("inv5", {canFocusDisabled = true}))),
    modifySubWidget(2, 14, skinButton(ctrlID("inv6"))),
    modifySubWidget(2, 15, skinButton(ctrlID("inv7"))),
    modifySubWidget(2, 16, skinButton(ctrlID("inv8"))),
    modifySubWidget(2, 19, skinButton(ctrlID("aug1", {canFocusDisabled = true}))),
    modifySubWidget(2, 20, skinButton(ctrlID("aug2", {canFocusDisabled = true}))),
    modifySubWidget(2, 21, skinButton(ctrlID("aug3", {canFocusDisabled = true}))),
    modifySubWidget(2, 22, skinButton(ctrlID("aug4", {canFocusDisabled = true}))),
    modifySubWidget(2, 23, skinButton(ctrlID("aug5", {canFocusDisabled = true}))),
    modifySubWidget(2, 24, skinButton(ctrlID("aug6", {canFocusDisabled = true}))),
    modifySubWidget(2, 25, skinButton(ctrlID("aug7", {canFocusDisabled = true}))),
    modifySubWidget(2, 26, skinButton(ctrlID("aug8", {canFocusDisabled = true}))),

    -- 4 : panel
    -- Agent/Incognita tab selector. 
    -- TODO: Better highlights for these 5.
    -- TODO: LB/RB hotkeys to change tabs.
    modifyWidget(8, skinButton(ctrlID("agent1"))),
    modifyWidget(9, skinButton(ctrlID("agent2"))),
    modifyWidget(10, skinButton(ctrlID("agent3"))),
    modifyWidget(11, skinButton(ctrlID("agent4"))),
    modifyWidget(12, skinButton(ctrlID("incognita"))),
    -- Agent Reserve mod -- TODO: pseudo-listbox
    modifyNamedWidget("reserveLeftBtn", ctrlID("agentCyclePrev")),
    modifyNamedWidget("reserveRightBtn", ctrlID("agentCycleNext")),
    modifyNamedWidget("assignBtn", skinButton(ctrlID("agentAssign"))),

    -- Stash inventory. ("agency_inv") -- TODO: pseudo-listbox.
    modifyWidget(13, skinButton(ctrlID("stash1"))),
    modifyWidget(14, skinButton(ctrlID("stash2"))),
    modifyWidget(15, skinButton(ctrlID("stash3"))),
    modifyWidget(16, skinButton(ctrlID("stash4"))),
    modifyWidget(17, ctrlID("stashCyclePrev")), -- cycleLeftBtn
    modifyWidget(18, ctrlID("stashCycleNext")), -- cycleRightBtn
    modifySubWidget(19, 1, ctrlID("monst3rBtn")),

    -- 4 > 21 : programPnl
    -- Incognita programs.
    modifySubWidget(21, 9, ctrlID("programList")),

    -- 4 : panel
    modifyWidget(26, skinButton(ctrlID("acceptBtn"))),

    sutil.setSingleLayout(
            "upgrade_screen.lua", {
                {
                    id = "tabs",
                    coord = 1,
                    shape = [[hlist]],
                    children = sutil.widgetList(
                            "agentCyclePrev", "agent1", "agent2", "agent3", "agent4",
                            "agentCycleNext", "incognita"),
                    -- TODO: Set default to current tab when selecting a tab.
                },
                {
                    id = "main",
                    coord = 2,
                    -- TODO: Below idea was incorrect. Stash remains visible on Incognita tab.
                    -- Only 1 child is visible at any time.
                    -- Group them into a single layout so that if focus is in the main area when switching tabs,
                    -- it moves to the main area of the next one.
                    children = {
                        {
                            id = "agentPanel",
                            coord = 1,
                            shape = [[rgrid]],
                            w = 9,
                            h = 7,
                            children = sutil.concat(
                                    -- y = 1-2: items
                                    -- x = 1-4: augments, 5-8: agent inventory, 9: stash/Monst3r
                                    sutil.widgetRow(
                                            1, "aug1", "aug2", "aug3", "aug4", "inv1", "inv2",
                                            "inv3", "inv4"), --
                                    {
                                        {
                                            id = "stash",
                                            coord = {9, 1},
                                            shape = [[hlist]],
                                            children = sutil.widgetList(
                                                    "stashCyclePrev", "stash1", "stash2", "stash3",
                                                    "stash4", "stashCycleNext"),
                                        },
                                    }, --
                                    sutil.widgetRow(
                                            2, "aug5", "aug6", "aug7", "aug8", "inv5", "inv6",
                                            "inv7", "inv8", "monst3rBtn"), --
                                    -- y = 3-7: skills
                                    -- x = 5: To line up with the first slot of agent inventory.
                                    {
                                        sutil.widget("skill1.lowerBtn", {4, 3}),
                                        sutil.widget("skill1.raiseBtn", {5, 3}),
                                        sutil.widget("skill2.lowerBtn", {4, 4}),
                                        sutil.widget("skill2.raiseBtn", {5, 4}),
                                        sutil.widget("skill3.lowerBtn", {4, 5}),
                                        sutil.widget("skill3.raiseBtn", {5, 5}),
                                        sutil.widget("skill4.lowerBtn", {4, 6}),
                                        sutil.widget("skill4.raiseBtn", {5, 6}),
                                        sutil.widget("skill5.lowerBtn", {4, 7}),
                                        sutil.widget("skill5.raiseBtn", {5, 7}),
                                    }),
                            defaultXReverse = true, -- All entry paths come from the right side.
                            recallOrthogonalX = true,
                        },
                        sutil.widget("programList", 2, {widgetType = [[listbox]]}),
                    },
                },
                { --
                    id = "bottom",
                    coord = 3,
                    children = sutil.widgetList("agentAssign", "acceptBtn"),
                },
            }, {default = "main", cancelTo = "acceptBtn"}),
}

return modifications
