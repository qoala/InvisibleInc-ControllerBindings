local function assignCtrl(childIndex, coord)
	return {
		"pause_dialog_screen.lua",
		{ "widgets", 2, "children", childIndex },
		{ ctrlCoord = coord },
	}
end

local modifications = {
	assignCtrl(7,  {1}), -- resumeBtn
	assignCtrl(5,  {2}), -- optionsBtn
	assignCtrl(10, {3}), -- helpBtn
	assignCtrl(4,  {4}), -- quitBtn
	assignCtrl(9,  {5}), -- abortBtn
	assignCtrl(8,  {6}), -- retireBtn
}

return modifications

