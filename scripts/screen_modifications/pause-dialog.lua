local function assignCoord(childIndex, coord)
	return {
		"pause_dialog_screen.lua",
		{ "widgets", 2, "children", childIndex },
		{ ctrlProperties = { coord = coord } },
	}
end

local function setLayout(layoutDef)
	return {
		"pause_dialog_screen.lua",
		{ "properties" },
		{ ctrlProperties = layoutDef },
	}
end

local modifications = {
	setLayout({ forceController = true }),
	assignCoord(7,  {1}), -- resumeBtn
	assignCoord(5,  {2}), -- optionsBtn
	assignCoord(10, {3}), -- helpBtn
	assignCoord(4,  {4}), -- quitBtn
	assignCoord(9,  {5}), -- abortBtn
	assignCoord(8,  {6}), -- retireBtn
}

return modifications

