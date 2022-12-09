local function assignCtrl(widgetIndex, coord)
	return {
		"main-menu.lua",
		{ "widgets", widgetIndex },
		{ ctrlCoord = coord },
	}
end

local modifications = {
	assignCtrl(9,  {1}), -- playBtn
	assignCtrl(13, {2}), -- optionsBtn
	assignCtrl(12, {3}), -- creditsBtn
	assignCtrl(11, {4}), -- exitBtn
	assignCtrl(10, {5}), -- signUpBtn
}

return modifications
