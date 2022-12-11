-- Modal dialogs with a simple layout of buttons.

local util = include(SCRIPT_PATHS.qedctrl.."/screen_util")
local ctrlID = util.modificationDef.ctrlID
local skinButton = util.modificationDef.skinButton
local widget = util.layoutDef.widget
local widgetList = util.layoutDef.widgetList

local function soloButton()
	return ctrlID("btn", { soloButton = true, autoConfirm = true })
end

-- Most dialogs have widgets[2] as the main dialog panel, with all buttons among its children.
local function modifyDialog(filename, childIndex, modification)
	return { filename, { "widgets", 2, "children", childIndex }, modification }
end

-- Many dialogs have a single screen_button (named okBtn, at child index 3).
local function oneButtonDialog(filename)
	return modifyDialog(filename, 3, skinButton(soloButton()))
end

local modifications = {
	oneButtonDialog("modal-alarm.lua"),
	oneButtonDialog("modal-agents-added.lua"),
	oneButtonDialog("modal-blindspots.lua"),
	oneButtonDialog("modal-cooldown.lua"),
	oneButtonDialog("modal-corner_peek.lua"),
	oneButtonDialog("modal-daemon.lua"),
	oneButtonDialog("modal-daemon-intro.lua"),
	oneButtonDialog("modal-incognita.lua"),
	oneButtonDialog("modal-lockpick.lua"),
	oneButtonDialog("modal-love.lua"),
	oneButtonDialog("modal-manipulate.lua"),
	oneButtonDialog("modal-mission-objectives.lua"),
	oneButtonDialog("modal-peek_open_peek.lua"),
	oneButtonDialog("modal-pinning.lua"),
	oneButtonDialog("modal-program.lua"),
	oneButtonDialog("modal-rewind-tutorial.lua"),
	oneButtonDialog("modal-spotted.lua"),
	oneButtonDialog("modal-tactical-view.lua"),
	oneButtonDialog("modal-turns.lua"),
	modifyDialog("modal-alarm-first.lua", 4, skinButton(soloButton())),
	modifyDialog("modal-unlock.lua", 5, skinButton(soloButton())),
	modifyDialog("modal-unlock-agents.lua", 5, skinButton(soloButton())),
	{ "modal-posttutorial.lua", { "widgets", 2, "children", 3, "children", 3 }, soloButton() },

	modifyDialog("modal-dialog.lua", 5, ctrlID("okBtn")),
	modifyDialog("modal-dialog.lua", 6, ctrlID("cancelBtn")),
	modifyDialog("modal-dialog.lua", 8, ctrlID("auxBtn")),
	util.setSingleLayout("modal-dialog.lua", widgetList("okBtn", "cancelBtn", "auxBtn")),
	modifyDialog("modal-dialog-large.lua", 3, ctrlID("okBtn")),
	modifyDialog("modal-dialog-large.lua", 4, ctrlID("cancelBtn")),
	modifyDialog("modal-dialog-large.lua", 6, ctrlID("auxBtn")),
	util.setSingleLayout("modal-dialog-large.lua", widgetList("okBtn", "cancelBtn", "auxBtn")),

	modifyDialog("modal-execterminals.lua", 5, skinButton(ctrlID("location1"))),
	modifyDialog("modal-execterminals.lua", 6, skinButton(ctrlID("location2"))),
	modifyDialog("modal-execterminals.lua", 7, skinButton(ctrlID("location3"))),
	modifyDialog("modal-execterminals.lua", 8, skinButton(ctrlID("location4"))),
	util.setSingleLayout("modal-execterminals.lua",
		-- TODO: Grid layout.
		{
			widget("location1", 1),
			widget("location2", 2),
			widget("location3", 3),
			widget("location4", 4),
		}
	),

	-- TODO: Drill button grid widgets[2].children[20].children[...]
	modifyDialog("modal-grafter.lua", 16, ctrlID("installSocketBtn")),
	modifyDialog("modal-grafter.lua", 15, ctrlID("installAugmentBtn")),
	modifyDialog("modal-grafter.lua", 17, ctrlID("cancelBtn")),
	util.setSingleLayout("modal-grafter.lua",
		{
			-- Drill grid, coord = 1
			{
				id = "actions", coord = 2,
				shape = [[HLIST]],
				children = widgetList("installSocketBtn", "installAugmentBtn"),
				default = "installAugmentBtn",
			},
			widget("cancelBtn", 3),
		},
		{ defaultChain = { "actions", "cancelBtn" } }
	),

	modifyDialog("modal-install-augment.lua", 6, ctrlID("installAugmentBtn")),
	modifyDialog("modal-install-augment.lua", 5, ctrlID("leaveInInventoryBtn")),
	util.setSingleLayout("modal-install-augment.lua", widgetList("installAugmentBtn", "leaveInInventoryBtn")),

	modifyDialog("modal-rewind.lua", 7, skinButton(ctrlID("cancelBtn"))),
	modifyDialog("modal-rewind.lua", 3, skinButton(ctrlID("okBtn"))),
	util.setSingleLayout("modal-rewind.lua",
		widgetList("cancelBtn", "okBtn"),
		{ shape = [[HLIST]], default = "okBtn" }
	),

	-- TODO: listbox @9 above okBtn. Needs: sub-item selection, scroll handling, custom hover effects.
	modifyDialog("modal-select-dlc.lua", 6, ctrlID("okBtn")),
	modifyDialog("modal-select-dlc.lua", 7, ctrlID("cancelBtn")),
	util.setSingleLayout("modal-select-dlc.lua", widgetList("okBtn", "cancelBtn")),

	-- Ignoring the input elements and okBtn.
	modifyDialog("modal-signup.lua", 17, skinButton(ctrlID("cancelBtn"))),
	util.setSingleLayout("modal-signup.lua", widgetList("cancelBtn")),

	modifyDialog("modal-story.lua", 7, ctrlID("skipBtn")),
	modifyDialog("modal-story.lua", 8, ctrlID("prevBtn")),
	modifyDialog("modal-story.lua", 9, ctrlID("nextBtn")),
	util.setSingleLayout("modal-story.lua",
		{
			widget("skipBtn", 1),
			{
				id = "nav", coord = 2,
				shape = [[HLIST]],
				children = widgetList("prevBtn", "nextBtn"),
				default = "nextBtn",
			},
		},
		{ default = "nav" }
	),

	modifyDialog("modal-update-disclaimer.lua", 5, skinButton(ctrlID("okBtn"))),
	modifyDialog("modal-update-disclaimer.lua", 4, skinButton(ctrlID("readMoreBtn"))),
	util.setSingleLayout("modal-update-disclaimer.lua", widgetList("okBtn", "readMoreBtn")),

	modifyDialog("modal-update-disclaimer_b.lua", 6, skinButton(ctrlID("resetBtn"))),
	modifyDialog("modal-update-disclaimer_b.lua", 5, skinButton(ctrlID("okBtn"))),
	modifyDialog("modal-update-disclaimer_b.lua", 4, skinButton(ctrlID("readMoreBtn"))),
	util.setSingleLayout("modal-update-disclamer_b.lua",
		{
			widget("resetBtn", 1),
			{
				id = "actions", coord = 2,
				children = widgetList("okBtn", "readMoreBtn"),
			},
		},
		{ shape = [[HLIST]], default = "actions" }
	),
}

return modifications
