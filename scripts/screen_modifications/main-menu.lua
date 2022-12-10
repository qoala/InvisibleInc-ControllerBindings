local function assignCoord(widgetIndex, coord)
	return {
		"main-menu.lua",
		{ "widgets", widgetIndex },
		{ ctrlProperties = { coord = coord } },
	}
end

local modifications = {
	assignCoord(9,  {1}), -- playBtn
	assignCoord(13, {2}), -- optionsBtn
	assignCoord(12, {3}), -- creditsBtn
	assignCoord(11, {4}), -- exitBtn
	assignCoord(10, {5}), -- signUpBtn
}

return modifications
