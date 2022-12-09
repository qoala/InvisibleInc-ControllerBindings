-- Modal dialogs with a simple layout of buttons.

local IDX1 = { ctrlindex = {1,1} }
local IDX2 = { ctrlindex = {1,2} }
local IDX3 = { ctrlindex = {1,3} }

-- Skins add an extra layer of indirection on the modification.
-- Many dialogs use screen_button, though some use their own skin with the same btn child.
local function skinButton(buttonModification)
	return { inheritDef = { ["btn"] = buttonModification } }
end

-- Most dialogs have widgets[2] as the main dialog panel, with all buttons among its children.
local function modifyDialog(filename, childIndex, modification)
	return { filename, { "widgets", 2, "children", childIndex }, modification }
end

-- Many dialogs have a single screen_button (named okBtn, at child index 3).
local function oneButtonDialog(filename)
	return modifyDialog(filename, 3, skinButton(IDX1))
end

local modifications = {
	modifyDialog("modal-alarm-first.lua", 4, skinButton(IDX1)),
	modifyDialog("modal-unlock.lua", 5, skinButton(IDX1)),
	modifyDialog("modal-unlock-agents.lua", 5, skinButton(IDX1)),
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
	{ "modal-posttutorial.lua", { "widgets", 2, "children", 3, "children", 3 }, IDX1 },

	modifyDialog("modal-dialog.lua", 5, IDX1), -- okBtn
	modifyDialog("modal-dialog.lua", 6, IDX2), -- cancelBtn
	modifyDialog("modal-dialog.lua", 8, IDX3), -- okBtn
	modifyDialog("modal-dialog-large.lua", 3, IDX1), -- okBtn
	modifyDialog("modal-dialog-large.lua", 4, IDX2), -- cancelBtn
	modifyDialog("modal-dialog-large.lua", 6, IDX3), -- okBtn

	-- TODO: Grid layout.
	modifyDialog("modal-execterminals.lua", 5, -- location1
		skinButton({ ctrlindex = {1,1} })
	),
	modifyDialog("modal-execterminals.lua", 6, -- location2
		skinButton({ ctrlindex = {1,2} })
	),
	modifyDialog("modal-execterminals.lua", 7, -- location3
		skinButton({ ctrlindex = {1,3} })
	),
	modifyDialog("modal-execterminals.lua", 8, -- location4
		skinButton({ ctrlindex = {1,4} })
	),

	-- TODO: installSocketBtn left of installAugmentBtn, both above cancelBtn.
	-- TODO: Drill button grid widgets[2].children[20].children[...]
	modifyDialog("modal-grafter.lua", 16, IDX1), -- installSocketBtn
	modifyDialog("modal-grafter.lua", 15, IDX2), -- installAugmentBtn
	modifyDialog("modal-grafter.lua", 17, IDX3), -- cancelBtn

	modifyDialog("modal-install-augment.lua", 6, IDX1), -- installAugmentBtn
	modifyDialog("modal-install-augment.lua", 5, IDX2), -- leaveInInventoryBtn

	-- TODO: horizontal, cancelBtn left of okBtn
	modifyDialog("modal-rewind.lua", 3, skinButton(IDX1)), -- okBtn
	modifyDialog("modal-rewind.lua", 7, skinButton(IDX2)), -- cancelBtn

	-- TODO: listbox 9 @ IDX1
	modifyDialog("modal-select-dlc.lua", 6, IDX2), -- okBtn
	modifyDialog("modal-select-dlc.lua", 7, IDX2), -- cancelBtn

	-- Skipping the input elements and okBtn.
	modifyDialog("modal-signup.lua", 17, skinButton(IDX1)), -- cancelBtn

	-- TODO: nextBtn right of prevBtn, both below skipBtn
	modifyDialog("modal-story.lua", 7, IDX1), -- skipBtn
	modifyDialog("modal-story.lua", 8, IDX2), -- prevBtn
	modifyDialog("modal-story.lua", 9, IDX3), -- nextBtn

	modifyDialog("modal-update-disclaimer.lua", 5, skinButton(IDX1)), -- okBtn
	modifyDialog("modal-update-disclaimer.lua", 4, skinButton(IDX2)), -- readMoreBtn
	-- TODO: default okBtn
	-- TODO: resetBtn left of okBtn. okBtn above readMoreBtn
	modifyDialog("modal-update-disclaimer_b.lua", 5, skinButton(IDX1)), -- okBtn
	modifyDialog("modal-update-disclaimer_b.lua", 4, skinButton(IDX2)), -- readMoreBtn
	modifyDialog("modal-update-disclaimer_b.lua", 6, skinButton(IDX3)), -- resetBtn
}

return modifications
