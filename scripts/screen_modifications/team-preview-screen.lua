local sutil = include(SCRIPT_PATHS.qedctrl .. "/screen_util")
local ctrlID = sutil.ctrlID
local skinButton = sutil.skinButton

local function skinAgentLoadoutBtn(id)
    return {inheritDef = {["loadoutBtn1"] = skinButton(ctrlID(id))}}
end

-- TODO: Focusable widget for the whole box.
--   Confirming on that ctrl-only widget would move into the box's root layout.
-- TODO: pseudo-spinners for prev/next: agents, lore pages, and loadouts.
-- TODO: Add vanilla loadout buttons to layout.
local function skinAgent(baseID)
    return {
        inheritDef = {
            -- Cycle agents
            ["arrowLeft"] = skinButton(ctrlID(baseID .. ".selectPrev")),
            ["arrowRight"] = skinButton(ctrlID(baseID .. ".selectNext")),
            -- Cycle lore
            ["prevBtn"] = ctrlID(baseID .. ".lorePrev"),
            ["nextBtn"] = ctrlID(baseID .. ".loreNext"),
            -- Sim Constructor loadout selection
            ["loadoutArrowLeft"] = skinButton(ctrlID(baseID .. ".loadoutSimConPrev")),
            ["loadoutSharedBtn"] = skinAgentLoadoutBtn(baseID .. ".loadoutSimConOpen"),
            ["loadoutArrowRight"] = skinButton(ctrlID(baseID .. ".loadoutSimConNext")),
            -- Vanilla loadout selection
            ["loadoutBtn1"] = skinAgentLoadoutBtn(baseID .. ".loadout1Btn"),
            ["loadoutBtn2"] = skinAgentLoadoutBtn(baseID .. ".loadout2Btn"),
        },
    }
end

local function skinProgram(baseID)
    return {
        inheritDef = {
            -- Cycle programs
            ["arrowLeft"] = skinButton(ctrlID(baseID .. ".selectPrev")),
            ["arrowRight"] = skinButton(ctrlID(baseID .. ".selectNext")),
        },
    }
end

-- ===

local function modifyWidget(childIndex, modification)
    return {"team_preview_screen.lua", {"widgets", 2, "children", childIndex}, modification}
end

local function modifySkinCtrl(skinIndex, properties)
    return {"team_preview_screen.lua", {"skins", skinIndex}, {ctrlProperties = properties}}
end
local function modifySkinWidget(skinIndex, childIndex, modification)
    return {"team_preview_screen.lua", {"skins", skinIndex, "children", childIndex}, modification}
end

-- ===

local modifications = {
    -- agentSelect, for agentList.
    modifySkinCtrl(6, {bindListItemTo = "img"}),
    modifySkinWidget(
            6, 2, sutil.ctrl({focusImages = "qedctrl/select-team-agent.png", focusImagePadding = 0})),

    -- Top row
    modifyWidget(14, ctrlID("agentList")),
    -- Middle row
    modifyWidget(3, skinAgent("agent1")),
    modifyWidget(4, skinAgent("agent2")),
    modifyWidget(8, skinProgram("program1")),
    modifyWidget(9, skinProgram("program2")),
    -- Bottom row
    modifyWidget(11, ctrlID("randomizeBtn")),
    modifyWidget(15, ctrlID("muteBtn")),
    modifyWidget(5, ctrlID("cancelBtn")),
    modifyWidget(6, ctrlID("acceptBtn")),

    sutil.setLayouts(
            "team_preview_screen.lua", {
                {
                    id = "main",
                    shape = [[rgrid]],
                    w = 3,
                    h = 3,
                    children = {
                        -- Top row (right-justified)  y = 1
                        sutil.widget("agentList", {3, 1}, {widgetType = [[listbox]], wrap = true}),

                        -- Middle row  y = 2
                        {
                            id = "agent1",
                            coord = {1, 2},
                            shape = [[rgrid]],
                            w = 9,
                            h = 5,
                            children = {
                                sutil.widget("agent1.selectPrev", {1, 1}),
                                sutil.widget("agent1.selectNext", {9, 1}),
                                sutil.widget("agent1.lorePrev", {1, 2}),
                                sutil.widget("agent1.loreNext", {9, 2}),
                                sutil.widget("agent1.loadoutSimConPrev", {1, 3}),
                                sutil.widget("agent1.loadout1Btn", {2, 3}),
                                sutil.widget("agent1.loadoutSimConOpen", {5, 3}),
                                sutil.widget("agent1.loadout2Btn", {8, 3}),
                                sutil.widget("agent1.loadoutSimConNext", {9, 3}),
                            },
                        },
                        {
                            id = "agent2",
                            coord = {2, 2},
                            shape = [[rgrid]],
                            w = 9,
                            h = 5,
                            children = {
                                sutil.widget("agent2.selectPrev", {1, 1}),
                                sutil.widget("agent2.selectNext", {9, 1}),
                                sutil.widget("agent2.lorePrev", {1, 2}),
                                sutil.widget("agent2.loreNext", {9, 2}),
                                sutil.widget("agent2.loadoutSimConPrev", {1, 3}),
                                sutil.widget("agent2.loadout1Btn", {2, 3}),
                                sutil.widget("agent2.loadoutSimConOpen", {5, 3}),
                                sutil.widget("agent2.loadout2Btn", {8, 3}),
                                sutil.widget("agent2.loadoutSimConNext", {9, 3}),
                            },
                        },
                        {
                            id = "programs",
                            coord = {3, 2},
                            shape = [[rgrid]],
                            w = 2,
                            h = 2,
                            children = {
                                sutil.widget("program1.selectPrev", {1, 1}),
                                sutil.widget("program1.selectNext", {2, 1}),
                                sutil.widget("program2.selectPrev", {1, 2}),
                                sutil.widget("program2.selectNext", {2, 2}),
                            },
                        },

                        -- Bottom row  y = 3
                        {
                            id = "bottomLeft",
                            coord = {1, 3},
                            shape = [[hlist]],
                            children = sutil.widgetList("randomizeBtn", "muteBtn"),
                        },
                        sutil.widget("cancelBtn", {2, 3}),
                        sutil.widget("acceptBtn", {3, 3}),
                    },
                    default = "agent1",
                    defaultXReverse = true,
                    cancelTo = "cancelBtn",
                },
                {id = "agent1.box", children = {}},
                {id = "agent2.box", children = {}},
                {id = "program1.box", children = {}},
                {id = "program2.box", children = {}},
            }),
}

return modifications
