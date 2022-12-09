local function assignCtrlIndex(childIndex, ctrlindex)
	return {
		"pause_dialog_screen.lua",
		{ "widgets", 2, "children", childIndex },
		{ ctrlindex = ctrlindex },
	}
end

local modifications = {
	assignCtrlIndex(7,  {1,1}), -- resumeBtn
	assignCtrlIndex(5,  {1,2}), -- optionsBtn
	assignCtrlIndex(10, {1,3}), -- helpBtn
	assignCtrlIndex(4,  {1,4}), -- quitBtn
	assignCtrlIndex(9,  {1,5}), -- abortBtn
	assignCtrlIndex(8,  {1,6}), -- retireBtn
}

return modifications

