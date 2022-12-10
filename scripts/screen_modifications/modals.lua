-- Modal dialogs with a simple layout of buttons.

local util = include(SCRIPT_PATHS.qedctrl.."/screen_util")
local ctrlCoord = util.ctrlCoord
local ctrlGroupCoord = util.ctrlGroupCoord
local skinButton = util.skinButton
local setLayout = util.setLayout

local IDX1 = ctrlCoord{1}
local IDX2 = ctrlCoord{2}
local IDX3 = ctrlCoord{3}
local SOLO_IDX = ctrlCoord({1}, { autoConfirm = true })

-- Most dialogs have widgets[2] as the main dialog panel, with all buttons among its children.
local function modifyDialog(filename, childIndex, modification)
	return { filename, { "widgets", 2, "children", childIndex }, modification }
end

-- Many dialogs have a single screen_button (named okBtn, at child index 3).
local function oneButtonDialog(filename)
	return modifyDialog(filename, 3, skinButton(SOLO_IDX))
end

local modifications = {
	modifyDialog("modal-alarm-first.lua", 4, skinButton(SOLO_IDX)),
	modifyDialog("modal-unlock.lua", 5, skinButton(SOLO_IDX)),
	modifyDialog("modal-unlock-agents.lua", 5, skinButton(SOLO_IDX)),
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
	{ "modal-posttutorial.lua", { "widgets", 2, "children", 3, "children", 3 }, SOLO_IDX },

	modifyDialog("modal-dialog.lua", 5, IDX1), -- okBtn
	modifyDialog("modal-dialog.lua", 6, IDX2), -- cancelBtn
	modifyDialog("modal-dialog.lua", 8, IDX3), -- okBtn
	modifyDialog("modal-dialog-large.lua", 3, IDX1), -- okBtn
	modifyDialog("modal-dialog-large.lua", 4, IDX2), -- cancelBtn
	modifyDialog("modal-dialog-large.lua", 6, IDX3), -- okBtn

	-- TODO: Grid layout.
	modifyDialog("modal-execterminals.lua", 5, -- location1
		skinButton(ctrlCoord{1})
	),
	modifyDialog("modal-execterminals.lua", 6, -- location2
		skinButton(ctrlCoord{2})
	),
	modifyDialog("modal-execterminals.lua", 7, -- location3
		skinButton(ctrlCoord{3})
	),
	modifyDialog("modal-execterminals.lua", 8, -- location4
		skinButton(ctrlCoord{4})
	),

	-- TODO: Drill button grid widgets[2].children[20].children[...]
	setLayout("modal-grafter.lua", {
		{ shape = [[HLIST]], defaultCoord = {2}, downToGroup = {2} },
		{ upToGroup = {1} },
	}, { defaultGroupChain = {1, 2} }),
	modifyDialog("modal-grafter.lua", 16, ctrlGroupCoord(1, {1})), -- installSocketBtn
	modifyDialog("modal-grafter.lua", 15, ctrlGroupCoord(1, {2})), -- installAugmentBtn (default)
	modifyDialog("modal-grafter.lua", 17, ctrlGroupCoord(2, {1})), -- cancelBtn

	modifyDialog("modal-install-augment.lua", 6, IDX1), -- installAugmentBtn
	modifyDialog("modal-install-augment.lua", 5, IDX2), -- leaveInInventoryBtn

	setLayout("modal-rewind.lua", {{ shape = [[HLIST]], defaultCoord = {2} }}),
	modifyDialog("modal-rewind.lua", 7, skinButton(IDX1)), -- cancelBtn
	modifyDialog("modal-rewind.lua", 3, skinButton(IDX2)), -- okBtn (default)

	-- TODO: listbox 9 @ IDX1
	modifyDialog("modal-select-dlc.lua", 6, IDX2), -- okBtn
	modifyDialog("modal-select-dlc.lua", 7, IDX3), -- cancelBtn

	-- Skipping the input elements and okBtn.
	modifyDialog("modal-signup.lua", 17, skinButton(IDX1)), -- cancelBtn

	setLayout("modal-story.lua", {
		{ downToGroup = {2} },
		{ shape = [[HLIST]], defaultCoord = {2}, upToGroup = {1} },
	}, { defaultGroup = 2 }),
	modifyDialog("modal-story.lua", 7, ctrlGroupCoord(1, {1})), -- skipBtn
	modifyDialog("modal-story.lua", 8, ctrlGroupCoord(2, {1})), -- prevBtn
	modifyDialog("modal-story.lua", 9, ctrlGroupCoord(2, {2})), -- nextBtn (default)

	modifyDialog("modal-update-disclaimer.lua", 5, skinButton(IDX1)), -- okBtn
	modifyDialog("modal-update-disclaimer.lua", 4, skinButton(IDX2)), -- readMoreBtn

	setLayout("modal-update-disclamer_b.lua", {
		{ rightToGroup = {2} },
		{ leftToGroup = {1} },
	}, { defaultGroup = 2 }),
	modifyDialog("modal-update-disclaimer_b.lua", 6, skinButton(ctrlGroupCoord(1, {1}))), -- resetBtn
	modifyDialog("modal-update-disclaimer_b.lua", 5, skinButton(ctrlGroupCoord(2, {1}))), -- okBtn (default)
	modifyDialog("modal-update-disclaimer_b.lua", 4, skinButton(ctrlGroupCoord(2, {2}))), -- readMoreBtn
}

return modifications
