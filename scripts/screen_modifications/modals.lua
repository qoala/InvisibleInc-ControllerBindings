-- Modal dialogs with a simple layout of buttons.

local sutil = include(SCRIPT_PATHS.qedctrl.."/screen_util")
local ctrlID = sutil.ctrlID
local skinButton = sutil.skinButton

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

-- The rest are only 1 level deeper.
local function modifySubWidget(filename, childIndex, subChildIndex, modification)
	return {
		filename,
		{ "widgets", 2, "children", childIndex, "children", subChildIndex },
		modification,
	}
end


local modifications =
{
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
	modifySubWidget("modal-posttutorial.lua", 3, 3, soloButton()),

	modifyDialog("modal-dialog.lua", 5, ctrlID("okBtn")),
	modifyDialog("modal-dialog.lua", 6, ctrlID("cancelBtn")),
	modifyDialog("modal-dialog.lua", 8, ctrlID("auxBtn")),
	sutil.setSingleLayout("modal-dialog.lua", sutil.widgetList("okBtn", "cancelBtn", "auxBtn")),
	modifyDialog("modal-dialog-large.lua", 3, ctrlID("okBtn")),
	modifyDialog("modal-dialog-large.lua", 4, ctrlID("cancelBtn")),
	modifyDialog("modal-dialog-large.lua", 6, ctrlID("auxBtn")),
	sutil.setSingleLayout("modal-dialog-large.lua", sutil.widgetList("okBtn", "cancelBtn", "auxBtn")),

	modifyDialog("modal-execterminals.lua", 5, skinButton(ctrlID("location1"))),
	modifyDialog("modal-execterminals.lua", 6, skinButton(ctrlID("location2"))),
	modifyDialog("modal-execterminals.lua", 7, skinButton(ctrlID("location3"))),
	modifyDialog("modal-execterminals.lua", 8, skinButton(ctrlID("location4"))),
	sutil.setSingleLayout("modal-execterminals.lua",
		{
			sutil.widget("location1", {1,1}), sutil.widget("location2", {2,1}),
			sutil.widget("location3", {1,2}), sutil.widget("location4", {2,2}),
		},
		{ shape = [[RGRID]], w = 2, h = 2 }
	),

	-- Normal interactions in the lower half of the modal.
	modifyDialog("modal-grafter.lua", 16, ctrlID("installSocketBtn")),
	modifyDialog("modal-grafter.lua", 15, ctrlID("installAugmentBtn")),
	modifyDialog("modal-grafter.lua", 17, ctrlID("cancelBtn")),
	-- Per-augment drill targets. Layout:
	-- 1 2 3 4
	-- 5 6
	modifySubWidget("modal-grafter.lua", 20, 2, skinButton(ctrlID("drillAug1"))),
	modifySubWidget("modal-grafter.lua", 20, 3, skinButton(ctrlID("drillAug2"))),
	modifySubWidget("modal-grafter.lua", 20, 6, skinButton(ctrlID("drillAug3"))),
	modifySubWidget("modal-grafter.lua", 20, 4, skinButton(ctrlID("drillAug4"))),
	modifySubWidget("modal-grafter.lua", 20, 5, skinButton(ctrlID("drillAug5"))),
	modifySubWidget("modal-grafter.lua", 20, 1, skinButton(ctrlID("drillAug6"))),
	-- TODO: Add visual indicator of focus. Not sure why the following doesn't work.
	-- {
	-- 	"modal-grafter.lua", -- skins > 3:Group 2 > 2:btn > 2:hover
	-- 	{ "skins", 3, "children", 2, "images", 2 },
	-- 	{
	-- 		color =
	-- 		{
	-- 			1,
	-- 			1,
	-- 			1,
	-- 			0.800000011920929,
	-- 		},
	-- 	},
	-- },
	sutil.setSingleLayout("modal-grafter.lua",
		{
			{
				id = "drill", coord = 1,
				shape = [[RGRID]], w = 4, h = 2,
				children =
				{
					sutil.widget("drillAug1", {1,1}), sutil.widget("drillAug2", {2,1}), -- Row 1
					sutil.widget("drillAug3", {3,1}), sutil.widget("drillAug4", {4,1}), -- Row 1, cont.
					sutil.widget("drillAug5", {1,2}), sutil.widget("drillAug6", {2,2}), -- Row 2
				},
			},
			{
				id = "actions", coord = 2,
				shape = [[HLIST]],
				children = sutil.widgetList("installSocketBtn", "installAugmentBtn"),
				default = "installAugmentBtn",
			},
			sutil.widget("cancelBtn", 3),
		},
		{ defaultChain = { "actions", "cancelBtn" } }
	),

	modifyDialog("modal-install-augment.lua", 6, ctrlID("installAugmentBtn")),
	modifyDialog("modal-install-augment.lua", 5, ctrlID("leaveInInventoryBtn")),
	sutil.setSingleLayout("modal-install-augment.lua",
		sutil.widgetList("installAugmentBtn", "leaveInInventoryBtn")),

	modifyDialog("modal-rewind.lua", 7, skinButton(ctrlID("cancelBtn"))),
	modifyDialog("modal-rewind.lua", 3, skinButton(ctrlID("okBtn"))),
	sutil.setSingleLayout("modal-rewind.lua",
		sutil.widgetList("cancelBtn", "okBtn"),
		{ shape = [[HLIST]], default = "okBtn" }
	),

	-- TODO: listbox @9 above okBtn. Needs: sub-item selection, scroll handling, custom hover effects.
	modifyDialog("modal-select-dlc.lua", 6, ctrlID("okBtn")),
	modifyDialog("modal-select-dlc.lua", 7, ctrlID("cancelBtn")),
	sutil.setSingleLayout("modal-select-dlc.lua", sutil.widgetList("okBtn", "cancelBtn")),

	-- Ignoring the input elements and okBtn.
	modifyDialog("modal-signup.lua", 17, skinButton(ctrlID("cancelBtn"))),
	sutil.setSingleLayout("modal-signup.lua", sutil.widgetList("cancelBtn")),

	modifyDialog("modal-story.lua", 7, ctrlID("skipBtn")),
	modifyDialog("modal-story.lua", 8, ctrlID("prevBtn")),
	modifyDialog("modal-story.lua", 9, ctrlID("nextBtn")),
	sutil.setSingleLayout("modal-story.lua",
		{
			sutil.widget("skipBtn", 1),
			{
				id = "nav", coord = 2,
				shape = [[HLIST]],
				children = sutil.widgetList("prevBtn", "nextBtn"),
				default = "nextBtn",
			},
		},
		{ default = "nav" }
	),

	modifyDialog("modal-update-disclaimer.lua", 5, skinButton(ctrlID("okBtn"))),
	modifyDialog("modal-update-disclaimer.lua", 4, skinButton(ctrlID("readMoreBtn"))),
	sutil.setSingleLayout("modal-update-disclaimer.lua", sutil.widgetList("okBtn", "readMoreBtn")),

	modifyDialog("modal-update-disclaimer_b.lua", 6, skinButton(ctrlID("resetBtn"))),
	modifyDialog("modal-update-disclaimer_b.lua", 5, skinButton(ctrlID("okBtn"))),
	modifyDialog("modal-update-disclaimer_b.lua", 4, skinButton(ctrlID("readMoreBtn"))),
	sutil.setSingleLayout("modal-update-disclamer_b.lua",
		{
			sutil.widget("resetBtn", 1),
			{
				id = "actions", coord = 2,
				children = sutil.widgetList("okBtn", "readMoreBtn"),
			},
		},
		{ shape = [[HLIST]], default = "actions" }
	),
}

return modifications
